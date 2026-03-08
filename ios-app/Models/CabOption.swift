import Foundation

struct CabOption: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let price: String
    let etaMinutes: Int
    let appName: String

    init(id: UUID = UUID(), name: String, price: String, etaMinutes: Int, appName: String) {
        self.id = id
        self.name = name
        self.price = price
        self.etaMinutes = etaMinutes
        self.appName = appName
    }
}

extension CabOption {
    static let sampleData: [CabOption] = [
        CabOption(name: "UberX", price: "$14", etaMinutes: 3, appName: "Uber"),
        CabOption(name: "Lyft", price: "$16", etaMinutes: 4, appName: "Lyft"),
        CabOption(name: "Uber Comfort", price: "$19", etaMinutes: 5, appName: "Uber")
    ]
}
