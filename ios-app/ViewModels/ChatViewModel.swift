import Foundation
import Combine

@MainActor
final class ChatViewModel: ObservableObject {
    @Published private(set) var messages: [ChatMessage] = []
    @Published var rideOptions: [CabOption] = []
    @Published var bookingConfirmation: BookingConfirmation?
    @Published var inputText = ""
    @Published var voiceState: VoiceOrbView.OrbState = .idle

    private let elevenLabsService: ElevenLabsService
    private let backendAPI: BackendAPI

    init(
        elevenLabsService: ElevenLabsService = ElevenLabsService(),
        backendAPI: BackendAPI = BackendAPI()
    ) {
        self.elevenLabsService = elevenLabsService
        self.backendAPI = backendAPI
        bindService()
        elevenLabsService.startConversation()
        rideOptions = CabOption.sampleData
    }

    func sendMessage() {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        elevenLabsService.sendText(trimmed)
        rideOptions = CabOption.sampleData
        inputText = ""
    }

    func cycleVoiceState() {
        switch elevenLabsService.conversationState {
        case .idle, .stopped:
            elevenLabsService.startConversation()
        case .listening, .speaking:
            elevenLabsService.stopConversation()
        }
    }

    func bookRide(_ option: CabOption) {
        elevenLabsService.sendText("Book \(option.name) with \(option.appName) for \(option.price).")
        Task {
            do {
                let confirmation = try await backendAPI.confirmBooking(BookingConfirmRequest(optionId: option.id))
                bookingConfirmation = confirmation
            } catch {
                elevenLabsService.sendText("Could not confirm booking yet. Please try again.")
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
                case .listening:
                    return VoiceOrbView.OrbState.listening
                case .speaking:
                    return VoiceOrbView.OrbState.speaking
                }
            }
            .assign(to: &$voiceState)
    }
}
