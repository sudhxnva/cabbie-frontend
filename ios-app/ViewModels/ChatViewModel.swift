import Foundation
import Combine

@MainActor
final class ChatViewModel: ObservableObject {
    @Published private(set) var messages: [ChatMessage] = []
    @Published var rideOptions: [CabOption] = []
    @Published var bookingConfirmation: BookingConfirmation?
    @Published var inputText = ""
    @Published var voiceState: VoiceOrbView.OrbState = .idle
    @Published private(set) var isUsingRealAgent = false
    @Published private(set) var isCallActive = false
    @Published private(set) var isMuted = true
    @Published private(set) var isConnecting = false
    @Published var callErrorMessage: String?

    private let elevenLabsService: ElevenLabsService
    private let backendAPI: BackendAPI

    init(
        elevenLabsService: ElevenLabsService,
        backendAPI: BackendAPI
    ) {
        self.elevenLabsService = elevenLabsService
        self.backendAPI = backendAPI
        bindService()
    }

    convenience init() {
        self.init(
            elevenLabsService: ElevenLabsService(),
            backendAPI: BackendAPI()
        )
    }

    func sendMessage() {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        elevenLabsService.sendText(trimmed, origin: .textInput)
        if !isUsingRealAgent {
            fetchRideOptions(for: trimmed)
        }
        inputText = ""
    }

    func cycleVoiceState() {
        if isCallActive {
            elevenLabsService.stopConversation()
            return
        }
        if isConnecting {
            return
        }
        elevenLabsService.startConversation()
    }

    func toggleMute() {
        elevenLabsService.toggleMute()
    }

    func setMuted(_ muted: Bool) {
        elevenLabsService.setMuted(muted)
    }

    func bookRide(_ option: CabOption) {
        elevenLabsService.sendText("Book \(option.name) with \(option.appName) for \(option.price).", origin: .system)
        if isUsingRealAgent {
            return
        }

        Task {
            do {
                let confirmation = try await backendAPI.confirmBooking(BookingConfirmRequest(optionId: option.id))
                bookingConfirmation = confirmation
            } catch {
                elevenLabsService.sendText("Could not confirm booking yet. Please try again.", origin: .system)
            }
        }
    }

    private func bindService() {
        elevenLabsService.$messages
            .receive(on: DispatchQueue.main)
            .assign(to: &$messages)

        elevenLabsService.$conversationState
            .receive(on: DispatchQueue.main)
            .map { state in
                switch state {
                case .idle, .stopped:
                    return VoiceOrbView.OrbState.idle
                case .connecting:
                    return VoiceOrbView.OrbState.connecting
                case .listening:
                    return VoiceOrbView.OrbState.listening
                case .speaking:
                    return VoiceOrbView.OrbState.speaking
                }
            }
            .assign(to: &$voiceState)

        elevenLabsService.$conversationState
            .receive(on: DispatchQueue.main)
            .map { $0 == .connecting }
            .assign(to: &$isConnecting)

        elevenLabsService.$isUsingRealAgent
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: { [weak self] isReal in
                if isReal {
                    self?.rideOptions = []
                }
            })
            .assign(to: &$isUsingRealAgent)

        elevenLabsService.$isCallActive
            .receive(on: DispatchQueue.main)
            .assign(to: &$isCallActive)

        elevenLabsService.$isMuted
            .receive(on: DispatchQueue.main)
            .assign(to: &$isMuted)

        elevenLabsService.$callErrorMessage
            .receive(on: DispatchQueue.main)
            .assign(to: &$callErrorMessage)
    }

    func clearCallError() {
        callErrorMessage = nil
        elevenLabsService.clearCallError()
    }

    private func fetchRideOptions(for message: String) {
        let request = BookingRequest(
            userId: "demo-user",
            pickup: "Current location",
            dropoff: message,
            passengers: nil
        )

        Task {
            do {
                let response = try await backendAPI.requestBooking(request)
                rideOptions = response.options
            } catch {
                rideOptions = []
            }
        }
    }
}
