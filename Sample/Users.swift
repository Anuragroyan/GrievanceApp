//
//  Users.swift
//  Sample
//
//  Created by Dungeon_master on 28/06/25.
//

import Foundation
import FirebaseFirestoreSwift

struct Users: Identifiable, Codable {
    @DocumentID var id: String? // Firestore will manage this ID
    var name: String
    var number: String
    var email: String
    var date: Date
    var location: String
    var grievanceContent: String
    var resolution: String
    var types: [String]
    var status: Bool // ✅ true = Resolved, false = Pending
}
