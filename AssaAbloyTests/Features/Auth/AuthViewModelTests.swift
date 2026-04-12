//
//  AuthViewModelTests.swift
//  AssaAbloyTests
//
//  Created by Gabriel do Prado Moreira on 07/04/26.
//

import XCTest
@testable import AssaAbloy
import Combine

final class MockTokenManager: TokenManaging {
    var storedToken: String?
    var storedEmail: String?
    
    func saveToken(_ token: String) throws { storedToken = token }
    func getToken() throws -> String? { return storedToken }
    func saveEmail(_ email: String) throws { storedEmail = email }
    func getEmail() throws -> String? { return storedEmail }
    func clear() throws {
        storedToken = nil
        storedEmail = nil
    }
}

final class AuthViewModelTests: XCTestCase {
    var viewModel: AuthViewModel!
    var mockTokenManager: MockTokenManager!
    
    override func setUp() {
        super.setUp()
        mockTokenManager = MockTokenManager()
        viewModel = AuthViewModel(authService: AuthService(), tokenManager: mockTokenManager)
    }
    
    func testLoadPreFilledEmail() throws {
        try mockTokenManager.saveEmail("test@example.com")
        
        let newViewModel = AuthViewModel(authService: AuthService(), tokenManager: mockTokenManager)
        
        XCTAssertEqual(newViewModel.email, "test@example.com")
    }
    
    func testCheckAuth() throws {
        try mockTokenManager.saveToken("sample_token")
        
        let newViewModel = AuthViewModel(authService: AuthService(), tokenManager: mockTokenManager)
        
        XCTAssertTrue(newViewModel.isAuthenticated)
    }
    
    func testSignOut() throws {
        try mockTokenManager.saveToken("sample_token")
        viewModel.isAuthenticated = true
        
        viewModel.signOut()
        
        XCTAssertFalse(viewModel.isAuthenticated)
        XCTAssertNil(try mockTokenManager.getToken())
    }
}