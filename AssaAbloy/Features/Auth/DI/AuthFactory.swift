import SwiftUI

enum AuthFactory {
    static func makeViewModel() -> AuthViewModel {
        return AuthBuilder()
            .with(authService: AuthService())
            .with(tokenManager: KeychainManager.shared)
            .build()
    }
    
    static func makeSignInView(viewModel: AuthViewModel) -> SignInView {
        return SignInView(viewModel: viewModel)
    }
    
    static func makeSignUpView(viewModel: AuthViewModel) -> SignUpView {
        return SignUpView(viewModel: viewModel)
    }
}
