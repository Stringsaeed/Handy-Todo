//
//  HandyTodoApp.swift
//  HandyTodo
//
//  Created by Muhammed Saeed on 24/04/2023.
//

import SwiftUI

@main
struct HandyTodoApp: App {
    let persistenceController = PersistenceController.shared
    
    init() {
        
        /// setup font for UI components
        UINavigationBar.appearance().largeTitleTextAttributes = [
            .font: UIFont(name: "Edu QLD Beginner", size: 34.0)!
        ]
        
        UINavigationBar.appearance().titleTextAttributes = [
            .font: UIFont(name: "Edu QLD Beginner", size: 17.0)!
        ]
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
