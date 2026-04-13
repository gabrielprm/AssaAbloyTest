import Foundation
import Combine

class DoorEventsViewModel: ObservableObject {
    @Published var events: [DoorEvent] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let doorService: DoorServiceProtocol
    let door: Door
    
    private var currentPage = 0
    private var totalPages = 1
    
    init(doorService: DoorServiceProtocol, door: Door) {
        self.doorService = doorService
        self.door = door
    }
    
    @MainActor
    func loadEvents() async {
        guard !isLoading && currentPage < totalPages else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await doorService.getEvents(doorId: door.id, page: currentPage)
            events.append(contentsOf: response.content)
            currentPage = response.page + 1
            totalPages = response.totalPages
        } catch NetworkError.serverError(let errorResponse) {
            errorMessage = errorResponse.description
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    @MainActor
    func refresh() async {
        events = []
        currentPage = 0
        totalPages = 1
        await loadEvents()
    }
}