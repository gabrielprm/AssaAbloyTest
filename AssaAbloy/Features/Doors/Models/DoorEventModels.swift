import Foundation

struct EventAdditionalData: Codable, Equatable {
    let parameterName: String
    let hexValue: String?
    let parsedValue: String?
}

struct DoorEvent: Codable, Identifiable, Equatable {
    let id: Int
    let logType: String
    let logNumber: Int
    let eventTimestamp: String
    let additionalData: [EventAdditionalData]
}

struct DoorEventsResponse: Codable, Equatable {
    let content: [DoorEvent]
    let page: Int
    let size: Int
    let totalElements: Int
    let totalPages: Int
    let last: Bool
}