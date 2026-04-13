import SwiftUI

struct DoorEventsListView: View {
    @StateObject var viewModel: DoorEventsViewModel
    
    var body: some View {
        List {
            ForEach(viewModel.events) { event in
                VStack(alignment: .leading, spacing: 4) {
                    Text(event.logType)
                        .font(.headline)
                    
                    if let date = formattedDate(from: event.eventTimestamp) {
                        Text(date)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    } else {
                        Text(event.eventTimestamp)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    if !event.additionalData.isEmpty {
                        VStack(alignment: .leading, spacing: 2) {
                            ForEach(event.additionalData, id: \.parameterName) { data in
                                Text("\(data.parameterName): \(data.parsedValue ?? data.hexValue ?? "")")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.top, 2)
                    }
                }
                .padding(.vertical, 4)
                .onAppear {
                    if event == viewModel.events.last {
                        Task { await viewModel.loadEvents() }
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
        .overlay(Group {
            if viewModel.events.isEmpty && !viewModel.isLoading {
                EmptyStateView(
                    iconName: "list.bullet.clipboard",
                    title: "No Events",
                    message: "There are no events recorded for this door yet."
                )
            }
        })
        .listStyle(PlainListStyle())
        .navigationTitle(viewModel.door.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: DoorsFactory.makePermissionsListView(for: viewModel.door)) {
                    Image(systemName: "key.fill")
                }
            }
        }
        .task {
            if viewModel.events.isEmpty {
                await viewModel.loadEvents()
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
    
    private func formattedDate(from string: String) -> String? {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        var date = isoFormatter.date(from: string)
        
        if date == nil {
            isoFormatter.formatOptions = [.withInternetDateTime]
            date = isoFormatter.date(from: string)
        }
        
        // Also handling simple format without TimeZone 
        if date == nil {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            date = formatter.date(from: string)
        }
        
        guard let d = date else { return nil }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: d)
    }
}