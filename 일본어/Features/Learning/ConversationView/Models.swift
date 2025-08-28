import Foundation
/// 단어 모델
struct VocabItem: Identifiable, Codable, Equatable {
    let id: UUID
    var kanji: String
    var furigana: String?
    var korean: String
    var dayTag: String?

    init(id: UUID = UUID(),
         kanji: String,
         furigana: String? = nil,
         korean: String,
         dayTag: String? = nil) {
        self.id = id
        self.kanji = kanji
        self.furigana = furigana
        self.korean = korean
        self.dayTag = dayTag
    }
}
