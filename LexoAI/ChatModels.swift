import Foundation

struct Conversation: Decodable, Identifiable, Hashable {
    let id: String
    var title: String
    let updatedAt: Date?
    let lastUsedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id, title
        case updatedAt = "updated_at"
        case lastUsedAt = "last_used_at"
    }
}

struct ChatMessage: Identifiable, Decodable, Hashable {
    var id: String
    var role: String
    var content: String
    var createdAt: Date?

    var isUser: Bool { role == "user" }

    enum CodingKeys: String, CodingKey {
        case id, role, content
        case createdAt = "created_at"
    }
}

struct HistoryResponse: Decodable {
    let messages: [ChatMessage]
}