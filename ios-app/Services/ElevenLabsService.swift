import Foundation
import Combine
#if canImport(ElevenLabs)
import ElevenLabs
#endif

@MainActor
final class ElevenLabsService: ObservableObject {
    enum TextOrigin {
        case textInput
        case system
    }

    enum ConversationState: Equatable {
        case idle
        case connecting
        case listening
        case speaking
        case stopped
    }

    struct AgentEvent: Identifiable, Equatable {
        let id = UUID()
        let timestamp: Date
        let description: String
    }

    @Published private(set) var messages: [ChatMessage] = []
    @Published private(set) var conversationState: ConversationState = .idle
    @Published private(set) var agentEvents: [AgentEvent] = []
    @Published private(set) var isUsingRealAgent = false
    @Published private(set) var isCallActive = false
    @Published private(set) var isMuted = true
    @Published private(set) var callErrorMessage: String?

    private let config: AppConfig
    private var shouldRenderAgentText = false
#if canImport(ElevenLabs)
    private var conversation: Conversation?
    private var cancellables = Set<AnyCancellable>()
    private var seenAgentMessageIDs = Set<String>()
    private var seenToolCallIDs = Set<String>()
    private var connectionTimeoutTask: Task<Void, Never>?
    private var connectionAttemptID: UUID?
#endif

    init(config: AppConfig = .current) {
        self.config = config
    }

    func startConversation() {
        guard !isCallActive else { return }

        if config.shouldUseRealElevenLabs {
            startRealConversation()
            return
        }

        shouldRenderAgentText = false
        isUsingRealAgent = false
        conversationState = .listening
        isCallActive = true
        isMuted = false
        appendEvent("Conversation started (stub)")
        if !config.useStubElevenLabs {
            appendEvent("Missing ElevenLabs credentials/config, running in stub mode.")
        }
    }

    func stopConversation() {
#if canImport(ElevenLabs)
        connectionTimeoutTask?.cancel()
        connectionTimeoutTask = nil
        connectionAttemptID = nil
        let activeConversation = conversation
        conversation = nil
        cancellables.removeAll()
        seenAgentMessageIDs.removeAll()
        seenToolCallIDs.removeAll()
        Task {
            await activeConversation?.endConversation()
        }
#endif
        isUsingRealAgent = false
        conversationState = .stopped
        isCallActive = false
        isMuted = true
        appendEvent("Conversation stopped")
    }

    func toggleMute() {
        setMuted(!isMuted)
    }

    func setMuted(_ muted: Bool) {
#if canImport(ElevenLabs)
        guard isUsingRealAgent, let conversation else {
            isMuted = muted
            return
        }
        Task {
            do {
                try await conversation.setMuted(muted)
            } catch {
                await MainActor.run {
                    self.appendEvent("Mute change failed: \(error.localizedDescription)")
                }
            }
        }
#else
        isMuted = muted
#endif
    }

    func sendText(_ message: String, origin: TextOrigin = .system) {
        let trimmed = message.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        if origin == .textInput {
            shouldRenderAgentText = true
            messages.append(ChatMessage(sender: .user, text: trimmed, timestamp: .now))
        }
        appendEvent("User text sent: \(trimmed)")

        if isUsingRealAgent {
#if canImport(ElevenLabs)
            Task {
                do {
                    try await conversation?.sendMessage(trimmed)
                } catch {
                    appendEvent("Failed to send message to ElevenLabs: \(error.localizedDescription)")
                }
            }
#else
            appendEvent("ElevenLabs SDK missing, cannot send real message.")
#endif
            return
        }

        handleToolCall(name: "search_cabs", payload: "{ \"query\": \"\(trimmed)\" }")

        if shouldRenderAgentText && !isCallActive {
            let agentReply = "Got it. Comparing ride options now."
            messages.append(ChatMessage(sender: .agent, text: agentReply, timestamp: .now))
            appendEvent("Agent reply received (stub)")
        }
        conversationState = .speaking
    }

    private func handleToolCall(name: String, payload: String) {
        // Stubbed until backend tool execution is integrated.
        appendEvent("Tool call requested: \(name) payload=\(payload)")
    }

    private func appendEvent(_ description: String) {
        agentEvents.append(AgentEvent(timestamp: .now, description: description))
    }

    private func reportCallError(_ message: String) {
        callErrorMessage = message
        appendEvent(message)
    }

    func clearCallError() {
        callErrorMessage = nil
    }

    private func startRealConversation() {
#if canImport(ElevenLabs)
        Task {
            do {
                clearCallError()
                shouldRenderAgentText = false
                guard let agentID = config.elevenLabsAgentID, !agentID.isEmpty else {
                    reportCallError("Missing ElevenLabs configuration. Check agent and API settings.")
                    isUsingRealAgent = false
                    conversationState = .idle
                    isCallActive = false
                    return
                }

                let attemptID = UUID()
                connectionAttemptID = attemptID

                var conversationConfig = ConversationConfig()
                conversationConfig.onAgentReady = { [weak self] in
                    Task { @MainActor in
                        guard self?.connectionAttemptID == attemptID else { return }
                        self?.connectionTimeoutTask?.cancel()
                        self?.connectionTimeoutTask = nil
                        self?.isUsingRealAgent = true
                        self?.conversationState = .listening
                        self?.isCallActive = true
                        self?.isMuted = false
                        self?.appendEvent("Connected to ElevenLabs agent")
                    }
                }
                conversationConfig.onDisconnect = { [weak self] in
                    Task { @MainActor in
                        self?.isUsingRealAgent = false
                        self?.conversationState = .stopped
                        self?.isCallActive = false
                        self?.isMuted = true
                        self?.appendEvent("Disconnected from ElevenLabs agent")
                    }
                }

                conversationState = .connecting
                isCallActive = false
                let startedConversation = try await ElevenLabs.startConversation(
                    agentId: agentID,
                    config: conversationConfig
                )
                guard connectionAttemptID == attemptID else {
                    await startedConversation.endConversation()
                    return
                }
                conversation = startedConversation
                bindConversation(startedConversation)

                connectionTimeoutTask?.cancel()
                connectionTimeoutTask = Task { @MainActor [weak self] in
                    try? await Task.sleep(for: .seconds(12))
                    guard let self else { return }
                    guard self.connectionAttemptID == attemptID else { return }
                    guard self.conversationState == .connecting, !self.isCallActive else { return }
                    self.stopConversation()
                    self.reportCallError("Connection timed out. Please try again.")
                }
            } catch {
                isUsingRealAgent = false
                conversationState = .idle
                isCallActive = false
                reportCallError("Failed to connect: \(error.localizedDescription)")
            }
        }
#else
        isUsingRealAgent = false
        conversationState = .idle
        appendEvent("ElevenLabs SDK not installed in project. Running in stub mode.")
#endif
    }

#if canImport(ElevenLabs)
    private func bindConversation(_ conversation: Conversation) {
        cancellables.removeAll()
        seenAgentMessageIDs.removeAll()
        seenToolCallIDs.removeAll()

        conversation.$isMuted
            .receive(on: DispatchQueue.main)
            .sink { [weak self] muted in
                self?.isMuted = muted
            }
            .store(in: &cancellables)

        conversation.$agentState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                switch state {
                case .speaking:
                    self?.conversationState = .speaking
                case .listening, .thinking:
                    self?.conversationState = .listening
                case .connecting, .initializing:
                    self?.conversationState = .connecting
                case .disconnected, .unknown:
                    self?.conversationState = .stopped
                }
            }
            .store(in: &cancellables)

        conversation.$messages
            .receive(on: DispatchQueue.main)
            .sink { [weak self] sdkMessages in
                guard let self else { return }
                for message in sdkMessages where message.role == .agent {
                    guard !self.seenAgentMessageIDs.contains(message.id) else { continue }
                    self.seenAgentMessageIDs.insert(message.id)
                    let trimmed = message.content.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !trimmed.isEmpty else { continue }
                    guard self.shouldRenderAgentText, !self.isCallActive else { continue }
                    self.messages.append(ChatMessage(sender: .agent, text: trimmed, timestamp: message.timestamp))
                    self.conversationState = .speaking
                }
            }
            .store(in: &cancellables)

        conversation.$pendingToolCalls
            .receive(on: DispatchQueue.main)
            .sink { [weak self] toolCalls in
                guard let self else { return }
                for toolCall in toolCalls {
                    guard !self.seenToolCallIDs.contains(toolCall.toolCallId) else { continue }
                    self.seenToolCallIDs.insert(toolCall.toolCallId)
                    self.appendEvent("Unhandled tool call: \(toolCall.toolName)")
                }
            }
            .store(in: &cancellables)

        conversation.$mcpToolCalls
            .receive(on: DispatchQueue.main)
            .sink { [weak self] toolCalls in
                guard let self, let latest = toolCalls.last else { return }
                self.appendEvent("Agent tool request: \(latest.toolName)")
            }
            .store(in: &cancellables)

        conversation.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                switch state {
                case .active:
                    self?.isCallActive = true
                case .connecting:
                    self?.conversationState = .connecting
                    self?.isCallActive = false
                default:
                    self?.isCallActive = false
                }
            }
            .store(in: &cancellables)
    }
#endif
}
