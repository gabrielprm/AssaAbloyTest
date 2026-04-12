import SwiftUI

enum DoorsFactory {
    static func makeViewModel() -> DoorsViewModel {
        return DoorsBuilder()
            .with(doorService: DoorService(tokenManager: KeychainManager.shared))
            .build()
    }
    
    static func makeDoorsListView() -> DoorsListView {
        return DoorsListView(viewModel: makeViewModel())
    }
}