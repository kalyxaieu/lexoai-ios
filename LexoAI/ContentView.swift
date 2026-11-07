import SwiftUI

struct ContentView: View {
    @StateObject private var app = AppModel()
    @AppStorage("lexoThemeMode") private var themeMode = "system"

    var body: some View {
        Group {
            if app.isAuthenticated {
                ChatView(app: app)
            } else {
                AuthView(app: app)
            }
        }
        .preferredColorScheme(selectedScheme)
        .animation(.easeInOut(duration: 0.2), value: app.isAuthenticated)
    }

    private var selectedScheme: ColorScheme? {
        switch themeMode {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }
}