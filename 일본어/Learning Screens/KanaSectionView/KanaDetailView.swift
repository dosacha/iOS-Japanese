import SwiftUI
import AVFoundation

// MARK: - 발음 재생 클래스
final class SpeechPlayer {
    static let shared = SpeechPlayer()
    private let synth = AVSpeechSynthesizer()
    
    private init() {
        try? AVAudioSession.sharedInstance().setCategory(
            .playback,
            mode: .spokenAudio,
            options: [.duckOthers]
        )
        try? AVAudioSession.sharedInstance().setActive(true, options: [])
    }
    
    // MARK: - 모라 추정(대략)
    private func estimateMora(_ text: String) -> Double {
        let smallKana: Set<Character> = Set("ゃゅょぁぃぅぇぉャュョァィゥェォヮっッ")
        var mora: Double = 0
        for ch in text {
            switch ch.unicodeScalars.first?.value ?? 0 {
            case 0x3040...0x309F: // ひらがな
                mora += smallKana.contains(ch) ? 0.5 : 1.0
            case 0x30A0...0x30FF: // カタカナ
                mora += smallKana.contains(ch) ? 0.5 : 1.0
            case 0x4E00...0x9FFF: // 한자
                mora += 2.0
            default:
                mora += 0.5
            }
        }
        return max(mora, 1.0)
    }
    
    private func rate(forMora mora: Double) -> Float {
        switch mora {
        case ..<1.5:    return 0.22
        case ..<2.5:    return 0.25
        case ..<3.5:    return 0.30
        case ..<4.5:    return 0.35
        case ..<6.5:    return 0.40
        default:        return 0.45
        }
    }
    
    // MARK: - 문자열 처리
    private func trimmedPunctuations(_ s: String) -> String {
        let jpPunct = "、。・「」『』（）【】［］《》！？：；…ー"
        let enPunct = ".,!?;:()[]{}\"'`~"
        let set = CharacterSet(charactersIn: jpPunct + enPunct + " ").union(.whitespacesAndNewlines)
        return s.trimmingCharacters(in: set)
    }
    
    // 길게 읽을 대상 판단
    private func shouldElongate(_ token: String) -> Bool {
        let trimmed = trimmedPunctuations(token)
        let lowered = trimmed.lowercased()

        // 로마자
        if ["a","e","he","i","o","n","wo"].contains(lowered) { return true }

        // 가나 (を, ヲ 추가)
        let elongateKana: Set<String> = [
            "あ","ア",
            "え","エ",
            "へ","ヘ",
            "い","イ",
            "お","オ",
            "ん","ン",
            "を","ヲ"   // ← 추가
        ]
        return elongateKana.contains(trimmed)
    }

    // 모라 반복 변환
    private func elongatedStringByRepetition(for token: String) -> String {
        let trimmed = trimmedPunctuations(token)
        let lowered = trimmed.lowercased()
        let suffix = token.replacingOccurrences(of: trimmed, with: "")

        switch lowered {
        case "a": return "ああ" + suffix
        case "e": return "ええ" + suffix
        case "he": return "へー" + suffix
        case "i": return "いい" + suffix
        case "o": return "おお" + suffix
        case "n": return "んん" + suffix
        case "wo": return "をを" + suffix // ← 추가
        default:
            let mapRepeat: [String:String] = [
                "あ":"ああ", "ア":"アア",
                "え":"ええ", "エ":"エエ",
                "へ":"へー", "ヘ":"ヘー",
                "い":"いい", "イ":"イイ",
                "お":"おお", "オ":"オオ",
                "ん":"んん", "ン":"ンン",
                "を":"をを", "ヲ":"ヲヲ"  // ← 추가
            ]
            if let rep = mapRepeat[trimmed] {
                return rep + suffix
            }
            return token
        }
    }
    
    private func interWordPause(after token: String) -> Double {
        let punctTail = token.last.map { "、。.!?？！".contains($0) } ?? false
        if punctTail { return 0.20 }
        let m = estimateMora(token)
        return m < 2 ? 0.10 : 0.06
    }
    
    // MARK: - 메인
    func speakJapanese(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        let tokens = trimmed.split(whereSeparator: { $0.isWhitespace })
        let chunks: [String] = tokens.isEmpty ? [trimmed] : tokens.map(String.init)
        
        synth.stopSpeaking(at: .immediate)
        
        for (idx, token) in chunks.enumerated() {
            // ✅ 대상이면 같은 모라 2회로 늘림
            let speakText = shouldElongate(token) ? elongatedStringByRepetition(for: token) : token
            
            let u = AVSpeechUtterance(string: speakText)
            u.voice = AVSpeechSynthesisVoice(language: "ja-JP")
            u.pitchMultiplier = 1.0
            u.prefersAssistiveTechnologySettings = true
            
            let m = estimateMora(speakText)
            var baseRate = rate(forMora: m)
            var postDelay = interWordPause(after: speakText)
            
            if shouldElongate(token) {
                // 반복 자체로 모라가 늘었으므로, 지나치게 느려지지 않게 살짝만 낮춤
                baseRate = 0.16
                postDelay += 0.10
            } else if m < 1.5 {
                baseRate = max(0.18, baseRate - 0.04)
            }
            
            u.rate = baseRate
            u.preUtteranceDelay = 0.0
            u.postUtteranceDelay = postDelay
            
            if idx == chunks.count - 1 {
                u.postUtteranceDelay += 0.05
            }
            
            synth.speak(u)
        }
    }
}

// MARK: - KanaDetailView (UI 변경 없음)
struct KanaDetailView: View {
    let character: KanaCharacter
    var onClose: () -> Void
    
    private var koreanPronunciation: String {
        let mapping: [String: String] = [
            "a":"아","i":"이","u":"우","e":"에","o":"오",
            "ka":"카","ki":"키","ku":"쿠","ke":"케","ko":"코",
            "sa":"사","shi":"시","su":"스","se":"세","so":"소",
            "ta":"타","chi":"치","tsu":"츠","te":"테","to":"토",
            "na":"나","ni":"니","nu":"누","ne":"네","no":"노",
            "ha":"하","hi":"히","fu":"후","he":"헤","ho":"호",
            "ma":"마","mi":"미","mu":"무","me":"메","mo":"모",
            "ya":"야","yu":"유","yo":"요",
            "ra":"라","ri":"리","ru":"루","re":"레","ro":"로",
            "wa":"와","n":"응"
        ]
        return mapping[character.pronunciation] ?? ""
    }
    
    var body: some View {
        VStack(spacing: 24) {
            // 상단 라벨
            HStack {
                Text(character.gyo)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(red: 1.0, green: 0.4196, blue: 0.5059)) // 로즈핑크
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                Spacer()
            }
            
            // 큰 문자
            Text(character.kana)
                .font(.system(size: 120, weight: .bold))
                .foregroundColor(.black)
            
            // 발음 섹션
            VStack(spacing: 8) {
                Text("발음")
                    .font(.subheadline)
                    .foregroundColor(.black.opacity(0.6))
                
                HStack(alignment: .firstTextBaseline, spacing: 10) {
                    Text("\(character.pronunciation) / \(koreanPronunciation)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    
                    // ✅ 발음 재생 버튼 (UI/색상 그대로)
                    Button {
                        SpeechPlayer.shared.speakJapanese(character.kana)
                    } label: {
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.title2)
                            .foregroundColor(Color(red: 1.0, green: 0.8, blue: 0.0))
                    }
                    .buttonStyle(.plain)
                }
            }
            
            // 획순 섹션
            VStack(spacing: 10) {
                Text("획순")
                    .font(.subheadline)
                    .foregroundColor(.black.opacity(0.6))
                
                StrokeOrderView(character: character.kana)
            }
        }
        .padding(28)
        .background(Color(red: 238/255, green: 238/255, blue: 238/255))// 카드 배경
        .cornerRadius(30)
        .shadow(color: .black.opacity(0.15), radius: 20)
        .padding(30)
        // ✅ 닫기 버튼
        .overlay(
            Button(action: onClose) {
                Image(systemName: "xmark.circle.fill")
                    .font(.largeTitle)
                    .foregroundColor(.gray)
            }
            .buttonStyle(.plain)
            .padding(10),
            alignment: .topTrailing
        )
    }
}
