import Foundation

protocol DoorServiceProtocol {
    func getDoors(page: Int) async throws -> DoorsResponse
    func findDoors(name: String, page: Int) async throws -> DoorsResponse
    func getEvents(doorId: Int, page: Int) async throws -> DoorEventsResponse
}

class DoorService: DoorServiceProtocol {
    private let networkClient: NetworkClientProtocol
    private let tokenManager: TokenManaging
    
    init(networkClient: NetworkClientProtocol = NetworkClient(), tokenManager: TokenManaging) {
        self.networkClient = networkClient
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
    
    func getEvents(doorId: Int, page: Int) async throws -> DoorEventsResponse {
        var urlComponents = URLComponents(url: API.baseURL.appendingPathComponent("doors/\(doorId)/events"), resolvingAgainstBaseURL: false)!
        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "size", value: "20"),
            URLQueryItem(name: "sort", value: "eventTimestamp,desc")
        ]
        
        return try await fetch(url: urlComponents.url!)
    }
    
    private func fetch<T: Decodable>(url: URL) async throws -> T {
        guard let token = try? tokenManager.getToken() else {
            throw NetworkError.unhandledResponse
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return try await networkClient.request(request, responseType: T.self)
    }
}