import Foundation

struct FuriganaUnit: Equatable, Hashable {
    let text: String          // 본문
    let furigana: String?     // 후리가나 (없을 수 있음)
}
