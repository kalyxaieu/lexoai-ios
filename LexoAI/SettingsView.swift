import SwiftUI

struct SettingsView: View {
    @ObservedObject var app: AppModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage("lexoThemeMode") private var themeMode = "system"
    @State private var displayName = ""
    @State private var aiName = ""
    @State private var saved = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Compte") {
                    LabeledContent("Adresse e-mail", value: app.email ?? "—")
                    TextField("Nom affiché", text: $displayName)
                    TextField("Nom utilisé par Lexo", text: $aiName)
                    Button("Enregistrer le profil") {
                        Task {
                            await app.saveProfile(displayName: displayName, preferredName: aiName)
                            saved = true
                        }
                    }
                    if saved { Text("Profil enregistré").font(.caption).foregroundStyle(.green) }
                }

                Section("Apparence") {
                    Picker("Thème", selection: $themeMode) {
                        Text("Système").tag("system")
                        Text("Clair").tag("light")
                        Text("Sombre").tag("dark")
                    }
                    .pickerStyle(.segmented)
                }

                Section("À propos") {
                    Label("Lexo AI", systemImage: "sparkles")
                    LabeledContent("Développé par", value: "Kalyx AI")
                    LabeledContent("Version", value: "1.0")
                }
            }
            .scrollContentBackground(.hidden)
            .background(LexoTheme.background(colorScheme))
            .navigationTitle("Paramètres")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Terminé") { dismiss() }
                }
            }
            .onAppear {
                displayName = app.displayName
                aiName = app.preferredName
            }
        }
    }
}