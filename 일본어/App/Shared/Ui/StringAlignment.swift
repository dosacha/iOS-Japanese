// StringAlignment.swift
//
// 문자 정렬/정규화 + 점수 계산 유틸의 단일 소스
// - AlignmentResult
// - TextNormalizeOption
// - normalizeText(_:option:)
// - alignCharacters(ref:hyp:)

import Foundation

// 채점/하이라이트 용 정렬 결과
struct AlignmentResult {
    let matches: Int
    let substitutions: Int
    let insertions: Int
    let deletions: Int
    let alignedRef: [Character?]
    let alignedHyp: [Character?]

    var cer: Double {
        let n = alignedRef.compactMap { $0 }.count
        guard n > 0 else { return 0 }
        return Double(substitutions + insertions + deletions) / Double(n)
    }
    var accuracyPercent: Int {
        let n = alignedRef.compactMap { $0 }.count
        guard n > 0 else { return 100 }
        return Int(round(100.0 * Double(matches) / Double(n)))
    }
}

// 텍스트 정규화 옵션
enum TextNormalizeOption {
    case basic                // 공백/문장부호 제거 + NFKC 유사
    case japaneseFoldKana     // 전각/반각 정규화 + Katakana→Hiragana + 공백/문장부호 제거
}

// 공통 정규화
func normalizeText(_ s: String, option: TextNormalizeOption = .basic) -> String {
    var t = s.precomposedStringWithCompatibilityMapping

    if option == .japaneseFoldKana {
        let mutable = NSMutableString(string: t)
        // 전각/반각 정규화
        CFStringTransform(mutable, nil, kCFStringTransformFullwidthHalfwidth, false)
        // Katakana → Hiragana 접기
        CFStringTransform(mutable, nil, "Katakana-Hiragana" as NSString, true)
        t = mutable as String
    }

    // 공백/개행 + 문장부호 + 기호 제거 (Swift CharacterSet 사용)
    let ws = CharacterSet.whitespacesAndNewlines
    let punct = CharacterSet.punctuationCharacters
    let symbols = CharacterSet.symbols
    t = String(t.unicodeScalars.filter { !ws.contains($0) && !punct.contains($0) && !symbols.contains($0) })

    return t
}

/// Levenshtein DP 기반 문자 정렬 + 백트레이스 (빈 문자열 안전처리)
func alignCharacters(ref: String, hyp: String) -> AlignmentResult {
    let r = Array(ref)
    let h = Array(hyp)
    let m = r.count, n = h.count

    // 빈 문자열 예외처리
    if m == 0 && n == 0 {
        return AlignmentResult(matches: 0, substitutions: 0, insertions: 0, deletions: 0,
                               alignedRef: [], alignedHyp: [])
    }
    if m == 0 {
        return AlignmentResult(matches: 0, substitutions: 0, insertions: n, deletions: 0,
                               alignedRef: Array<Character?>(repeating: nil, count: n),
                               alignedHyp: h.map { Optional($0) })
    }
    if n == 0 {
        return AlignmentResult(matches: 0, substitutions: 0, insertions: 0, deletions: m,
                               alignedRef: r.map { Optional($0) },
                               alignedHyp: Array<Character?>(repeating: nil, count: m))
    }

    // DP/백포인터 테이블
    var dp = Array(repeating: Array(repeating: 0, count: n + 1), count: m + 1)
    var bt = Array(repeating: Array(repeating: 0, count: n + 1), count: m + 1) // 0=diag,1=up,2=left

    for i in 0...m { dp[i][0] = i; if i > 0 { bt[i][0] = 1 } }
    for j in 0...n { dp[0][j] = j; if j > 0 { bt[0][j] = 2 } }

    for i in 1...m {
        for j in 1...n {
            let cost = (r[i - 1] == h[j - 1]) ? 0 : 1
            let del = dp[i - 1][j] + 1
            let ins = dp[i][j - 1] + 1
            let sub = dp[i - 1][j - 1] + cost
            let best = min(del, ins, sub)
            dp[i][j] = best
            if best == sub { bt[i][j] = 0 }
            else if best == del { bt[i][j] = 1 }
            else { bt[i][j] = 2 }
        }
    }

    // 백트레이스
    var i = m, j = n
    var alignedRef: [Character?] = []
    var alignedHyp: [Character?] = []
    var matches = 0, subs = 0, ins = 0, del = 0

    while i > 0 || j > 0 {
        let move = bt[i][j]
        if move == 0 {
            let rc = r[i - 1], hc = h[j - 1]
            alignedRef.append(rc)
            alignedHyp.append(hc)
            if rc == hc { matches += 1 } else { subs += 1 }
            i -= 1; j -= 1
        } else if move == 1 {
            alignedRef.append(r[i - 1])
            alignedHyp.append(nil)
            del += 1
            i -= 1
        } else {
            alignedRef.append(nil)
            alignedHyp.append(h[j - 1])
            ins += 1
            j -= 1
        }
    }

    alignedRef.reverse()
    alignedHyp.reverse()

    return AlignmentResult(
        matches: matches,
        substitutions: subs,
        insertions: ins,
        deletions: del,
        alignedRef: alignedRef,
        alignedHyp: alignedHyp
    )
}
