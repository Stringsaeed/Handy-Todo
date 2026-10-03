import Foundation
import SwiftData

@MainActor
enum HandyPersistence {
    static func makeContainer() throws -> ModelContainer {
        let directory = try FileManager.default.url(for: .applicationSupportDirectory,
                                                   in: .userDomainMask,
                                                   appropriateFor: nil, create: true)
        // Reuse the original store, including its task IDs and CloudKit metadata.
        let configuration = ModelConfiguration(
            "HandyTodo", schema: Schema([TodoItem.self]),
            url: directory.appendingPathComponent("HandyTodo.sqlite"),
            cloudKitDatabase: .private("iCloud.com.stringsaeed.handy.todo")
        )
        return try ModelContainer(for: TodoItem.self, configurations: configuration)
    }
}
