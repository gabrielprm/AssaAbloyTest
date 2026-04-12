import Foundation

class AuthBuilder {
    private var authService: AuthService?
    private var tokenManager: TokenManaging?
    
    func with(authService: AuthService) -> Self {
        self.authService = authService
        return self
    }
    
    func with(tokenManager: TokenManaging) -> Self {
        self.tokenManager = tokenManager
        return self
    }
    
    func build() -> AuthViewModel {
        let service = authService ?? AuthService()
        let manager = tokenManager ?? KeychainManager.shared
        return AuthViewModel(authService: service, tokenManager: manager)
    }
}
