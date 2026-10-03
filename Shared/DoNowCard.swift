import SwiftUI

struct DoNowCard: View {
    let title: String?
    let category: String?
    let onComplete: () -> Void
    let onShuffle: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title == nil ? "all clear" : "do now")
                    .font(.handWritten(14))
                    .foregroundStyle(HandyTheme.accent)
                Text(title?.lowercased() ?? "no unfinished tasks to pick")
                    .font(.handWritten(20))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                if let category {
                    Text(category.lowercased())
                        .font(.handWritten(13))
                        .foregroundStyle(HandyTheme.ink.opacity(0.6))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            if title != nil {
                Button(action: onComplete) { HandySymbol(.completed, size: 26).frame(width: 44, height: 44) }
                    .accessibilityLabel("complete the picked task")
                Button(action: onShuffle) { HandySymbol(.shuffle, size: 24).frame(width: 44, height: 44) }
                    .accessibilityLabel("pick another task")
            }
            Button(action: onDismiss) { HandySymbol(.close, size: 16).frame(width: 44, height: 44) }
                .accessibilityLabel("dismiss random pick")
        }
        .buttonStyle(.plain)
        .foregroundStyle(HandyTheme.ink)
        .padding(.leading, 14)
        .padding(.vertical, 8)
        .background(HandyTheme.card, in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(HandyTheme.accent.opacity(0.35)))
        .accessibilityElement(children: .contain)
    }
}
