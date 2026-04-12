import Foundation

enum NetworkError: Error {
    case invalidURL
    case noData
    case parsingError
    case serverError(ErrorResponse)
    case unhandledResponse
}

class AuthService {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func signUp(body: Data) async throws -> User {
        let url = API.baseURL.appendingPathComponent("users/signup")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unhandledResponse
        }
        
        if httpResponse.statusCode == 201 {
            return try JSONDecoder().decode(User.self, from: data)
        } else {
            let errorResp = try JSONDecoder().decode(ErrorResponse.self, from: data)
            throw NetworkError.serverError(errorResp)
        }
    }
    
    func signIn(body: Data) async throws -> AuthResponse {
        let url = API.baseURL.appendingPathComponent("users/signin")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unhandledResponse
        }
        
        if httpResponse.statusCode == 200 {
            return try JSONDecoder().decode(AuthResponse.self, from: data)
        } else {
            if let errorResp = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                 throw NetworkError.serverError(errorResp)
            } else {
                 throw NetworkError.unhandledResponse
            }
        }
    }
}