import SwiftUI
import SwiftData

struct TaskComposer: View {
    let category: Category
    let count: Int
    let onDismiss: () -> Void
    let onFocusReady: () -> Void
    @Environment(\.modelContext) private var context
    @State private var text = ""
    @State private var dueDate = Date.now
    @State private var showingDatePicker = false
    @State private var saveError: String?
    @FocusState private var focused: Bool

    private var title: String { text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }

    var body: some View {
        VStack(spacing: 0) {
            TaskCategoryHeader(category: category, count: count)
                .padding(.horizontal, 14)
                .padding(.top, 4)
            Divider().overlay(HandyTheme.ink.opacity(0.08))
            VStack(spacing: 8) {
                HStack(spacing: 10) {
                    HandySymbol(.add, size: 22)
                        .foregroundStyle(category.color)
                    TextField("add a task…", text: $text)
                        .font(.handWritten(20))
                        .textInputAutocapitalization(.never)
                        .onChange(of: text) { _, value in
                            if value != value.lowercased() { text = value.lowercased() }
                        }
                        .focused($focused)
                        .submitLabel(.done)
                        .onSubmit(createTask)
                        .accessibilityLabel("new \(category.rawValue.lowercased()) task")
                    Button(action: createTask) {
                        HandySymbol(.completed, size: 28)
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                    .disabled(title.isEmpty)
                    .accessibilityLabel("save new \(category.rawValue.lowercased()) task")
                }
                HStack(spacing: 8) {
                    HandySymbol(.calendar, size: 18)
                    Text("due").font(.handWritten(14))
                    Spacer(minLength: 4)
                    Button {
                        focused = false
                        showingDatePicker = true
                    } label: {
                        Text(dueDate.formatted(.dateTime.day().month(.abbreviated).hour().minute()).lowercased())
                            .font(.handWritten(14))
                            .padding(.horizontal, 10)
                            .frame(minHeight: 44)
                            .background(HandyTheme.paper, in: RoundedRectangle(cornerRadius: 8))
                    }
                    .accessibilityLabel("due date for new \(category.rawValue.lowercased()) task")
                    .popover(isPresented: $showingDatePicker, arrowEdge: .bottom) {
                        DatePicker("due", selection: $dueDate)
                            .datePickerStyle(.graphical)
                            .labelsHidden()
                            .frame(width: 320)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(12)
                            .presentationCompactAdaptation(.sheet)
                            .presentationDetents([.height(440)])
                            .presentationDragIndicator(.visible)
                            .background(HandyTheme.paper)
                            .presentationBackground(HandyTheme.paper)
                    }
                }
                if let saveError {
                    Text(saveError.lowercased())
                        .font(.handWritten(14))
                        .foregroundStyle(HandyTheme.accent)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
        }
        .buttonStyle(.plain)
        .foregroundStyle(HandyTheme.ink)
        .tint(category.color)
        .background(HandyTheme.card, in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 24, y: 8)
        .accessibilityAddTraits(.isModal)
        .accessibilityAction(.escape, onDismiss)
        .task {
            focused = true
            // Hardware and floating keyboards may not announce a docked frame.
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled else { return }
            onFocusReady()
        }
        .onChange(of: showingDatePicker) { _, showing in
            if !showing { focused = true }
        }
    }

    private func createTask() {
        guard !title.isEmpty else { return }
        context.insert(TodoItem(text: title, date: dueDate, category: category.rawValue))
        do {
            try context.save()
            focused = false
            onDismiss()
        } catch {
            context.rollback()
            saveError = "couldn't save your task. \(error.localizedDescription)"
        }
    }
}
