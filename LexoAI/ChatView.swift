import SwiftUI

struct ChatView: View {
    @ObservedObject var app: AppModel
    @StateObject private var store: ChatStore
    @Environment(\.colorScheme) private var colorScheme
    @State private var draft = ""
    @State private var showSidebar = false
    @State private var historySearch = ""
    @State private var renameTarget: Conversation?
    @State private var renameText = ""
    @FocusState private var composerFocused: Bool

    init(app: AppModel) {
        self.app = app
        _store = StateObject(wrappedValue: ChatStore(app: app))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                header
                if store.messages.isEmpty && store.selectedConversationID == nil {
                    welcome
                } else {
                    transcript
                }
                if let error = store.errorMessage {
                    Text(error).font(.caption).foregroundStyle(.red)
                        .padding(.horizontal, 16).padding(.bottom, 6)
                }
                composer
            }
            .background(LexoTheme.background(colorScheme))
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showSidebar) { sidebar }
            .alert("Renommer la conversation", isPresented: Binding(
                get: { renameTarget != nil },
                set: { if !$0 { renameTarget = nil } }
            )) {
                TextField("Nom de la conversation", text: $renameText)
                Button("Annuler", role: .cancel) { renameTarget = nil }
                Button("Enregistrer") {
                    if let item = renameTarget {
                        Task { await store.renameConversation(item.id, title: renameText) }
                    }
                    renameTarget = nil
                }
            }
            .task {
                await store.refreshConversations()
                while !Task.isCancelled {
                    try? await Task.sleep(nanoseconds: 45_000_000_000)
                    if !Task.isCancelled { await store.refreshConversations() }
                }
            }
        }
    }

    private var header: some View {
        HStack(spacing: 13) {
            Button { showSidebar = true } label: {
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 20, weight: .medium))
                    .frame(width: 42, height: 42)
                    .background(LexoTheme.surface(colorScheme))
                    .clipShape(RoundedRectangle(cornerRadius: 13))
            }
            LexoLogoView()
                .frame(width: 32, height: 32)
                .clipShape(RoundedRectangle(cornerRadius: 9))
            VStack(alignment: .leading, spacing: 1) {
                Text("Lexo AI").font(.headline.weight(.bold))
                Text("Kalyx AI").font(.caption2).foregroundStyle(.secondary)
            }
            Spacer()
            Button {
                store.newConversation()
                draft = ""
            } label: {
                Image(systemName: "square.and.pencil")
                    .font(.system(size: 18, weight: .medium))
                    .frame(width: 42, height: 42)
                    .background(LexoTheme.surface(colorScheme))
                    .clipShape(RoundedRectangle(cornerRadius: 13))
            }
        }
        .foregroundStyle(.primary)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(LexoTheme.background(colorScheme))
    }

    private var welcome: some View {
        VStack(spacing: 16) {
            Spacer()
            LexoLogoView().frame(width: 76, height: 76)
                .clipShape(RoundedRectangle(cornerRadius: 22))
            Text("Comment puis-je t'aider ?")
                .font(.system(size: 25, weight: .semibold, design: .rounded))
                .multilineTextAlignment(.center)
            Text("Pose une question, partage une idée ou commence un nouveau projet.")
                .font(.subheadline).foregroundStyle(.secondary)
                .multilineTextAlignment(.center).frame(maxWidth: 300)
            Spacer()
        }
        .padding(24)
    }

    private var transcript: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 18) {
                    ForEach(store.messages) { message in
                        MessageBubble(message: message)
                            .id(message.id)
                    }
                    if store.isSending && store.messages.last?.content.isEmpty == true {
                        HStack {
                            ProgressView().controlSize(.small)
                            Text("Lexo AI réfléchit…").font(.caption).foregroundStyle(.secondary)
                            Spacer()
                        }
                        .padding(.horizontal, 18)
                    }
                }
                .padding(.horizontal, 15)
                .padding(.vertical, 18)
            }
            .onChange(of: store.messages.count) { _, _ in
                if let last = store.messages.last { proxy.scrollTo(last.id, anchor: .bottom) }
            }
            .onChange(of: store.messages.last?.content) { _, _ in
                if let last = store.messages.last { proxy.scrollTo(last.id, anchor: .bottom) }
            }
        }
    }

    private var composer: some View {
        HStack(alignment: .bottom, spacing: 10) {
            TextField("Écrire à Lexo AI…", text: $draft, axis: .vertical)
                .lineLimit(1...5)
                .focused($composerFocused)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(LexoTheme.surface(colorScheme))
                .clipShape(RoundedRectangle(cornerRadius: 22))
                .onSubmit(send)
            Button(action: send) {
                Image(systemName: "arrow.up")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 46, height: 46)
                    .background(LexoTheme.violet)
                    .clipShape(Circle())
            }
            .disabled(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || store.isSending)
            .opacity(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || store.isSending ? 0.55 : 1)
        }
        .padding(.horizontal, 14)
        .padding(.top, 10)
        .padding(.bottom, 10)
        .background(LexoTheme.background(colorScheme))
    }

    private var sidebar: some View {
        NavigationStack {
            VStack(spacing: 14) {
                HStack(spacing: 12) {
                    LexoLogoView().frame(width: 46, height: 46)
                        .clipShape(RoundedRectangle(cornerRadius: 13))
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Lexo AI").font(.title3.bold())
                        Text(app.displayName).font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(.top, 10)

                Button {
                    store.newConversation()
                    showSidebar = false
                } label: {
                    Label("Nouvelle conversation", systemImage: "plus")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(13)
                        .background(LexoTheme.violet)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }

                HStack {
                    Text("Historique").font(.headline)
                    Spacer()
                    Button { Task { await store.refreshConversations() } } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
                List {
                    ForEach(store.conversations.filter {
                        historySearch.isEmpty || $0.title.localizedCaseInsensitiveContains(historySearch)
                    }) { conversation in
                        HStack(spacing: 8) {
                            Button {
                                Task {
                                    await store.selectConversation(conversation.id)
                                    showSidebar = false
                                }
                            } label: {
                                HStack(spacing: 9) {
                                    Image(systemName: "bubble.left.and.bubble.right")
                                        .foregroundStyle(LexoTheme.violet)
                                    Text(conversation.title)
                                        .lineLimit(2)
                                        .multilineTextAlignment(.leading)
                                    Spacer(minLength: 0)
                                }
                            }
                            .buttonStyle(.plain)
                            Menu {
                                Button("Renommer", systemImage: "pencil") {
                                    renameTarget = conversation
                                    renameText = conversation.title
                                    showSidebar = false
                                }
                                Button("Supprimer", systemImage: "trash", role: .destructive) {
                                    Task { await store.deleteConversation(conversation.id) }
                                }
                            } label: {
                                Image(systemName: "ellipsis").foregroundStyle(.secondary)
                            }
                        }
                        .listRowBackground(
                            store.selectedConversationID == conversation.id
                            ? LexoTheme.violet.opacity(0.12) : Color.clear
                        )
                    }
                }
                .listStyle(.plain)
                .searchable(text: $historySearch, prompt: "Rechercher une conversation")

                NavigationLink {
                    SettingsView(app: app)
                } label: {
                    Label("Paramètres", systemImage: "gearshape")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                        .background(LexoTheme.surface(colorScheme))
                        .clipShape(RoundedRectangle(cornerRadius: 13))
                }
                .buttonStyle(.plain)
                Button(role: .destructive) {
                    Task { await app.signOut() }
                } label: {
                    Label("Se déconnecter", systemImage: "rectangle.portrait.and.arrow.right")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                }
            }
            .padding(.horizontal, 16)
            .background(LexoTheme.background(colorScheme))
            .navigationTitle("Menu")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fermer") { showSidebar = false }
                }
            }
        }
        .presentationDetents([.large])
    }

    private func send() {
        let value = draft
        guard !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        draft = ""
        composerFocused = false
        Task { await store.send(value) }
    }
}

private struct MessageBubble: View {
    let message: ChatMessage
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack {
            if message.isUser { Spacer(minLength: 45) }
            VStack(alignment: .leading, spacing: 7) {
                if !message.isUser {
                    Label("Lexo AI", systemImage: "sparkles")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(LexoTheme.violet)
                }
                Text(message.content.isEmpty ? " " : message.content)
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(message.isUser ? 13 : 3)
            .background(message.isUser ? LexoTheme.violet.opacity(0.16) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            if !message.isUser { Spacer(minLength: 25) }
        }
    }
}