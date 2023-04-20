//
//  HandyApp.swift
//  Handy
//
//  Created by Muhammed Saeed on 17/04/2023.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth

@main
struct HandyApp: App {
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    let auth = Auth.auth()
                    guard auth.currentUser == nil else { return }
                    auth.signInAnonymously()
                }
        }
    }
}
