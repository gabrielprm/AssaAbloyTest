import Foundation
import Combine

class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isAuthenticated = false
    
    private let authService: AuthService
    private let tokenManager: TokenManaging
    
    init(authService: AuthService, tokenManager: TokenManaging) {
        self.authService = authService
        self.tokenManager = tokenManager
        loadPreFilledEmail()
        checkAuth()
    }
    
    func loadPreFilledEmail() {
        if let storedEmail = try? tokenManager.getEmail() {
            email = storedEmail
        }
    }
    
    func checkAuth() {
        if let _ = try? tokenManager.getToken() {
            isAuthenticated = true
        }
    }
    
    @MainActor
    func signIn() async {
        isLoading = true
        errorMessage = nil
        do {
            let bodyDict = ["email": email, "password": password]
            let bodyData = try JSONSerialization.data(withJSONObject: bodyDict)
            let response = try await authService.signIn(body: bodyData)
            try tokenManager.saveToken(response.token)
            try tokenManager.saveEmail(email)
            isAuthenticated = true
        } catch NetworkError.serverError(let errorResponse) {
            errorMessage = errorResponse.description
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    @MainActor
    func signUp() async {
        isLoading = true
        errorMessage = nil
        do {
            let bodyDict = ["firstName": firstName, "lastName": lastName, "email": email, "password": password]
            let bodyData = try JSONSerialization.data(withJSONObject: bodyDict)
            _ = try await authService.signUp(body: bodyData)
            // After successful signup, auto sign-in
            await signIn()
        } catch NetworkError.serverError(let errorResponse) {
            if !errorResponse.fieldErrors.isEmpty {
                errorMessage = errorResponse.fieldErrors.map { "\($0.field): \($0.message)" }.joined(separator: "\n")
            } else {
                errorMessage = errorResponse.description
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func signOut() {
        try? tokenManager.clear()
        isAuthenticated = false
        password = ""
    }
}
