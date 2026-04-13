import Foundation

class AuthService {
    private let networkClient: NetworkClientProtocol
    
    init(networkClient: NetworkClientProtocol = NetworkClient()) {
        self.networkClient = networkClient
    }
    
    func signUp(body: Data) async throws -> User {
        let url = API.baseURL.appendingPathComponent("users/signup")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        
        return try await networkClient.request(request, responseType: User.self)
    }
    
    func signIn(body: Data) async throws -> AuthResponse {
        let url = API.baseURL.appendingPathComponent("users/signin")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        
        return try await networkClient.request(request, responseType: AuthResponse.self)
    }
}