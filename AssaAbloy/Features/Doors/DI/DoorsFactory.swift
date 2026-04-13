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
    
    static func makeDoorEventsViewModel(for door: Door) -> DoorEventsViewModel {
        return DoorEventsViewModel(doorService: DoorService(tokenManager: KeychainManager.shared), door: door)
    }
    
    static func makeDoorEventsListView(for door: Door) -> DoorEventsListView {
        let viewModel = makeDoorEventsViewModel(for: door)
        return DoorEventsListView(viewModel: viewModel)
    }

    static func makePermissionsListView(for door: Door) -> PermissionsListView {
        let viewModel = PermissionsViewModel(door: door, doorService: DoorService(tokenManager: KeychainManager.shared))
        return PermissionsListView(viewModel: viewModel)
    }
}