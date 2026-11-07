import SwiftUI

enum LexoTheme {
    static let violet = Color(red: 0.36, green: 0.30, blue: 0.84)
    static let darkBackground = Color(red: 0.051, green: 0.051, blue: 0.071)
    static let darkSurface = Color(red: 0.082, green: 0.082, blue: 0.114)
    static let darkElevated = Color(red: 0.133, green: 0.133, blue: 0.176)
    static let lightBackground = Color(red: 0.976, green: 0.973, blue: 0.992)

    static func background(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? darkBackground : lightBackground
    }
    static func surface(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? darkSurface : .white
    }
}