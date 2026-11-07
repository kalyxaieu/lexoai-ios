import Foundation
import Supabase

@MainActor
final class ChatStore: ObservableObject {
    @Published var conversations: [Conversation] = []
    @Published var messages: [ChatMessage] = []
    @Published var selectedConversationID: String?
    @Published var isSending = false
    @Published var errorMessage: String?

    private let app: AppModel
    private var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }

    init(app: AppModel) { self.app = app }

    func refreshConversations() async {
        guard let userID = app.userID else { return }
        do {
            let rows: [Conversation] = try await app.client
                .from("conversations")
                .select()
                .eq("user_id", value: userID)
                .order("updated_at", ascending: false)
                .execute()
                .value
            conversations = rows
            if let selectedConversationID,
               !rows.contains(where: { $0.id == selectedConversationID }) {
                self.selectedConversationID = nil
                messages = []
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func newConversation() {
        selectedConversationID = nil
        messages = []
        errorMessage = nil
    }

    func selectConversation(_ id: String) async {
        selectedConversationID = id
        errorMessage = nil
        do {
            let response: HistoryResponse = try await app.client.functions.invoke(
                "lexo-ai",
                options: FunctionInvokeOptions(body: [
                    "action": "history",
                    "conversationId": id
                ])
            )
            messages = response.messages
        } catch {
            errorMessage = "Impossible de charger cette conversation : \(error.localizedDescription)"
        }
    }

    func renameConversation(_ id: String, title: String) async {
        let clean = String(title.trimmingCharacters(in: .whitespacesAndNewlines).prefix(80))
        guard !clean.isEmpty else { return }
        do {
            try await app.client.from("conversations")
                .update(["title": clean, "updated_at": ISO8601DateFormatter().string(from: Date())])
                .eq("id", value: id)
                .execute()
            await refreshConversations()
        } catch { errorMessage = error.localizedDescription }
    }

    func deleteConversation(_ id: String) async {
        do {
            try await app.client.from("conversations").delete().eq("id", value: id).execute()
            if selectedConversationID == id { newConversation() }
            await refreshConversations()
        } catch { errorMessage = error.localizedDescription }
    }

    func send(_ rawText: String) async {
        let text = rawText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !isSending else { return }
        errorMessage = nil
        isSending = true
        let temporaryID = UUID().uuidString
        messages.append(ChatMessage(id: temporaryID, role: "user", content: text))
        let assistantID = UUID().uuidString
        messages.append(ChatMessage(id: assistantID, role: "assistant", content: ""))
        defer { isSending = false }

        do {
            let session = try await app.client.auth.session
            var request = URLRequest(url: SupabaseConfig.streamFunctionURL)
            request.httpMethod = "POST"
            request.timeoutInterval = 90
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue(SupabaseConfig.publishableKey, forHTTPHeaderField: "apikey")
            request.setValue("Bearer \(session.accessToken)", forHTTPHeaderField: "Authorization")
            var body: [String: Any] = ["action": "chat", "message": text]
            if let selectedConversationID { body["conversationId"] = selectedConversationID }
            request.httpBody = try JSONSerialization.data(withJSONObject: body)

            let (bytes, response) = try await URLSession.shared.bytes(for: request)
            guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
                throw AppError.server("Le serveur Lexo AI a refusé la requête.")
            }

            for try await line in bytes.lines {
                guard line.hasPrefix("data: ") else { continue }
                let json = String(line.dropFirst(6))
                guard let data = json.data(using: .utf8),
                      let event = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let type = event["type"] as? String else { continue }
                switch type {
                case "meta":
                    if let id = event["conversationId"] as? String {
                        selectedConversationID = id
                    }
                case "delta":
                    if let delta = event["text"] as? String,
                       let index = messages.firstIndex(where: { $0.id == assistantID }) {
                        messages[index].content += delta
                    }
                case "done":
                    if let answer = event["answer"] as? String,
                       let index = messages.firstIndex(where: { $0.id == assistantID }),
                       messages[index].content.isEmpty {
                        messages[index].content = answer
                    }
                case "error":
                    throw AppError.server(event["message"] as? String ?? "Réponse indisponible.")
                default: break
                }
            }
            await refreshConversations()
        } catch {
            messages.removeAll { $0.id == assistantID }
            errorMessage = error.localizedDescription
        }
    }
}