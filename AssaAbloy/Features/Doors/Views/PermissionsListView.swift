import SwiftUI

struct PermissionsListView: View {
    @StateObject var viewModel: PermissionsViewModel
    @State private var showingAddForm = false
    @State private var selectedPermission: Permission?
    
    var body: some View {
        List {
            ForEach(viewModel.permissions) { permission in
                PermissionRowView(permission: permission)
                    .onAppear {
                        if permission == viewModel.permissions.last {
                            Task { await viewModel.loadPermissions() }
                        }
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            if let index = viewModel.permissions.firstIndex(where: { $0.id == permission.id }) {
                                Task { await viewModel.deletePermission(at: IndexSet(integer: index)) }
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        
                        Button {
                            selectedPermission = permission
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        .tint(.blue)
                    }
            }
            
            if viewModel.isLoading {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            }
        }
        .overlay(Group {
            if viewModel.permissions.isEmpty && !viewModel.isLoading {
                EmptyStateView(
                    iconName: "key.slash",
                    title: "No Permissions",
                    message: "There are no permissions assigned to this door."
                )
            }
        })
        .listStyle(PlainListStyle())
        .navigationTitle("Permissions")
        .task {
            if viewModel.permissions.isEmpty {
                await viewModel.loadPermissions()
            }
        }
        .refreshable {
            await viewModel.refresh()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddForm = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddForm) {
            PermissionFormView(viewModel: viewModel, permission: nil)
        }
        .sheet(item: $selectedPermission) { permission in
            PermissionFormView(viewModel: viewModel, permission: permission)
        }
        .alert(isPresented: Binding<Bool>(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Alert(title: Text("Error"), message: Text(viewModel.errorMessage ?? ""), dismissButton: .default(Text("OK")))
        }
    }
}

struct PermissionRowView: View {
    let permission: Permission
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(permission.type.rawValue).font(.headline)
                Spacer()
                Text("Days: \(permission.weekDays)").font(.caption).foregroundColor(.gray)
            }
            Text(permission.value).font(.subheadline)
            Text("\(formatDate(permission.startDateTime)) - \(formatDate(permission.endDateTime))")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
    
    private func formatDate(_ isoString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: isoString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .short
            displayFormatter.timeStyle = .short
            return displayFormatter.string(from: date)
        }
        
        let formatter2 = ISO8601DateFormatter()
        if let date = formatter2.date(from: isoString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .short
            displayFormatter.timeStyle = .short
            return displayFormatter.string(from: date)
        }
        return isoString
    }
}