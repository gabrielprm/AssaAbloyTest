import SwiftUI

class DoorsBuilder {
    private var doorService: DoorServiceProtocol?

    func with(doorService: DoorServiceProtocol) -> Self {
        self.doorService = doorService
        return self
    }

    func build() -> DoorsViewModel {
        guard let doorService = doorService else {
            fatalError("DoorServiceProtocol not provided")
        }
        return DoorsViewModel(doorService: doorService)
    }
}
