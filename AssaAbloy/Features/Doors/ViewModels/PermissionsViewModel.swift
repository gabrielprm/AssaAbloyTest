import Foundation
import Combine
import SwiftUI

@MainActor
class PermissionsViewModel: ObservableObject {
    @Published var permissions: [Permission] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let doorService: DoorServiceProtocol
    let door: Door
    
    private var currentPage = 0
    private var totalPages = 1
    
    init(door: Door, doorService: DoorServiceProtocol) {
        self.door = door
        self.doorService = doorService
    }
    
    func loadPermissions() async {
        guard !isLoading && currentPage < totalPages else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await doorService.getPermissions(doorId: door.id, page: currentPage)
            permissions.append(contentsOf: response.content)
            totalPages = response.totalPages
            currentPage += 1
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func refresh() async {
        currentPage = 0
        totalPages = 1
        permissions = []
        await loadPermissions()
    }
    
    func deletePermission(at offsets: IndexSet) async {
        let indicesToDelete = Array(offsets)
        let permissionsToDelete = indicesToDelete.map { permissions[$0] }
        
        for permission in permissionsToDelete {
            do {
                try await doorService.deletePermission(doorId: door.id, permissionId: permission.id)
            } catch {
                errorMessage = error.localizedDescription
                return
            }
        }
        
        permissions.remove(atOffsets: offsets)
    }
    
    func createPermission(request: PermissionCreateRequest) async -> Bool {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            let newPermission = try await doorService.createPermission(doorId: door.id, request: request)
            permissions.insert(newPermission, at: 0)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
    
    func updatePermission(permissionId: Int, request: PermissionUpdateRequest) async -> Bool {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            let updatedPermission = try await doorService.updatePermission(doorId: door.id, permissionId: permissionId, request: request)
            if let index = permissions.firstIndex(where: { $0.id == permissionId }) {
                permissions[index] = updatedPermission
            }
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}