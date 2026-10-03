import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var showingSettings = false
    @State private var showingRandomPick = false
    @State private var pickedTaskID: PersistentIdentifier?
    @State private var pickSaveError: String?
    private enum ComposerPresentation {
        case closed
        case preparing(Category)
        case presented(Category)

        var category: Category? {
            switch self {
            case .closed: return nil
            case .preparing(let category), .presented(let category): return category
            }
        }

        var isPresented: Bool {
            if case .presented = self { return true }
            return false
        }
    }

    @State private var composerPresentation = ComposerPresentation.closed
    @State private var keyboardFrame = CGRect.null
    @State private var categoryFrames: [Category: CGRect] = [:]
    @State private var composerHeight: CGFloat = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
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

    private var composingCategory: Category? { composerPresentation.category }
    private var composerIsPresented: Bool { composerPresentation.isPresented }
    private var composerEasing: Animation {
        reduceMotion ? .easeOut(duration: 0.15) : .timingCurve(0.22, 0.8, 0.25, 1, duration: 0.38)
    }

    private var remaining: Int { items.filter { !$0.isCompleted }.count }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
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
                            TodoCategoryView(category: category, onAdd: { showComposer(category) })
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background {
                                    GeometryReader { card in
                                        Color.clear.preference(key: CategoryFrames.self,
                                                               value: [category: card.frame(in: .named("task-board"))])
                                    }
                                }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                }
                .foregroundStyle(HandyTheme.ink)
                .allowsHitTesting(composingCategory == nil)
                .accessibilityHidden(composingCategory != nil)
                if let category = composingCategory {
                    Button(action: dismissComposer) {
                        Color.black.opacity(composerIsPresented ? 0.24 : 0).ignoresSafeArea()
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("cancel new task")
                    .transition(.opacity)

                    TaskComposer(category: category,
                                 count: items.filter { !$0.isCompleted && $0.category == category.rawValue }.count,
                                 onDismiss: dismissComposer,
                                 onFocusReady: revealComposer)
                        .frame(maxWidth: 560)
                        .background {
                            GeometryReader { card in
                                Color.clear.preference(key: ComposerHeight.self, value: card.size.height)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, keyboardOverlap(in: geometry) + 12)
                        .offset(composerIsPresented || reduceMotion ? .zero : composerOrigin(category, in: geometry))
                        .opacity(composerIsPresented ? 1 : 0)
                        .allowsHitTesting(composerIsPresented)
                        .accessibilityHidden(!composerIsPresented)
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
            .coordinateSpace(name: "task-board")
        }
        .ignoresSafeArea(.keyboard)
        .onPreferenceChange(CategoryFrames.self) { categoryFrames = $0 }
        .onPreferenceChange(ComposerHeight.self) { height in
            composerHeight = height
            if height > 0, !keyboardFrame.isNull { revealComposer() }
        }
        .background(HandyTheme.paper.ignoresSafeArea())
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification)) { notification in
            updateKeyboard(notification)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { notification in
            updateKeyboard(notification, hiding: true)
        }
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

    private func showComposer(_ category: Category) {
        keyboardFrame = .null
        composerPresentation = .preparing(category)
    }

    private func revealComposer() {
        guard case .preparing(let category) = composerPresentation, composerHeight > 0 else { return }
        withAnimation(composerEasing) {
            composerPresentation = .presented(category)
        }
    }

    private func dismissComposer() {
        withAnimation(composerEasing) {
            composerPresentation = .closed
        }
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    private func composerOrigin(_ category: Category, in geometry: GeometryProxy) -> CGSize {
        guard let source = categoryFrames[category] else { return .zero }
        let destinationY = geometry.size.height - keyboardOverlap(in: geometry) - 12 - composerHeight / 2
        return CGSize(width: source.midX - geometry.size.width / 2,
                      height: source.midY - destinationY)
    }

    private func keyboardOverlap(in geometry: GeometryProxy) -> CGFloat {
        let bounds = geometry.frame(in: .global)
        guard !keyboardFrame.isNull, keyboardFrame.width >= bounds.width * 0.8 else { return 0 }
        return max(0, bounds.maxY - keyboardFrame.minY)
    }

    private func updateKeyboard(_ notification: Notification, hiding: Bool = false) {
        guard composingCategory != nil else { return }
        let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect ?? .null
        let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.25
        if case .preparing = composerPresentation {
            guard !hiding, !frame.isNull else { return }
            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) { keyboardFrame = hiding ? .null : frame }
            DispatchQueue.main.async { revealComposer() }
        } else {
            withAnimation(.timingCurve(0.22, 0.8, 0.25, 1, duration: duration)) {
                keyboardFrame = hiding ? .null : frame
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
        HStack(spacing: 4) {
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

private struct CategoryFrames: PreferenceKey {
    static var defaultValue: [Category: CGRect] { [:] }
    static func reduce(value: inout [Category: CGRect], nextValue: () -> [Category: CGRect]) {
        value.merge(nextValue(), uniquingKeysWith: { _, new in new })
    }
}

private struct ComposerHeight: PreferenceKey {
    static var defaultValue: CGFloat { 0 }
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}
