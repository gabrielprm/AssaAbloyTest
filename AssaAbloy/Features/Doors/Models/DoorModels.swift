import Foundation

struct Door: Codable, Identifiable, Equatable {
    let id: Int
    let serial: String
    let lockMac: String
    let name: String
    let address: String
    let latitude: Double
    let longitude: Double
    let battery: Int
}

struct DoorsResponse: Codable, Equatable {
    let content: [Door]
    let page: Int
    let size: Int
    let totalElements: Int
    let totalPages: Int
    let last: Bool
}
