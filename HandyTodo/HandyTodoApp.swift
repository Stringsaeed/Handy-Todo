import SwiftUI
import SwiftData

@main
struct HandyTodoApp: App {
    private let storage: Result<ModelContainer, Error>

    init() {
        storage = Result { try HandyPersistence.makeContainer() }
    }

    var body: some Scene {
        WindowGroup {
            Group {
                switch storage {
                case .success(let container):
                    ContentView().modelContainer(container)
                case .failure(let error):
                    ContentUnavailableView {
                        Label("couldn't open your tasks", systemImage: "externaldrive.badge.exclamationmark")
                    } description: {
                        Text("your task database has been kept. close handy and try again. \(error.localizedDescription.lowercased())")
                    }
                    .padding(24)
                    .background(HandyTheme.paper)
                }
            }
            .background(HandyTheme.paper.ignoresSafeArea())
            .font(.handWritten())
            .tint(HandyTheme.accent)
        }
    }
}
