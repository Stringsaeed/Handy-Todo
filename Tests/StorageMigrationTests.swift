import CoreData
import Foundation
import SwiftData

struct TaskRecord: Equatable {
    let id: UUID?
    let text: String?
    let category: String?
    let finished: Bool?
    let date: Date?
    let timestamp: Date?

    init(_ item: TodoItem) {
        id = item.id; text = item.text; category = item.category
        finished = item.isFinished; date = item.date; timestamp = item.timestamp
    }

    init(id: UUID?, text: String?, category: String?, finished: Bool?, date: Date?, timestamp: Date?) {
        self.id = id; self.text = text; self.category = category
        self.finished = finished; self.date = date; self.timestamp = timestamp
    }
}

@main
struct StorageMigrationTests {
    @MainActor
    static func main() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }
        let store = root.appendingPathComponent("HandyTodo.sqlite")
        let expected = [
            TaskRecord(id: UUID(uuidString: "00000000-0000-0000-0000-000000000001"), text: "Same title",
                       category: "Primary", finished: false, date: Date(timeIntervalSince1970: 1700000000),
                       timestamp: Date(timeIntervalSince1970: 1699990000)),
            TaskRecord(id: UUID(uuidString: "00000000-0000-0000-0000-000000000002"), text: "Same title",
                       category: "Secondary", finished: true, date: nil, timestamp: nil),
            TaskRecord(id: UUID(uuidString: "00000000-0000-0000-0000-000000000003"), text: "Read كتاب",
                       category: "Tertiary", finished: false, date: nil, timestamp: nil),
            TaskRecord(id: nil, text: nil, category: nil, finished: nil, date: nil, timestamp: nil)
        ]
        try seedLegacyStore(store, modelURL: URL(fileURLWithPath: CommandLine.arguments[1]), records: expected)
        for _ in 0..<2 {
            try withStore(store) { context in
                let migrated = try context.fetch(FetchDescriptor<TodoItem>()).map(TaskRecord.init)
                precondition(migrated.count == expected.count, "Upgrade changed the task count")
                precondition(expected.allSatisfy(migrated.contains), "Upgrade changed task fields")
            }
        }
        let addedID = UUID()
        try withStore(store) { context in
            let primaryName = "Primary"
            let descriptor = FetchDescriptor<TodoItem>(predicate: #Predicate { $0.category == primaryName })
            let primary = try context.fetch(descriptor)
            precondition(primary.count == 1, "Priority query lost a task")
            primary[0].isCompleted = true
            let secondaryName = "Secondary"
            let secondary = try context.fetch(FetchDescriptor<TodoItem>(predicate: #Predicate { $0.category == secondaryName }))
            context.delete(secondary[0])
            let newTask = TodoItem(text: "New SwiftData task", date: .now, category: "Primary")
            newTask.id = addedID
            context.insert(newTask)
            try context.save()
        }
        try withStore(store) { context in
            let tasks = try context.fetch(FetchDescriptor<TodoItem>())
            precondition(tasks.count == 4, "Changes didn't persist across reopening")
            precondition(tasks.first { $0.id == expected[0].id }?.isCompleted == true)
            precondition(!tasks.contains { $0.id == expected[1].id })
            precondition(tasks.first { $0.id == addedID }?.text == "New SwiftData task")
            let task = tasks.first { $0.id == expected[0].id }!
            task.isCompleted = false
            try context.save()
        }
        try withStore(store) { context in
            let reopened = try context.fetch(FetchDescriptor<TodoItem>())
            precondition(reopened.first { $0.id == expected[0].id }?.isCompleted == false)
        }
        print("PASS: Legacy fields, IDs, duplicate titles and nulls survived two upgrades; priority queries, add, complete, undo and delete persisted.")
    }

    @MainActor
    static func withStore(_ url: URL, body: (ModelContext) throws -> Void) throws {
        try autoreleasepool {
            let config = ModelConfiguration("HandyTodo", schema: Schema([TodoItem.self]), url: url, cloudKitDatabase: .none)
            let container = try ModelContainer(for: TodoItem.self, configurations: config)
            let context = ModelContext(container)
            context.autosaveEnabled = false
            try body(context)
        }
    }

    static func seedLegacyStore(_ url: URL, modelURL: URL, records: [TaskRecord]) throws {
        try autoreleasepool {
            let model = NSManagedObjectModel(contentsOf: modelURL)!
            let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
            let store = try coordinator.addPersistentStore(type: .sqlite, at: url, options: [NSPersistentHistoryTrackingKey: true])
            let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            context.persistentStoreCoordinator = coordinator
            for record in records {
                let task = NSManagedObject(entity: model.entitiesByName["TodoItem"]!, insertInto: context)
                task.setValue(record.id, forKey: "id")
                task.setValue(record.text, forKey: "text")
                task.setValue(record.category, forKey: "category")
                task.setValue(record.finished, forKey: "isFinished")
                task.setValue(record.date, forKey: "date")
                task.setValue(record.timestamp, forKey: "timestamp")
            }
            try context.save()
            try coordinator.remove(store)
        }
    }
}
