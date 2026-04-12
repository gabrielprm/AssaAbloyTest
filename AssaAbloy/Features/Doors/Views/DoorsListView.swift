import SwiftUI

struct DoorsListView: View {
    @StateObject var viewModel: DoorsViewModel
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.doors) { door in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(door.name).font(.headline)
                        Text(door.address).font(.subheadline).foregroundColor(.gray)
                        Text("Battery: \(door.battery)%").font(.caption).foregroundColor(door.battery < 20 ? .red : .green)
                    }
                    .padding(.vertical, 4)
                    .onAppear {
                        if door == viewModel.doors.last {
                            Task { await viewModel.loadDoors() }
                        }
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
            .listStyle(PlainListStyle())
            .navigationTitle("Doors")
            .searchable(text: $viewModel.searchText, prompt: "Search doors...")
            .task {
                if viewModel.doors.isEmpty {
                    await viewModel.loadDoors()
                }
            }
            .refreshable {
                await viewModel.refresh()
            }
            .alert(isPresented: Binding<Bool>(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Alert(title: Text("Error"), message: Text(viewModel.errorMessage ?? ""), dismissButton: .default(Text("OK")))
            }
        }
    }
}
