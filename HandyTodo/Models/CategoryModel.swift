import SwiftUI

enum Category: String, Codable, CaseIterable, Identifiable {
    var id: String { rawValue }
    case primary = "Primary", secondary = "Secondary", tertiary = "Tertiary"

    var number: String {
        switch self { case .primary: return "1"; case .secondary: return "2"; case .tertiary: return "3" }
    }
    var subtitle: String {
        switch self {
        case .primary: return "Make room for what matters"
        case .secondary: return "Next on your list"
        case .tertiary: return "Whenever you have a moment"
        }
    }
    var emptyMessage: String {
        switch self {
        case .primary: return "What's your one important thing?"
        case .secondary: return "A little space for what's next."
        case .tertiary: return "Keep the small things here."
        }
    }
    var color: Color {
        switch self {
        case .primary: return HandyTheme.accent
        case .secondary: return Color(red: 0.31, green: 0.47, blue: 0.37)
        case .tertiary: return Color(red: 0.43, green: 0.40, blue: 0.62)
        }
    }
    func getImageName() -> String { "\(number).circle" }
}
