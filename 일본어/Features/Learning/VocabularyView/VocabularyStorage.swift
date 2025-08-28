import Foundation

/// '오늘의 학습/회화' 북마크 영구 저장(UserDefaults)
final class VocabularyStorage {
    static let shared = VocabularyStorage()
    private init() {}

    private let learningKey = "vocab.learning.v1"
    private let convoKey    = "vocab.conversation.v1"

    // MARK: - Learning
    func loadLearning() -> [VocabItem] {
        guard let data = UserDefaults.standard.data(forKey: learningKey) else { return [] }
        return (try? JSONDecoder().decode([VocabItem].self, from: data)) ?? []
    }

    func saveLearning(_ items: [VocabItem]) {
        guard let data = try? JSONEncoder().encode(items) else { return }
        UserDefaults.standard.set(data, forKey: learningKey)
    }

    func clearLearning() {
        UserDefaults.standard.removeObject(forKey: learningKey)
    }

    // MARK: - Conversation
    func loadConversation() -> [VocabItem] {
        guard let data = UserDefaults.standard.data(forKey: convoKey) else { return [] }
        return (try? JSONDecoder().decode([VocabItem].self, from: data)) ?? []
    }

    func saveConversation(_ items: [VocabItem]) {
        guard let data = try? JSONEncoder().encode(items) else { return }
        UserDefaults.standard.set(data, forKey: convoKey)
    }

    func clearConversation() {
        UserDefaults.standard.removeObject(forKey: convoKey)
    }
}

// 편의 확장: 배열에 토글 적용
extension Array where Element == VocabItem {
    func toggled(_ item: VocabItem, isOn: Bool) -> [VocabItem] {
        var copy = self
        if isOn {
            if !copy.contains(where: { $0.id == item.id }) {
                copy.insert(item, at: 0)
            }
        } else {
            copy.removeAll { $0.id == item.id }
        }
        return copy
    }
}
