import XCTest
import Combine
@testable import AssaAbloy

class MockDoorService: DoorServiceProtocol {
    var mockDoorsResponse: DoorsResponse?
    var mockError: Error?
    
    var lastRequestedPage: Int?
    var lastRequestedName: String?
    
    func getDoors(page: Int) async throws -> DoorsResponse {
        lastRequestedPage = page
        if let error = mockError { throw error }
        return mockDoorsResponse!
    }
    
    func findDoors(name: String, page: Int) async throws -> DoorsResponse {
        lastRequestedName = name
        lastRequestedPage = page
        if let error = mockError { throw error }
        return mockDoorsResponse!
    }
}

final class DoorsViewModelTests: XCTestCase {
    var sut: DoorsViewModel!
    var mockService: MockDoorService!
    
    override func setUp() async throws {
        try await super.setUp()
        mockService = MockDoorService()
        await MainActor.run {
            sut = DoorsViewModel(doorService: mockService)
        }
    }

    func testLoadDoorsSuccess() async {
        let mockResponse = DoorsResponse(
            content: [Door(id: 1, serial: "S1", lockMac: "M1", name: "Door 1", address: "A1", latitude: 10, longitude: 10, battery: 90)],
            page: 0, size: 20, totalElements: 1, totalPages: 1, last: true
        )
        mockService.mockDoorsResponse = mockResponse
        
        await sut.loadDoors()
        
        await MainActor.run {
            XCTAssertEqual(sut.doors.count, 1)
            XCTAssertEqual(sut.doors.first?.name, "Door 1")
            XCTAssertEqual(mockService.lastRequestedPage, 0)
            XCTAssertNil(sut.errorMessage)
        }
    }
    
    func testSearchDoorsTrigger() async throws {
        let exp = expectation(description: "Debounce")
        
        let mockResponse = DoorsResponse(
            content: [Door(id: 1, serial: "S1", lockMac: "M1", name: "Search Door", address: "A1", latitude: 10, longitude: 10, battery: 90)],
            page: 0, size: 20, totalElements: 1, totalPages: 1, last: true
        )
        mockService.mockDoorsResponse = mockResponse
        
        await MainActor.run {
            sut.searchText = "Search"
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            exp.fulfill()
        }
        
        await fulfillment(of: [exp], timeout: 2.0)
        
        await MainActor.run {
            XCTAssertEqual(mockService.lastRequestedName, "Search")
            XCTAssertEqual(sut.doors.count, 1)
            XCTAssertEqual(sut.doors.first?.name, "Search Door")
        }
    }

    func testPagination() async {
        mockService.mockDoorsResponse = DoorsResponse(
            content: [Door(id: 1, serial: "S1", lockMac: "M1", name: "Door 1", address: "A1", latitude: 10, longitude: 10, battery: 90)],
            page: 0, size: 20, totalElements: 40, totalPages: 2, last: false
        )
        
        await sut.loadDoors()
        
        await MainActor.run {
            XCTAssertEqual(sut.doors.count, 1)
            XCTAssertEqual(mockService.lastRequestedPage, 0)
        }
        
        mockService.mockDoorsResponse = DoorsResponse(
            content: [Door(id: 2, serial: "S1", lockMac: "M1", name: "Door 2", address: "A1", latitude: 10, longitude: 10, battery: 90)],
            page: 1, size: 20, totalElements: 40, totalPages: 2, last: true
        )
        
        await sut.loadDoors()
        
        await MainActor.run {
            XCTAssertEqual(sut.doors.count, 2)
            XCTAssertEqual(mockService.lastRequestedPage, 1)
        }
    }
}
