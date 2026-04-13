import Foundation

enum NetworkError: Error {
    case invalidURL
    case noData
    case parsingError
    case serverError(ErrorResponse)
    case unhandledResponse
    case unauthorized
}