import Foundation

struct ConversationMessage: Identifiable, Equatable, Hashable {
    let id: Int
    let japanese: String
    let korean: String
    let isUser: Bool
    let furigana: [FuriganaUnit]
}
