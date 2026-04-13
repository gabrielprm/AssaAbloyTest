import Foundation

protocol NetworkClientProtocol {
    func request<T: Decodable>(_ urlRequest: URLRequest, responseType: T.Type) async throws -> T
}

class NetworkClient: NetworkClientProtocol {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func request<T: Decodable>(_ urlRequest: URLRequest, responseType: T.Type) async throws -> T {
        let (data, response) = try await session.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unhandledResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            if httpResponse.statusCode == 401 {
                throw NetworkError.unauthorized
            }
            if let errorResp = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                throw NetworkError.serverError(errorResp)
            }
            throw NetworkError.unhandledResponse
        }
        
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw NetworkError.parsingError
        }
    }
}