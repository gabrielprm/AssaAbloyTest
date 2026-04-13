import Foundation

struct Permission: Codable, Identifiable, Equatable {
    let id: Int
    let doorId: Int
    let type: PermissionType
    let value: String
    let startDateTime: String
    let endDateTime: String
    let weekDays: Int
}

enum PermissionType: String, Codable, Equatable, CaseIterable {
    case smartphone = "SMARTPHONE"
    case passcode = "PASSCODE"
    case card = "CARD"
}

struct PermissionsResponse: Codable, Equatable {
    let content: [Permission]
    let page: Int
    let size: Int
    let totalElements: Int
    let totalPages: Int
    let last: Bool
}

struct PermissionCreateRequest: Codable {
    let type: PermissionType
    let value: String
    let startDateTime: String
    let endDateTime: String
    let weekDays: Int
}

struct PermissionUpdateRequest: Codable {
    let startDateTime: String?
    let endDateTime: String?
    let weekDays: Int?
}
