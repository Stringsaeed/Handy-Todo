import SwiftUI

extension Font {
    static func handWritten(_ size: CGFloat = 16) -> Font {
        .custom("Oregano-Regular", size: size, relativeTo: .body)
    }
}

extension View {
    /// An inline navigation title drawn in handy's typeface. The system title ignores
    /// custom fonts once a view styles its toolbar, so the visible title is a principal
    /// toolbar item while `navigationTitle` keeps the title for accessibility.
    func handyNavigationTitle(_ title: String) -> some View {
        navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(title)
                        .font(.handWritten(20))
                        .foregroundStyle(HandyTheme.ink)
                        .accessibilityAddTraits(.isHeader)
                }
            }
    }
}

enum HandyTheme {
    static let paper = Color("Paper")
    static let ink = Color("Ink")
    static let accent = Color("HandyAccent")
    static let card = Color("Card")
}
