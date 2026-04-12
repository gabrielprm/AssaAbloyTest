import Foundation

protocol DoorServiceProtocol {
    func getDoors(page: Int) async throws -> DoorsResponse
    func findDoors(name: String, page: Int) async throws -> DoorsResponse
}

class DoorService: DoorServiceProtocol {
    private let session: URLSession
    private let tokenManager: TokenManaging
    
    init(session: URLSession = .shared, tokenManager: TokenManaging) {
        self.session = session
        self.tokenManager = tokenManager
    }
    
    func getDoors(page: Int) async throws -> DoorsResponse {
        var urlComponents = URLComponents(url: API.baseURL.appendingPathComponent("doors"), resolvingAgainstBaseURL: false)!
        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "size", value: "20")
        ]
        
        return try await fetch(url: urlComponents.url!)
    }
    
    func findDoors(name: String, page: Int) async throws -> DoorsResponse {
        var urlComponents = URLComponents(url: API.baseURL.appendingPathComponent("doors/find"), resolvingAgainstBaseURL: false)!
        urlComponents.queryItems = [
            URLQueryItem(name: "name", value: name),
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "size", value: "20")
        ]
        
        return try await fetch(url: urlComponents.url!)
    }
    
    private func fetch(url: URL) async throws -> DoorsResponse {
        guard let token = try? tokenManager.getToken() else {
            throw NetworkError.unhandledResponse
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unhandledResponse
        }
        
        if httpResponse.statusCode == 200 {
            return try JSONDecoder().decode(DoorsResponse.self, from: data)
        } else {
            if let errorResp = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                throw NetworkError.serverError(errorResp)
            } else {
                throw NetworkError.unhandledResponse
            }
        }
    }
}
