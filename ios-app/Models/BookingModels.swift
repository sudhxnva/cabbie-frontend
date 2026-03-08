import Foundation

struct BookingRequest: Codable, Equatable {
    let userId: String
    let pickup: String
    let dropoff: String
    let passengers: Int?
}

struct BookingSearchResponse: Codable, Equatable {
    let options: [CabOption]
    let status: String
}

struct BookingConfirmRequest: Codable, Equatable {
    let optionId: UUID
}

struct DriverInfo: Codable, Equatable {
    let name: String
    let vehicle: String
    let licensePlate: String
    let etaMinutes: Int
}

struct BookingConfirmation: Codable, Equatable, Identifiable {
    let id: UUID
    let status: String
    let option: CabOption
    let driver: DriverInfo?
}

struct HealthResponse: Codable, Equatable {
    let status: String
}

extension BookingConfirmation {
    static func sample(for option: CabOption = CabOption.sampleData[0]) -> BookingConfirmation {
        BookingConfirmation(
            id: UUID(),
            status: "Ride booked",
            option: option,
            driver: DriverInfo(
                name: "Alex",
                vehicle: "Toyota Prius (Silver)",
                licensePlate: "CAB-4021",
                etaMinutes: option.etaMinutes
            )
        )
    }
}
