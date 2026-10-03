import SwiftUI

extension Font {
    static func handWritten(_ size: CGFloat = 16) -> Font {
        .custom("Oregano-Regular", size: size, relativeTo: .body)
    }
}

enum HandyTheme {
    static let paper = Color("Paper")
    static let ink = Color("Ink")
    static let accent = Color("HandyAccent")
    static let card = Color("Card")
}
