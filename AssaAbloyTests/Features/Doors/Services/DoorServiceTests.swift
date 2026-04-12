import XCTest
@testable import AssaAbloy

final class MockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            fatalError("Handler is unavailable.")
        }
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }
    
    override func stopLoading() {}
}

final class DoorServiceTests: XCTestCase {
    var session: URLSession!
    var tokenManager: MockTokenManager!
    var sut: DoorService!

    override func setUp() {
        super.setUp()
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        session = URLSession(configuration: config)
        tokenManager = MockTokenManager()
        sut = DoorService(session: session, tokenManager: tokenManager)
    }

    func testGetDoorsSuccess() async throws {
        await tokenManager.saveToken("mock_token")
        let mockResponse = DoorsResponse(
            content: [Door(id: 1, serial: "S1", lockMac: "M1", name: "Door 1", address: "A1", latitude: 10, longitude: 10, battery: 90)],
            page: 0, size: 20, totalElements: 1, totalPages: 1, last: true
        )
        
        let responseData = try JSONEncoder().encode(mockResponse)
        
        MockURLProtocol.requestHandler = { request in
            XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer mock_token")
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, responseData)
        }

        let result = try await sut.getDoors(page: 0)
        await MainActor.run {
            XCTAssertEqual(result.content.count, 1)
            XCTAssertEqual(result.content.first?.name, "Door 1")
        }
    }
    
    func testFindDoorsSuccess() async throws {
        await tokenManager.saveToken("mock_token")
        let mockResponse = DoorsResponse(
            content: [Door(id: 2, serial: "S2", lockMac: "M2", name: "Alpha", address: "A2", latitude: 20, longitude: 20, battery: 80)],
            page: 0, size: 20, totalElements: 1, totalPages: 1, last: true
        )
        
        let responseData = try JSONEncoder().encode(mockResponse)
        
        MockURLProtocol.requestHandler = { request in
            XCTAssertTrue(request.url!.absoluteString.contains("name=Alpha"))
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, responseData)
        }

        let result = try await sut.findDoors(name: "Alpha", page: 0)
        await MainActor.run {
            XCTAssertEqual(result.content.count, 1)
            XCTAssertEqual(result.content.first?.name, "Alpha")
        }
    }
    
    func testUnauthenticatedError() async throws {
        await tokenManager.clear()
        do {
            _ = try await sut.getDoors(page: 0)
            XCTFail("Should throw unhandledResponse/missingToken")
        } catch NetworkError.unhandledResponse {
            // expected
        } catch {
            XCTFail("Unexpected error \(error)")
        }
    }
}
