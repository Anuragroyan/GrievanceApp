//
//  UserFormVie.swift
//  Sample
//
//  Created by Dungeon_master on 28/06/25.
//

import SwiftUI

struct UserFormView: View {
    @Environment(\.presentationMode) var presentationMode

    @State var user: Users
    let isEditMode: Bool
    let onSave: () -> Void

    @State private var showAlert = false
    @State private var alertMessage = ""

    private let predefinedTypes = ["Electricity", "Water", "Road", "Sanitation", "Other"]
    @State private var selectedTypes: [String] = []

    private let userService = UserService()

    var body: some View {
        Form {
            Section(header: Text("User Info")) {
                TextField("Name", text: $user.name)
                TextField("Email", text: $user.email)
                TextField("Phone Number", text: $user.number)
                    .keyboardType(.phonePad)
                TextField("Location", text: $user.location)
            }

            Section(header: Text("Complaint")) {
                TextField("Complaint Description", text: $user.grievanceContent)
                TextField("Resolution", text: $user.resolution)
                Toggle("Status: Resolved?", isOn: $user.status)
            }

            Section(header: Text("Type of Issue")) {
                VStack(alignment: .leading) {
                    ForEach(predefinedTypes, id: \.self) { type in
                        Toggle(type, isOn: Binding(
                            get: { user.types.contains(type) },
                            set: { isOn in
                                if isOn {
                                    user.types.append(type)
                                } else {
                                    user.types.removeAll { $0 == type }
                                }
                            }
                        ))
                    }
                }
            }

            Button(isEditMode ? "Update" : "Save") {
                if validateFields() {
                    if isEditMode {
                        userService.updateUser(user) { error in
                            if error == nil {
                                onSave()
                                presentationMode.wrappedValue.dismiss()
                            } else {
                                alertMessage = "Update failed: \(error?.localizedDescription ?? "")"
                                showAlert = true
                            }
                        }
                    } else {
                        userService.addUser(user) { error in
                            if error == nil {
                                onSave()
                                presentationMode.wrappedValue.dismiss()
                            } else {
                                alertMessage = "Save failed: \(error?.localizedDescription ?? "")"
                                showAlert = true
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(isEditMode ? "Edit Complaint" : "New Complaint")
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Validation"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .onAppear {
            selectedTypes = user.types
        }
    }

    // ✅ Validation
    func validateFields() -> Bool {
        if user.name.trimmingCharacters(in: .whitespaces).isEmpty {
            alertMessage = "Name cannot be empty"
            showAlert = true
            return false
        }
        if user.email.trimmingCharacters(in: .whitespaces).isEmpty {
            alertMessage = "Email cannot be empty"
            showAlert = true
            return false
        }
        if user.number.trimmingCharacters(in: .whitespaces).isEmpty {
            alertMessage = "Phone number cannot be empty"
            showAlert = true
            return false
        }
        if user.location.trimmingCharacters(in: .whitespaces).isEmpty {
            alertMessage = "Location cannot be empty"
            showAlert = true
            return false
        }
        if user.grievanceContent.trimmingCharacters(in: .whitespaces).isEmpty {
            alertMessage = "Complaint description cannot be empty"
            showAlert = true
            return false
        }
        if user.types.isEmpty {
            alertMessage = "Please select at least one type"
            showAlert = true
            return false
        }
        return true
    }
}
