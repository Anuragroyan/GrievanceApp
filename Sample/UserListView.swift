import SwiftUI

struct UserListView: View {
    @State private var users: [Users] = []
    @State private var filteredUsers: [Users] = []
    @State private var searchText: String = ""
    @State private var showForm = false
    @State private var selectedUser: Users?

    let userService = UserService()

    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGray6).edgesIgnoringSafeArea(.all)

                VStack {
                    // 🔍 Search Bar
                    TextField("Search by name, email, or complaint", text: $searchText)
                        .padding(10)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)

                    // 📋 User List
                    List {
                        ForEach(filteredUsers) { user in
                            ZStack(alignment: .topTrailing) {
                                // 🧾 Card
                                VStack(alignment: .leading) {
                                    HStack(alignment: .top, spacing: 12) {
                                        Image(systemName: "person.crop.circle.fill")
                                            .resizable()
                                            .frame(width: 50, height: 50)
                                            .foregroundColor(.blue)

                                        VStack(alignment: .leading, spacing: 6) {
                                            Text(user.name)
                                                .font(.headline)

                                            Text(user.email)
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)

                                            if !user.grievanceContent.isEmpty {
                                                Text("📝 \(user.grievanceContent)")
                                                    .font(.footnote)
                                                    .foregroundColor(.gray)
                                            }

                                            if !user.types.isEmpty {
                                                VStack(alignment: .leading, spacing: 2) {
                                                    ForEach(user.types, id: \.self) { type in
                                                        Text("\(emojiForType(type)) \(type)")
                                                            .font(.footnote)
                                                            .bold()
                                                            .foregroundColor(.purple)
                                                    }
                                                }
                                            }
                                        }

                                        Spacer()
                                    }
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
                                .onTapGesture {
                                    selectedUser = user
                                    showForm = true
                                }

                                // 🎯 Status Badge
                                let status = user.status ? "Resolved" : "Pending"
                                let badgeColor = user.status ? Color.green : Color.orange

                                Text(status)
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.vertical, 4)
                                    .padding(.horizontal, 8)
                                    .background(badgeColor)
                                    .cornerRadius(10)
                                    .padding(8)
                            }
                            .listRowSeparator(.hidden)
                            // ✅ Swipe-to-delete for resolved complaints only
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                if user.status {
                                    Button(role: .destructive) {
                                        userService.deleteUser(user) { error in
                                            if error == nil {
                                                fetchUsers()
                                            }
                                        }
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Users")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        selectedUser = nil
                        showForm = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .onAppear(perform: fetchUsers)
            .sheet(isPresented: $showForm) {
                NavigationView {
                    UserFormView(
                        user: selectedUser ?? Users(
                            name: "", number: "", email: "", date: Date(),
                            location: "", grievanceContent: "", resolution: "",
                            types: [], status: false
                        ),
                        isEditMode: selectedUser != nil
                    ) {
                        fetchUsers()
                    }
                }
            }
            .onChange(of: searchText) { _ in
                filterUsers()
            }
        }
    }

    // MARK: - Emoji Mapping
    func emojiForType(_ type: String) -> String {
        switch type.lowercased() {
            case "electricity": return "💡"
            case "water": return "💧"
            case "road": return "🛣️"
            case "sanitation": return "🚽"
            case "other": return "📝"
            default: return "🏷️"
        }
    }

    // MARK: - Data Functions
    func fetchUsers() {
        userService.fetchUsers { fetched, error in
            if let fetched = fetched {
                users = fetched
                filterUsers()
            }
        }
    }

    func filterUsers() {
        filteredUsers = users.filter { user in
            (searchText.isEmpty ||
             user.name.localizedCaseInsensitiveContains(searchText) ||
             user.email.localizedCaseInsensitiveContains(searchText) ||
             user.grievanceContent.localizedCaseInsensitiveContains(searchText))
        }
    }
}

