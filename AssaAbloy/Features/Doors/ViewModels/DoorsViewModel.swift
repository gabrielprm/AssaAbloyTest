import Foundation
import Combine

class DoorsViewModel: ObservableObject {
    @Published var doors: [Door] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = ""
    
    private let doorService: DoorServiceProtocol
    private var currentPage = 0
    private var totalPages = 1
    
    private var cancellables = Set<AnyCancellable>()
    
    init(doorService: DoorServiceProtocol) {
        self.doorService = doorService
        
        $searchText
            .dropFirst()
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] _ in
                Task { await self?.refresh() }
            }
            .store(in: &cancellables)
    }
    
    @MainActor
    func loadDoors() async {
        guard !isLoading && currentPage < totalPages else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let response: DoorsResponse
            if searchText.isEmpty {
                response = try await doorService.getDoors(page: currentPage)
            } else {
                response = try await doorService.findDoors(name: searchText, page: currentPage)
            }
            
            doors.append(contentsOf: response.content)
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
        doors = []
        currentPage = 0
        totalPages = 1
        await loadDoors()
    }
}