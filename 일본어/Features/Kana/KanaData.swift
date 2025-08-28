import SwiftUI

enum KanaType {
    case hiragana
    case katakana
}

struct KanaCharacter: Identifiable, Equatable {
    let id = UUID()
    let kana: String
    let pronunciation: String
    let gyo: String
}

enum KanaGridItem: Identifiable {
    case character(KanaCharacter)
    case empty(UUID = UUID()) // 고정 UUID로 변경

    var id: UUID {
        switch self {
        case .character(let char):
            return char.id
        case .empty(let id):
            return id
        }
    }
}

let hiraganaGridData: [KanaGridItem] = [
    .character(KanaCharacter(kana: "あ", pronunciation: "a", gyo: "あ행")), .character(KanaCharacter(kana: "い", pronunciation: "i", gyo: "あ행")), .character(KanaCharacter(kana: "う", pronunciation: "u", gyo: "あ행")), .character(KanaCharacter(kana: "え", pronunciation: "e", gyo: "あ행")), .character(KanaCharacter(kana: "お", pronunciation: "o", gyo: "あ행")),
    .character(KanaCharacter(kana: "か", pronunciation: "ka", gyo: "か행")), .character(KanaCharacter(kana: "き", pronunciation: "ki", gyo: "か행")), .character(KanaCharacter(kana: "く", pronunciation: "ku", gyo: "か행")), .character(KanaCharacter(kana: "け", pronunciation: "ke", gyo: "か행")), .character(KanaCharacter(kana: "こ", pronunciation: "ko", gyo: "か행")),
    .character(KanaCharacter(kana: "さ", pronunciation: "sa", gyo: "さ행")), .character(KanaCharacter(kana: "し", pronunciation: "shi", gyo: "さ행")), .character(KanaCharacter(kana: "す", pronunciation: "su", gyo: "さ행")), .character(KanaCharacter(kana: "せ", pronunciation: "se", gyo: "さ행")), .character(KanaCharacter(kana: "そ", pronunciation: "so", gyo: "さ행")),
    .character(KanaCharacter(kana: "た", pronunciation: "ta", gyo: "た행")), .character(KanaCharacter(kana: "ち", pronunciation: "chi", gyo: "た행")), .character(KanaCharacter(kana: "つ", pronunciation: "tsu", gyo: "た행")), .character(KanaCharacter(kana: "て", pronunciation: "te", gyo: "た행")), .character(KanaCharacter(kana: "と", pronunciation: "to", gyo: "た행")),
    .character(KanaCharacter(kana: "な", pronunciation: "na", gyo: "な행")), .character(KanaCharacter(kana: "に", pronunciation: "ni", gyo: "な행")), .character(KanaCharacter(kana: "ぬ", pronunciation: "nu", gyo: "な행")), .character(KanaCharacter(kana: "ね", pronunciation: "ne", gyo: "な행")), .character(KanaCharacter(kana: "の", pronunciation: "no", gyo: "な행")),
    .character(KanaCharacter(kana: "は", pronunciation: "ha", gyo: "は행")), .character(KanaCharacter(kana: "ひ", pronunciation: "hi", gyo: "は행")), .character(KanaCharacter(kana: "ふ", pronunciation: "fu", gyo: "は행")), .character(KanaCharacter(kana: "へ", pronunciation: "he", gyo: "は행")), .character(KanaCharacter(kana: "ほ", pronunciation: "ho", gyo: "は행")),
    .character(KanaCharacter(kana: "ま", pronunciation: "ma", gyo: "ま행")), .character(KanaCharacter(kana: "み", pronunciation: "mi", gyo: "ま행")), .character(KanaCharacter(kana: "む", pronunciation: "mu", gyo: "ま행")), .character(KanaCharacter(kana: "め", pronunciation: "me", gyo: "ま행")), .character(KanaCharacter(kana: "も", pronunciation: "mo", gyo: "ま행")),
    .character(KanaCharacter(kana: "や", pronunciation: "ya", gyo: "や행")), .empty(), .character(KanaCharacter(kana: "ゆ", pronunciation: "yu", gyo: "や행")), .empty(), .character(KanaCharacter(kana: "よ", pronunciation: "yo", gyo: "や행")),
    .character(KanaCharacter(kana: "ら", pronunciation: "ra", gyo: "ら행")), .character(KanaCharacter(kana: "り", pronunciation: "ri", gyo: "ら행")), .character(KanaCharacter(kana: "る", pronunciation: "ru", gyo: "ら행")), .character(KanaCharacter(kana: "れ", pronunciation: "re", gyo: "ら행")), .character(KanaCharacter(kana: "ろ", pronunciation: "ro", gyo: "ら행")),
    .character(KanaCharacter(kana: "わ", pronunciation: "wa", gyo: "わ행")), .empty(), .character(KanaCharacter(kana: "を", pronunciation: "o", gyo: "わ행")), .empty(), .character(KanaCharacter(kana: "ん", pronunciation: "n", gyo: "わ행"))
]

let katakanaGridData: [KanaGridItem] = [
    .character(KanaCharacter(kana: "ア", pronunciation: "a", gyo: "ア행")), .character(KanaCharacter(kana: "イ", pronunciation: "i", gyo: "ア행")), .character(KanaCharacter(kana: "ウ", pronunciation: "u", gyo: "ア행")), .character(KanaCharacter(kana: "エ", pronunciation: "e", gyo: "ア행")), .character(KanaCharacter(kana: "オ", pronunciation: "o", gyo: "ア행")),
    .character(KanaCharacter(kana: "カ", pronunciation: "ka", gyo: "カ행")), .character(KanaCharacter(kana: "キ", pronunciation: "ki", gyo: "カ행")), .character(KanaCharacter(kana: "ク", pronunciation: "ku", gyo: "カ행")), .character(KanaCharacter(kana: "ケ", pronunciation: "ke", gyo: "カ행")), .character(KanaCharacter(kana: "コ", pronunciation: "ko", gyo: "カ행")),
    .character(KanaCharacter(kana: "サ", pronunciation: "sa", gyo: "サ행")), .character(KanaCharacter(kana: "シ", pronunciation: "shi", gyo: "サ행")), .character(KanaCharacter(kana: "ス", pronunciation: "su", gyo: "サ행")), .character(KanaCharacter(kana: "セ", pronunciation: "se", gyo: "サ행")), .character(KanaCharacter(kana: "ソ", pronunciation: "so", gyo: "サ행")),
    .character(KanaCharacter(kana: "タ", pronunciation: "ta", gyo: "タ행")), .character(KanaCharacter(kana: "チ", pronunciation: "chi", gyo: "タ행")), .character(KanaCharacter(kana: "ツ", pronunciation: "tsu", gyo: "タ행")), .character(KanaCharacter(kana: "テ", pronunciation: "te", gyo: "タ행")), .character(KanaCharacter(kana: "ト", pronunciation: "to", gyo: "タ행")),
    .character(KanaCharacter(kana: "ナ", pronunciation: "na", gyo: "ナ행")), .character(KanaCharacter(kana: "ニ", pronunciation: "ni", gyo: "ナ행")), .character(KanaCharacter(kana: "ヌ", pronunciation: "nu", gyo: "ナ행")), .character(KanaCharacter(kana: "ネ", pronunciation: "ne", gyo: "ナ행")), .character(KanaCharacter(kana: "ノ", pronunciation: "no", gyo: "ナ행")),
    .character(KanaCharacter(kana: "ハ", pronunciation: "ha", gyo: "ハ행")), .character(KanaCharacter(kana: "ヒ", pronunciation: "hi", gyo: "ハ행")), .character(KanaCharacter(kana: "フ", pronunciation: "fu", gyo: "ハ행")), .character(KanaCharacter(kana: "ヘ", pronunciation: "he", gyo: "ハ행")), .character(KanaCharacter(kana: "ホ", pronunciation: "ho", gyo: "ハ행")),
    .character(KanaCharacter(kana: "マ", pronunciation: "ma", gyo: "マ행")), .character(KanaCharacter(kana: "ミ", pronunciation: "mi", gyo: "マ행")), .character(KanaCharacter(kana: "ム", pronunciation: "mu", gyo: "マ행")), .character(KanaCharacter(kana: "メ", pronunciation: "me", gyo: "マ행")), .character(KanaCharacter(kana: "モ", pronunciation: "mo", gyo: "マ행")),
    .character(KanaCharacter(kana: "ヤ", pronunciation: "ya", gyo: "ヤ행")), .empty(), .character(KanaCharacter(kana: "ユ", pronunciation: "yu", gyo: "ヤ행")), .empty(), .character(KanaCharacter(kana: "ヨ", pronunciation: "yo", gyo: "ヤ행")),
    .character(KanaCharacter(kana: "ラ", pronunciation: "ra", gyo: "ラ행")), .character(KanaCharacter(kana: "リ", pronunciation: "ri", gyo: "ラ행")), .character(KanaCharacter(kana: "ル", pronunciation: "ru", gyo: "ラ행")), .character(KanaCharacter(kana: "レ", pronunciation: "re", gyo: "ラ행")), .character(KanaCharacter(kana: "ロ", pronunciation: "ro", gyo: "ラ행")),
    .character(KanaCharacter(kana: "ワ", pronunciation: "wa", gyo: "ワ행")), .empty(), .character(KanaCharacter(kana: "ヲ", pronunciation: "o", gyo: "ワ행")), .empty(), .character(KanaCharacter(kana: "ン", pronunciation: "n", gyo: "ワ행"))
]

struct KanaDataProvider {
    static func getData(for type: KanaType) -> [KanaGridItem] {
        switch type {
        case .hiragana:
            return hiraganaGridData
        case .katakana:
            return katakanaGridData
        }
    }
}

