import SwiftUI
import WidgetKit

struct HandyEntry: TimelineEntry {
    let date: Date
    let snapshot: WidgetSnapshot
}

struct HandyProvider: TimelineProvider {
    func placeholder(in context: Context) -> HandyEntry {
        HandyEntry(date: .now, snapshot: WidgetSnapshot(tasks: [
            WidgetTask(id: UUID().uuidString, title: "Make something good", category: "Primary", dueDate: nil),
            WidgetTask(id: UUID().uuidString, title: "Take a little walk", category: "Secondary", dueDate: nil)
        ], completedCount: 2))
    }
    func getSnapshot(in context: Context, completion: @escaping (HandyEntry) -> Void) {
        completion(context.isPreview ? placeholder(in: context) : HandyEntry(date: .now, snapshot: WidgetSnapshotStore.read()))
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<HandyEntry>) -> Void) {
        completion(Timeline(entries: [HandyEntry(date: .now, snapshot: WidgetSnapshotStore.read())],
                            policy: .after(Date.now.addingTimeInterval(1800))))
    }
}

struct HandyWidgetView: View {
    let entry: HandyEntry
    @Environment(\.widgetFamily) private var family
    private var isSmall: Bool { family == .systemSmall }

    var body: some View {
        VStack(alignment: .leading, spacing: isSmall ? 6 : 10) {
            HStack {
                Text(entry.date.formatted(.dateTime.month(.abbreviated).day()).lowercased()).font(.handWritten(16))
                Spacer(minLength: 4)
            }
            HStack(alignment: .firstTextBaseline, spacing: 5) {
                Text("\(entry.snapshot.tasks.count)").font(.handWritten(isSmall ? 24 : 28))
                    .foregroundStyle(HandyTheme.accent)
                Text(entry.snapshot.tasks.count == 1 ? "thing to do" : "things to do").font(.handWritten(16))
            }
            if entry.snapshot.tasks.isEmpty {
                Text("all clear. make room for a little you.")
                    .font(.handWritten(18))
            } else {
                ForEach(entry.snapshot.tasks.prefix(isSmall ? 1 : 4)) { task in
                    HStack(alignment: .top, spacing: 8) {
                        HandySymbol(.circle, size: 18)
                            .foregroundStyle(HandyTheme.accent)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(task.title.lowercased()).font(.handWritten(isSmall ? 17 : 20)).lineLimit(isSmall ? 2 : 1)
                            if !isSmall {
                                Text(task.category.lowercased()).font(.handWritten(13)).foregroundStyle(HandyTheme.ink.opacity(0.6))
                            }
                        }
                    }
                }
            }
            Spacer(minLength: 0)
            if !isSmall {
                Text("\(entry.snapshot.completedCount) finished · one thing at a time")
                    .font(.handWritten(15)).foregroundStyle(HandyTheme.ink.opacity(0.6))
            }
        }
        .foregroundStyle(HandyTheme.ink)
        .widgetURL(URL(string: "handy://tasks"))
        .modifier(WidgetPaperBackground())
    }
}

private struct WidgetPaperBackground: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            content.containerBackground(HandyTheme.paper, for: .widget)
        } else {
            content.padding(16).background(HandyTheme.paper)
        }
    }
}

@main
struct HandyWidgets: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: WidgetSnapshotStore.widgetKind, provider: HandyProvider()) { entry in
            HandyWidgetView(entry: entry)
        }
        .configurationDisplayName("handy")
        .description("your next task, or a little view of everything to do.")
        .supportedFamilies([.systemSmall, .systemLarge])
    }
}
