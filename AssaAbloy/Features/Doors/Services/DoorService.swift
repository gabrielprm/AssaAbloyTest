import Foundation

protocol DoorServiceProtocol {
    func getDoors(page: Int) async throws -> DoorsResponse
    func findDoors(name: String, page: Int) async throws -> DoorsResponse
    func getEvents(doorId: Int, page: Int) async throws -> DoorEventsResponse
    func getPermissions(doorId: Int, page: Int) async throws -> PermissionsResponse
    func createPermission(doorId: Int, request: PermissionCreateRequest) async throws -> Permission
    func updatePermission(doorId: Int, permissionId: Int, request: PermissionUpdateRequest) async throws -> Permission
    func deletePermission(doorId: Int, permissionId: Int) async throws
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
    
    func getPermissions(doorId: Int, page: Int) async throws -> PermissionsResponse {
        var urlComponents = URLComponents(url: API.baseURL.appendingPathComponent("doors/\(doorId)/permissions"), resolvingAgainstBaseURL: false)!
        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "size", value: "20")
        ]
        
        return try await fetch(url: urlComponents.url!)
    }
    
    func createPermission(doorId: Int, request: PermissionCreateRequest) async throws -> Permission {
        let url = API.baseURL.appendingPathComponent("doors/\(doorId)/permissions")
        let data = try JSONEncoder().encode(request)
        return try await performRequest(url: url, method: "POST", body: data, responseType: Permission.self)
    }
    
    func updatePermission(doorId: Int, permissionId: Int, request: PermissionUpdateRequest) async throws -> Permission {
        let url = API.baseURL.appendingPathComponent("doors/\(doorId)/permissions/\(permissionId)")
        let data = try JSONEncoder().encode(request)
        return try await performRequest(url: url, method: "PATCH", body: data, responseType: Permission.self)
    }
    
    func deletePermission(doorId: Int, permissionId: Int) async throws {
        let url = API.baseURL.appendingPathComponent("doors/\(doorId)/permissions/\(permissionId)")
        try await performEmptyRequest(url: url, method: "DELETE", body: nil)
    }
    
    private func fetch<T: Decodable>(url: URL) async throws -> T {
        return try await performRequest(url: url, method: "GET", body: nil, responseType: T.self)
    }
    
    private func performRequest<T: Decodable>(url: URL, method: String, body: Data?, responseType: T.Type) async throws -> T {
        guard let token = try? tokenManager.getToken() else {
            throw NetworkError.unhandledResponse
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        if let body = body {
            request.httpBody = body
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        return try await networkClient.request(request, responseType: T.self)
    }
    
    private func performEmptyRequest(url: URL, method: String, body: Data?) async throws {
        guard let token = try? tokenManager.getToken() else {
            throw NetworkError.unhandledResponse
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        if let body = body {
            request.httpBody = body
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        try await networkClient.request(request)
    }
}