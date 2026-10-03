import Foundation
import SwiftData

@Model
final class TodoItem {
    // Keep the names and optional types aligned with the original Core Data entity.
    var category: String?
    var date: Date?
    var id: UUID?
    var isFinished: Bool?
    var text: String?
    var timestamp: Date?

    var isCompleted: Bool {
        get { isFinished ?? false }
        set { isFinished = newValue }
    }

    init(text: String, date: Date, category: String) {
        self.id = UUID()
        self.text = text
        self.date = date
        self.category = category
        self.timestamp = .now
        self.isFinished = false
    }
}
