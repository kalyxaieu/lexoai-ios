import SwiftUI

struct AuthView: View {
    @ObservedObject var app: AppModel
    @Environment(\.colorScheme) private var colorScheme
    @State private var isRegistering = false
    @State private var email = ""
    @State private var password = ""
    @State private var birthDate = Date()
    @State private var displayName = ""
    @State private var aiName = ""
    @State private var acceptedTerms = false
    @State private var showPassword = false

    var body: some View {
        ZStack {
            LinearGradient(colors: [
                LexoTheme.violet.opacity(colorScheme == .dark ? 0.22 : 0.13),
                LexoTheme.background(colorScheme),
                LexoTheme.background(colorScheme)
            ], startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 22) {
                    Spacer(minLength: 32)
                    LexoLogoView()
                        .resizable()
                        .scaledToFit()
                        .frame(width: 94, height: 94)
                        .clipShape(RoundedRectangle(cornerRadius: 25))
                        .shadow(color: LexoTheme.violet.opacity(0.22), radius: 22, y: 8)

                    VStack(spacing: 7) {
                        Text("LEXO AI")
                            .font(.system(size: 31, weight: .bold, design: .rounded))
                            .tracking(2)
                        Text(isRegistering ? "Crée ton compte Kalyx AI" : "Ton intelligence artificielle")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    VStack(spacing: 14) {
                        Button {
                            Task { await app.signInWithGoogle() }
                        } label: {
                            HStack(spacing: 11) {
                                Image(systemName: "g.circle.fill")
                                    .font(.title3)
                                    .foregroundStyle(.blue)
                                Text("Continuer avec Google").fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(Color.white)
                            .foregroundStyle(Color.black.opacity(0.85))
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                            .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.gray.opacity(0.22)))
                        }
                        .disabled(app.isBusy)

                        HStack(spacing: 12) {
                            Rectangle().fill(.secondary.opacity(0.25)).frame(height: 1)
                            Text("ou").font(.caption).foregroundStyle(.secondary)
                            Rectangle().fill(.secondary.opacity(0.25)).frame(height: 1)
                        }

                        field("Adresse e-mail", text: $email, icon: "envelope")
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                            .autocorrectionDisabled()

                        HStack {
                            Group {
                                if showPassword {
                                    TextField("Mot de passe", text: $password)
                                } else {
                                    SecureField("Mot de passe", text: $password)
                                }
                            }
                            Button { showPassword.toggle() } label: {
                                Image(systemName: showPassword ? "eye.slash" : "eye")
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.horizontal, 15)
                        .frame(height: 52)
                        .background(LexoTheme.background(colorScheme).opacity(0.75))
                        .clipShape(RoundedRectangle(cornerRadius: 15))

                        if isRegistering {
                            field("Nom affiché", text: $displayName, icon: "person")
                            field("Comment Lexo doit t'appeler ?", text: $aiName, icon: "sparkles")
                            DatePicker("Date de naissance", selection: $birthDate, in: ...Date(), displayedComponents: .date)
                                .datePickerStyle(.compact)
                                .padding(12)
                                .background(LexoTheme.background(colorScheme).opacity(0.75))
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                            Toggle(isOn: $acceptedTerms) {
                                Text("J'accepte les conditions d'utilisation et la politique de confidentialité.")
                                    .font(.caption)
                            }
                            .tint(LexoTheme.violet)
                        }

                        if let error = app.authError {
                            Text(error)
                                .font(.footnote)
                                .foregroundStyle(.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        if let notice = app.authNotice {
                            Text(notice)
                                .font(.footnote)
                                .foregroundStyle(.green)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        Button {
                            Task {
                                if isRegistering {
                                    let formatter = DateFormatter()
                                    formatter.dateFormat = "yyyy-MM-dd"
                                    await app.signUp(
                                        email: email, password: password,
                                        birthDate: formatter.string(from: birthDate),
                                        name: displayName, aiName: aiName,
                                        termsAccepted: acceptedTerms
                                    )
                                } else {
                                    await app.signIn(email: email, password: password)
                                }
                            }
                        } label: {
                            HStack {
                                if app.isBusy { ProgressView().tint(.white) }
                                Text(isRegistering ? "Créer mon compte" : "Se connecter")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(LexoTheme.violet)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .disabled(app.isBusy || email.isEmpty || password.isEmpty ||
                                  (isRegistering && (!acceptedTerms || displayName.isEmpty || aiName.isEmpty)))

                        Button(isRegistering ? "Déjà un compte ? Se connecter" : "Créer un compte") {
                            isRegistering.toggle()
                            app.authError = nil
                            app.authNotice = nil
                        }
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(LexoTheme.violet)
                    }
                    .padding(22)
                    .background(LexoTheme.surface(colorScheme).opacity(0.97))
                    .clipShape(RoundedRectangle(cornerRadius: 27))
                    .overlay(RoundedRectangle(cornerRadius: 27).stroke(.primary.opacity(0.06)))
                    .shadow(color: .black.opacity(colorScheme == .dark ? 0.18 : 0.06), radius: 24, y: 10)

                    Label("Connexion sécurisée par Kalyx AI", systemImage: "lock.shield")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("Propulsé par Kalyx AI")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                    Spacer(minLength: 28)
                }
                .frame(maxWidth: 480)
                .padding(.horizontal, 22)
                .frame(maxWidth: .infinity)
            }
        }
    }

    private func field(_ title: String, text: Binding<String>, icon: String) -> some View {
        HStack(spacing: 11) {
            Image(systemName: icon).foregroundStyle(.secondary)
            TextField(title, text: text)
        }
        .padding(.horizontal, 15)
        .frame(height: 52)
        .background(LexoTheme.background(colorScheme).opacity(0.75))
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}