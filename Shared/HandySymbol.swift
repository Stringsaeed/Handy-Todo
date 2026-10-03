import SwiftUI

struct HandySymbol: View {
    enum Kind: String {
        case shuffle = "HandyShuffle"
        case close = "HandyClose"
        case settings = "HandySettings"
        case delete = "HandyDelete"
        case add = "HandyAdd"
        case circle = "HandyCircle"
        case completed = "HandyCompleted"
        case sound = "HandySound"
        case muted = "HandyMuted"
        case feedback = "HandyFeedback"
        case calendar = "HandyCalendar"
    }

    let kind: Kind
    let size: CGFloat

    init(_ kind: Kind, size: CGFloat = 20) {
        self.kind = kind
        self.size = size
    }

    var body: some View {
        Image(kind.rawValue)
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .accessibilityHidden(true)
    }
}
