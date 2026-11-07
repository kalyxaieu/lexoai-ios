import Foundation

struct Conversation: Decodable, Identifiable, Hashable {
    let id: String
    var title: String
}

struct ChatMessage: Identifiable, Decodable, Hashable {
    var id: String
    var role: String
    var content: String

    var isUser: Bool { role == "user" }
}

struct HistoryResponse: Decodable {
    let messages: [ChatMessage]
}
