import FirebaseFirestore
import FirebaseFirestoreSwift

class UserService {
    private let db = Firestore.firestore()
    private let collection = "users"

    // MARK: - Validation
    private func isValidUser(_ user: Users) -> Bool {
        return !user.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               !user.number.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               !user.email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               !user.location.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               !user.grievanceContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               !user.types.isEmpty
    }

    // MARK: - Create
    func addUser(_ user: Users, completion: @escaping (Error?) -> Void) {
        guard isValidUser(user) else {
            let error = NSError(
                domain: "",
                code: 400,
                userInfo: [NSLocalizedDescriptionKey: "All fields must be filled before adding a user."]
            )
            completion(error)
            return
        }

        do {
            _ = try db.collection(collection).addDocument(from: user, completion: completion)
        } catch {
            completion(error)
        }
    }

    // MARK: - Read
    func fetchUsers(completion: @escaping ([Users]?, Error?) -> Void) {
        db.collection(collection).getDocuments { snapshot, error in
            if let error = error {
                completion(nil, error)
                return
            }

            let users = snapshot?.documents.compactMap {
                try? $0.data(as: Users.self)
            }

            completion(users, nil)
        }
    }

    // MARK: - Update
    func updateUser(_ user: Users, completion: @escaping (Error?) -> Void) {
        guard let id = user.id else {
            let error = NSError(
                domain: "",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Missing user ID for update."]
            )
            completion(error)
            return
        }

        guard isValidUser(user) else {
            let error = NSError(
                domain: "",
                code: 400,
                userInfo: [NSLocalizedDescriptionKey: "Cannot update user with empty fields."]
            )
            completion(error)
            return
        }

        do {
            try db.collection(collection).document(id).setData(from: user, merge: true, completion: completion)
        } catch {
            completion(error)
        }
    }

    // MARK: - Delete
    func deleteUser(_ user: Users, completion: @escaping (Error?) -> Void) {
        guard let id = user.id else {
            let error = NSError(
                domain: "",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Missing user ID for deletion."]
            )
            completion(error)
            return
        }

        db.collection(collection).document(id).delete(completion: completion)
    }
}

