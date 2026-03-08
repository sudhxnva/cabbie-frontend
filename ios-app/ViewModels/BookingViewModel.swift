import Foundation

final class BookingViewModel: ObservableObject {
    @Published var confirmation: BookingConfirmation

    init(confirmation: BookingConfirmation = .sample()) {
        self.confirmation = confirmation
    }
}
