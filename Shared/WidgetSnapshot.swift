import Foundation

struct WidgetTask: Codable, Identifiable, Equatable {
    let id: String
    let title: String
    let category: String
    let dueDate: Date?
}

struct WidgetSnapshot: Codable, Equatable {
    var tasks: [WidgetTask]
    var completedCount: Int
    static let empty = WidgetSnapshot(tasks: [], completedCount: 0)
}

enum WidgetSnapshotStore {
    static let groupID = "group.com.stringsaeed.handy.todo"
    static let widgetKind = "HandyTasks"
    static let key = "taskSnapshot"

    static func read() -> WidgetSnapshot {
        guard let data = UserDefaults(suiteName: groupID)?.data(forKey: key),
              let snapshot = try? JSONDecoder().decode(WidgetSnapshot.self, from: data) else { return .empty }
        return snapshot
    }

    static func write(_ snapshot: WidgetSnapshot) throws {
        let data = try JSONEncoder().encode(snapshot)
        UserDefaults(suiteName: groupID)?.set(data, forKey: key)
    }
}
