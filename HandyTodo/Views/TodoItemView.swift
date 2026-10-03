import SwiftUI

struct TodoItemView: View {
    let item: TodoItem

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            HandySymbol(item.isCompleted ? .completed : .circle, size: 25)
                .foregroundStyle(item.isCompleted ? HandyTheme.accent : HandyTheme.ink.opacity(0.35))
            VStack(alignment: .leading, spacing: 3) {
                Text((item.text ?? "untitled task").lowercased())
                    .font(.handWritten(20))
                    .strikethrough(item.isCompleted)
                    .foregroundStyle(HandyTheme.ink.opacity(item.isCompleted ? 0.45 : 1))
                    .fixedSize(horizontal: false, vertical: true)
                if let date = item.date {
                    Text(date.formatted(.dateTime.month(.abbreviated).day().hour().minute()).lowercased())
                        .font(.handWritten(13))
                        .foregroundStyle(HandyTheme.ink.opacity(0.5))
                }
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }
}
