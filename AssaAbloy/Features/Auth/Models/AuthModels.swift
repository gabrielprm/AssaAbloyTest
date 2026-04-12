import Foundation

struct User: Codable, Identifiable {
    let id: String
    let firstName: String
    let lastName: String
    let email: String
    let createdAt: String?
}

struct AuthResponse: Codable {
    let token: String
}

struct ErrorResponse: Codable, Error {
    let code: String
    let description: String
    let fieldErrors: [FieldError]
    
    struct FieldError: Codable {
        let field: String
        let message: String
    }
}