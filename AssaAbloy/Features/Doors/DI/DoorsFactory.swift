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
        return DoorEventsListView(viewModel: makeDoorEventsViewModel(for: door))
    }
}