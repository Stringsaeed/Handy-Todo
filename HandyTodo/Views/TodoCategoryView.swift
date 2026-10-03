import SwiftUI
import SwiftData

struct TodoCategoryView: View {
    let category: Category
    @State private var saveError: String?
    @Environment(\.modelContext) private var context
    @Query private var queriedItems: [TodoItem]

    private var items: [TodoItem] {
        queriedItems.filter { !$0.isCompleted } + queriedItems.filter(\.isCompleted)
    }

    init(category: Category) {
        self.category = category
        let categoryName = category.rawValue
        _queriedItems = Query(filter: #Predicate<TodoItem> { $0.category == categoryName },
                              sort: \TodoItem.timestamp)
    }

    var body: some View {
        VStack(spacing: 0) {
            categoryHeader
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
            Divider().overlay(HandyTheme.ink.opacity(0.08))
            InlineTaskEntry(category: category, onAdd: addTask)
                .padding(.horizontal, 12)
        }
        .background(HandyTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .alert("couldn't save your task", isPresented: Binding(
            get: { saveError != nil }, set: { if !$0 { saveError = nil } }
        )) { Button("ok", role: .cancel) { saveError = nil } }
        message: { Text((saveError ?? "please try again.").lowercased()) }
    }

    private var categoryHeader: some View {
        HStack(spacing: 8) {
            Text(category.number)
                .font(.handWritten(15))
                .frame(width: 24, height: 24)
                .background(category.color.opacity(0.15), in: Circle())
                .foregroundStyle(category.color)
            Text(category.rawValue.lowercased())
                .font(.handWritten(21))
            Spacer(minLength: 4)
            Text("\(items.filter { !$0.isCompleted }.count)")
                .font(.handWritten(16))
                .foregroundStyle(HandyTheme.ink.opacity(0.5))
        }
        .foregroundStyle(HandyTheme.ink)
        .padding(.horizontal, 12)
        .padding(.top, 8)
        .padding(.bottom, 4)
    }

    private func addTask(text: String, date: Date) -> Bool {
        context.insert(TodoItem(text: text, date: date, category: category.rawValue))
        return save()
    }

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
