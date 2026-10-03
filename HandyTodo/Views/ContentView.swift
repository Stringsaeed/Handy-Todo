import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var showingSettings = false
    @State private var showingRandomPick = false
    @State private var pickedTaskID: PersistentIdentifier?
    @State private var pickSaveError: String?
    @Environment(\.modelContext) private var context
    @Query(sort: \TodoItem.timestamp) private var items: [TodoItem]
    @Environment(\.scenePhase) private var scenePhase

    private var widgetSnapshot: WidgetSnapshot {
        WidgetSnapshot(tasks: Category.allCases.flatMap { category in
            items.filter { !$0.isCompleted && $0.category == category.rawValue }.map {
                WidgetTask(id: $0.id?.uuidString ?? String(describing: $0.persistentModelID),
                           title: $0.text ?? "Untitled task", category: category.rawValue, dueDate: $0.date)
            }
        }, completedCount: items.filter(\.isCompleted).count)
    }

    private var availableTasks: [TodoItem] { items.filter { !$0.isCompleted } }

    private var pickedTask: TodoItem? {
        availableTasks.first { $0.persistentModelID == pickedTaskID }
    }

    private var remaining: Int { items.filter { !$0.isCompleted }.count }

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                header
                if showingRandomPick {
                    DoNowCard(title: pickedTask?.text ?? (pickedTask == nil ? nil : "untitled task"),
                              category: pickedTask?.category,
                              onComplete: completePickedTask,
                              onShuffle: pickRandomTask,
                              onDismiss: { showingRandomPick = false; pickedTaskID = nil })
                        .padding(.horizontal, 16)
                        .padding(.bottom, 10)
                }
                let layout = geometry.size.width > 700
                    ? AnyLayout(HStackLayout(spacing: 10))
                    : AnyLayout(VStackLayout(spacing: 10))
                layout {
                    ForEach(Category.allCases, id: \.self) { category in
                        TodoCategoryView(category: category)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            }
            .foregroundStyle(HandyTheme.ink)
        }
        .background(HandyTheme.paper.ignoresSafeArea())
        .alert("couldn't complete task", isPresented: Binding(
            get: { pickSaveError != nil }, set: { if !$0 { pickSaveError = nil } }
        )) { Button("ok", role: .cancel) { pickSaveError = nil } }
        message: { Text((pickSaveError ?? "please try again.").lowercased()) }
        .onAppear { WidgetSnapshotPublisher.publish(widgetSnapshot) }
        .onChange(of: widgetSnapshot) { _, snapshot in WidgetSnapshotPublisher.publish(snapshot) }
        .onChange(of: scenePhase) { _, _ in WidgetSnapshotPublisher.publish(widgetSnapshot) }
        .onChange(of: availableTasks.map(\.persistentModelID)) { _, ids in
            if let pickedTaskID, !ids.contains(pickedTaskID) {
                self.pickedTaskID = nil
                showingRandomPick = false
            }
        }
        .sheet(isPresented: $showingSettings) {
            if #available(iOS 17.0, *) {
                SettingsView().presentationBackground(HandyTheme.paper)
            } else {
                SettingsView()
            }
        }
    }

    private func pickRandomTask() {
        let pool = availableTasks.count > 1
            ? availableTasks.filter { $0.persistentModelID != pickedTaskID }
            : availableTasks
        pickedTaskID = pool.randomElement()?.persistentModelID
        showingRandomPick = true
    }

    private func completePickedTask() {
        guard let task = pickedTask else { return }
        task.isCompleted = true
        do {
            try context.save()
            showingRandomPick = false
            pickedTaskID = nil
            TaskFeedback.play(.completion)
        } catch {
            context.rollback()
            pickSaveError = error.localizedDescription
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            Text(Date.now.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day()).lowercased())
                .font(.handWritten(20))
            Spacer(minLength: 4)
            Text("\(remaining) to do")
                .font(.handWritten(18))
                .foregroundStyle(HandyTheme.accent)
            Button(action: pickRandomTask) {
                HandySymbol(.shuffle, size: 24).frame(width: 44, height: 44)
            }
            .accessibilityLabel("pick a random task")
            .accessibilityHint("chooses an unfinished task to do now")
            Button { showingSettings = true } label: {
                HandySymbol(.settings, size: 24)
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel("settings")
        }
        .padding(.leading, 20)
        .padding(.trailing, 8)
        .padding(.vertical, 4)
    }
}
