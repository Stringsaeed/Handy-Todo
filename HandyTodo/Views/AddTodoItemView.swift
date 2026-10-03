import SwiftUI

struct InlineTaskEntry: View {
    let category: Category
    var onAdd: (String, Date) -> Bool
    @State private var text = ""
    @State private var dueDate = Date.now
    @FocusState private var focused: Bool
    @State private var showingDatePicker = false
    @State private var startedDraft = false

    private var title: String { text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
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
                if focused || !text.isEmpty || showingDatePicker {
                    Button(action: createTask) {
                        HandySymbol(.completed, size: 28)
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.borderless)
                    .disabled(title.isEmpty)
                    .accessibilityLabel("add \(category.rawValue.lowercased()) task")
                }
            }
            .frame(minHeight: 44)
            if focused || !text.isEmpty || showingDatePicker {
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
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .background(HandyTheme.paper, in: RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(.borderless)
                    .accessibilityLabel("due date for new \(category.rawValue.lowercased()) task")
                    .popover(isPresented: $showingDatePicker, arrowEdge: .top) {
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
                .padding(.bottom, 6)
            }
        }
        .foregroundStyle(HandyTheme.ink)
        .onChange(of: focused) { _, isFocused in
            if isFocused && !startedDraft {
                dueDate = .now
                startedDraft = true
            }
        }
    }

    private func createTask() {
        guard !title.isEmpty, onAdd(title, dueDate) else { return }
        text = ""
        dueDate = .now
        focused = false
        startedDraft = false
    }
}
