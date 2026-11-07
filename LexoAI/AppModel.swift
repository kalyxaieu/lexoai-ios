import Foundation
import Supabase

@MainActor
final class AppModel: ObservableObject {
    let client = SupabaseClient(
        supabaseURL: SupabaseConfig.projectURL,
        supabaseKey: SupabaseConfig.publishableKey
    )

    @Published private(set) var isAuthenticated = false
    @Published private(set) var userID: String?
    @Published private(set) var email: String?
    @Published var isBusy = false
    @Published var authError: String?
    @Published var authNotice: String?
    @Published var displayName = "Utilisateur"
    @Published var preferredName = ""

    init() {
        Task { await restoreSession() }
    }

    func restoreSession() async {
        do {
            let session = try await client.auth.session
            userID = session.user.id.uuidString
            email = session.user.email
            isAuthenticated = true
            await loadProfile()
        } catch {
            isAuthenticated = false
            userID = nil
            email = nil
        }
    }

    func signIn(email: String, password: String) async {
        authError = nil
        authNotice = nil
        isBusy = true
        defer { isBusy = false }
        do {
            try await client.auth.signIn(email: email.trimmingCharacters(in: .whitespacesAndNewlines), password: password)
            await restoreSession()
        } catch {
            authError = error.localizedDescription
        }
    }

    func signUp(email: String, password: String, birthDate: String, name: String, aiName: String, termsAccepted: Bool) async {
        authError = nil
        authNotice = nil
        guard termsAccepted else {
            authError = "Tu dois accepter les conditions d'utilisation."
            return
        }
        isBusy = true
        defer { isBusy = false }
        do {
            var request = URLRequest(url: SupabaseConfig.signupFunctionURL)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue(SupabaseConfig.publishableKey, forHTTPHeaderField: "apikey")
            request.httpBody = try JSONSerialization.data(withJSONObject: [
                "email": email.trimmingCharacters(in: .whitespacesAndNewlines),
                "password": password,
                "birthDate": birthDate,
                "displayName": name,
                "preferredName": aiName,
                "termsAccepted": true
            ])
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse else { throw URLError(.badServerResponse) }
            let payload = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any] ?? [:]
            guard (200...299).contains(http.statusCode) else {
                throw AppError.server(payload["error"] as? String ?? "Inscription impossible.")
            }
            if let session = payload["session"] as? [String: Any],
               let access = session["access_token"] as? String,
               let refresh = session["refresh_token"] as? String {
                try await client.auth.setSession(accessToken: access, refreshToken: refresh)
                await restoreSession()
            } else {
                authNotice = "Compte créé. Vérifie ton e-mail pour confirmer l'inscription, puis connecte-toi."
            }
        } catch {
            authError = error.localizedDescription
        }
    }

    func signInWithGoogle() async {
        authError = nil
        isBusy = true
        defer { isBusy = false }
        do {
            _ = try await client.auth.signInWithOAuth(provider: .google)
            await restoreSession()
        } catch {
            authError = error.localizedDescription
        }
    }

    func signOut() async {
        do { try await client.auth.signOut() } catch { authError = error.localizedDescription }
        isAuthenticated = false
        userID = nil
        email = nil
    }

    func loadProfile() async {
        guard let userID else { return }
        do {
            let profile: ProfileRecord = try await client
                .from("profiles")
                .select()
                .eq("user_id", value: userID)
                .single()
                .execute()
                .value
            displayName = profile.displayName
            preferredName = profile.aiName ?? ""
        } catch {
            // A missing profile must not prevent access to chat.
        }
    }

    func saveProfile(displayName: String, preferredName: String) async {
        guard let userID else { return }
        do {
            try await client.from("profiles").upsert([
                "user_id": userID,
                "display_name": displayName,
                "ai_name": preferredName
            ]).execute()
            self.displayName = displayName
            self.preferredName = preferredName
        } catch {
            authError = error.localizedDescription
        }
    }
}

struct ProfileRecord: Decodable {
    let displayName: String
    let aiName: String?

    enum CodingKeys: String, CodingKey {
        case displayName = "display_name"
        case aiName = "ai_name"
    }
}

enum AppError: LocalizedError {
    case server(String)
    var errorDescription: String? {
        switch self {
        case .server(let message): return message
        }
    }
}