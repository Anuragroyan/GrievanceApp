//
//  SampleApp.swift
//  Sample
//
//  Created by Dungeon_master on 28/06/25.
//

import SwiftUI
import Firebase


@main
struct SampleApp: App {
    init() {
           FirebaseApp.configure()
       }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
