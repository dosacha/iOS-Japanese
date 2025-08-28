import Foundation
import Combine

/// KeywordsScreen ↔ VocabularyView 사이의 공유 저장소
final class BookmarkStore: ObservableObject {
    // 오늘의 회화(대화에서 북마크한 단어들)
    @Published private(set) var conversationBookmarks: [VocabItem] = [] {
        didSet { persist(key: Keys.conversation, items: conversationBookmarks) }
    }

    // 오늘의 학습(필요하면 동일 패턴으로 확장)
    @Published private(set) var learningBookmarks: [VocabItem] = [] {
        didSet { persist(key: Keys.learning, items: learningBookmarks) }
    }

    private enum Keys {
        static let conversation = "bookmarks.conversation.v1"
        static let learning = "bookmarks.learning.v1"
    }

    init() {
        self.conversationBookmarks = load(key: Keys.conversation)
        self.learningBookmarks = load(key: Keys.learning)
    }

    // MARK: - Public APIs

    /// 오늘의 회화에 토글(있으면 제거, 없으면 추가)
    func toggleConversation(_ item: VocabItem) {
        if let idx = conversationBookmarks.firstIndex(of: item) {
            conversationBookmarks.remove(at: idx)
        } else {
            conversationBookmarks.append(item)
        }
    }

    /// 오늘의 회화에 포함되어 있는지
    func containsInConversation(_ item: VocabItem) -> Bool {
        conversationBookmarks.contains(item)
    }

    /// 오늘의 학습도 동일한 패턴 (필요시 사용)
    func toggleLearning(_ item: VocabItem) {
        if let idx = learningBookmarks.firstIndex(of: item) {
            learningBookmarks.remove(at: idx)
        } else {
            learningBookmarks.append(item)
        }
    }

    func containsInLearning(_ item: VocabItem) -> Bool {
        learningBookmarks.contains(item)
    }

    // MARK: - Persistence

    private func persist(key: String, items: [VocabItem]) {
        do {
            let data = try JSONEncoder().encode(items)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            print("❌ Persist error(\(key)):", error)
        }
    }

    private func load(key: String) -> [VocabItem] {
        guard let data = UserDefaults.standard.data(forKey: key) else { return [] }
        do {
            return try JSONDecoder().decode([VocabItem].self, from: data)
        } catch {
            print("❌ Load error(\(key)):", error)
            return []
        }
    }
}
