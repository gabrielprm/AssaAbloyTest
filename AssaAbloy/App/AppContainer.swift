import SwiftUI
import Combine

class AppContainer: ObservableObject {
    let authService = AuthService()
    let tokenManager = KeychainManager.shared
    let objectWillChange = PassthroughSubject<Void, Never>()
}