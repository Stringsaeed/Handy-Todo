import WidgetKit
import OSLog

@MainActor
enum WidgetSnapshotPublisher {
    static func publish(_ snapshot: WidgetSnapshot) {
        guard snapshot != WidgetSnapshotStore.read() else { return }
        do {
            try WidgetSnapshotStore.write(snapshot)
            WidgetCenter.shared.reloadTimelines(ofKind: WidgetSnapshotStore.widgetKind)
        } catch {
            Logger(subsystem: "com.stringsaeed.handy.todo", category: "widgets")
                .error("Couldn't refresh widgets: \(error.localizedDescription, privacy: .public)")
        }
    }
}
