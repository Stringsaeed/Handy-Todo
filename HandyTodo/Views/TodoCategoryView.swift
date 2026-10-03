import SwiftUI
import SwiftData

struct TodoCategoryView: View {
    let category: Category
    let onAdd: () -> Void
    @State private var saveError: String?
    @Environment(\.modelContext) private var context
    @Query private var queriedItems: [TodoItem]

    private var items: [TodoItem] {
        queriedItems.filter { !$0.isCompleted } + queriedItems.filter(\.isCompleted)
    }

    init(category: Category, onAdd: @escaping () -> Void = {}) {
        self.onAdd = onAdd
        self.category = category
        let categoryName = category.rawValue
        _queriedItems = Query(filter: #Predicate<TodoItem> { $0.category == categoryName },
                              sort: \TodoItem.timestamp)
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                TaskCategoryHeader(category: category, count: unfinishedCount)
                Button(action: onAdd) {
                    HandySymbol(.add, size: 20)
                        .foregroundStyle(category.color)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("add a \(category.rawValue.lowercased()) task")
            }
            .padding(.leading, 12)
            .padding(.trailing, 4)
            List {
                ForEach(items, id: \.persistentModelID) { item in
                    Button {
                        let completing = !item.isCompleted
                        withAnimation(.spring(response: 0.35)) { item.isCompleted.toggle() }
                        if save() { TaskFeedback.play(completing ? .completion : .undo) }
                    } label: {
                        TodoItemView(item: item)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("\(item.isCompleted ? "mark incomplete" : "complete") \((item.text ?? "task").lowercased())")
                    .listRowInsets(EdgeInsets(top: 2, leading: 12, bottom: 2, trailing: 12))
                    .listRowBackground(HandyTheme.card)
                    .listRowSeparatorTint(HandyTheme.ink.opacity(0.1))
                    .swipeActions {
                        Button(role: .destructive) {
                            withAnimation { context.delete(item) }
                            if save() { TaskFeedback.play(.deletion) }
                        } label: { Label { Text("delete") } icon: { Image("HandyDelete").renderingMode(.template) } }
                    }
                }
            }
            .listStyle(.plain)
            .environment(\.defaultMinListRowHeight, 44)
            .scrollContentBackground(.hidden)
            .contentMargins(.vertical, 0, for: .scrollContent)
            .scrollDismissesKeyboard(.interactively)
            .frame(maxHeight: .infinity)
        }
        .background(HandyTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .alert("couldn't save your task", isPresented: Binding(
            get: { saveError != nil }, set: { if !$0 { saveError = nil } }
        )) { Button("ok", role: .cancel) { saveError = nil } }
        message: { Text((saveError ?? "please try again.").lowercased()) }
    }

    private var unfinishedCount: Int { queriedItems.filter { !$0.isCompleted }.count }

    private func save() -> Bool {
        do {
            try context.save()
            return true
        } catch {
            context.rollback()
            saveError = error.localizedDescription
            return false
        }
    }
}

struct TaskCategoryHeader: View {
    let category: Category
    let count: Int
    var body: some View {
        HStack(spacing: 8) {
            Text(category.number)
                .font(.handWritten(15))
                .frame(width: 24, height: 24)
                .background(category.color.opacity(0.15), in: Circle())
                .foregroundStyle(category.color)
            Text(category.rawValue.lowercased())
                .font(.handWritten(21))
            Spacer(minLength: 4)
            Text("\(count)")
                .font(.handWritten(16))
                .foregroundStyle(HandyTheme.ink.opacity(0.5))
        }
        .foregroundStyle(HandyTheme.ink)
        .frame(height: 44)
    }
}
