import Foundation

struct User: Codable, Identifiable {
    let id: Int
    let firstName: String
    let lastName: String
    let email: String
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
