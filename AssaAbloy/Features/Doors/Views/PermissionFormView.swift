import SwiftUI

struct PermissionFormView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: PermissionsViewModel
    
    let permission: Permission?
    
    @State private var type: PermissionType = .smartphone
    @State private var value: String = ""
    @State private var startDateTime: Date = Date()
    @State private var endDateTime: Date = Date().addingTimeInterval(86400 * 30) // +30 days
    @State private var selectedDays: Set<Int> = Set(0...6)
    
    let daysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    var isEditMode: Bool { permission != nil }
    
    init(viewModel: PermissionsViewModel, permission: Permission?) {
        self.viewModel = viewModel
        self.permission = permission
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let backupFormatter = ISO8601DateFormatter()
        
        if let p = permission {
            _type = State(initialValue: p.type)
            _value = State(initialValue: p.value)
            
            if let start = formatter.date(from: p.startDateTime) ?? backupFormatter.date(from: p.startDateTime) {
                _startDateTime = State(initialValue: start)
            }
            if let end = formatter.date(from: p.endDateTime) ?? backupFormatter.date(from: p.endDateTime) {
                _endDateTime = State(initialValue: end)
            }
            
            var initialDays: Set<Int> = []
            for i in 0...6 {
                if (p.weekDays & (1 << i)) != 0 {
                    initialDays.insert(i)
                }
            }
            _selectedDays = State(initialValue: initialDays)
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Details")) {
                    Picker("Type", selection: $type) {
                        ForEach(PermissionType.allCases, id: \.self) { t in
                            Text(t.rawValue).tag(t)
                        }
                    }
                    .disabled(isEditMode)
                    
                    TextField("Value", text: $value)
                        .disabled(isEditMode)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                
                Section(header: Text("Schedule")) {
                    DatePicker("Start", selection: $startDateTime)
                    DatePicker("End", selection: $endDateTime)
                }
                
                Section(header: Text("Active Days")) {
                    ForEach(0..<7, id: \.self) { i in
                        Toggle(isOn: Binding(
                            get: { selectedDays.contains(i) },
                            set: { isSelected in
                                if isSelected {
                                    selectedDays.insert(i)
                                } else {
                                    selectedDays.remove(i)
                                }
                            }
                        )) {
                            Text(daysOfWeek[i])
                        }
                    }
                }
            }
            .navigationTitle(isEditMode ? "Edit Permission" : "New Permission")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    Task { await save() }
                }
                .disabled(selectedDays.isEmpty || value.isEmpty || startDateTime >= endDateTime)
            )
        }
    }
    
    private func save() async {
        let bitmask = selectedDays.reduce(0) { $0 | (1 << $1) }
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        
        let startStr = formatter.string(from: startDateTime)
        let endStr = FormatterHelper.formatDate(endDateTime)
        
        var success = false
        if isEditMode {
            let req = PermissionUpdateRequest(
                startDateTime: startStr,
                endDateTime: endStr,
                weekDays: bitmask
            )
            success = await viewModel.updatePermission(permissionId: permission!.id, request: req)
        } else {
            let req = PermissionCreateRequest(
                type: type,
                value: value,
                startDateTime: startStr,
                endDateTime: endStr,
                weekDays: bitmask
            )
            success = await viewModel.createPermission(request: req)
        }
        
        if success {
            presentationMode.wrappedValue.dismiss()
        }
    }
}

struct FormatterHelper {
    static func formatDate(_ date: Date) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.string(from: date)
    }
}
