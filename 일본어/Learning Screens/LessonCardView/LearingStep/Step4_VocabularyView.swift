// Step4_VocabularyView.swift
import SwiftUI
import AVKit

// 줄바꿈 가능한 래핑 레이아웃 (그대로 사용)
struct Wrap: Layout {
    var spacing: CGFloat = 8
    var lineSpacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0, y: CGFloat = 0, lineH: CGFloat = 0
        for s in subviews {
            let sz = s.sizeThatFits(.unspecified)
            if x + sz.width > maxWidth { x = 0; y += lineH + lineSpacing; lineH = 0 }
            lineH = max(lineH, sz.height)
            x += sz.width + spacing
        }
        return CGSize(width: maxWidth, height: y + lineH)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let maxWidth = bounds.width
        var x: CGFloat = 0, y: CGFloat = 0, lineH: CGFloat = 0
        for s in subviews {
            let sz = s.sizeThatFits(.unspecified)
            if x + sz.width > maxWidth { x = 0; y += lineH + lineSpacing; lineH = 0 }
            s.place(at: CGPoint(x: bounds.minX + x, y: bounds.minY + y),
                    proposal: ProposedViewSize(width: sz.width, height: sz.height))
            lineH = max(lineH, sz.height)
            x += sz.width + spacing
        }
    }
}

// 후리가나 토큰/뷰 (fixedSize 제거)
struct FuriganaToken: Identifiable {
    let id = UUID()
    let base: String
    let ruby: String?
    let highlight: Bool
}

struct FuriganaWordView: View {
    let token: FuriganaToken
    var body: some View {
        VStack(spacing: 2) {
            if let r = token.ruby, !r.isEmpty {
                Text(r)
                    .font(.caption2)
                    .foregroundColor(.black.opacity(0.7))
                    .lineLimit(1)
            }
            Text(token.base)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(token.highlight ? .pink : .black)
        }
    }
}

struct FuriganaWrapLines: View {
    let tokens: [FuriganaToken]
    var body: some View {
        Wrap(spacing: 8, lineSpacing: 6) {
            ForEach(tokens) { t in
                FuriganaWordView(token: t)
            }
        }
    }
}

// Step 4: Step 1 과 동일 축으로 정렬
struct Step4_VocabularyView: View {
    var onComplete: () -> Void
    @ObservedObject var viewModel: PlayerViewModel
    @StateObject private var recognizer = SpeechRecognizer()

    let targetSentence = "俺達は血液だ。滞り無く流れろ。酸素を回せ、脳が正常に働くために。"

    private let line1: [FuriganaToken] = [
        .init(base: "俺達", ruby: "おれたち", highlight: true),
        .init(base: "は", ruby: nil, highlight: false),
        .init(base: "血液", ruby: "けつえき", highlight: true),
        .init(base: "だ。", ruby: nil, highlight: false),
        .init(base: "滞り", ruby: "とどこおり", highlight: true),
        .init(base: "無く", ruby: "なく", highlight: true),
        .init(base: "流れろ。", ruby: "ながれろ", highlight: true)
    ]
    private let line2: [FuriganaToken] = [
        .init(base: "酸素", ruby: "さんそ", highlight: true),
        .init(base: "を", ruby: nil, highlight: false),
        .init(base: "回せ、", ruby: "まわせ", highlight: true),
        .init(base: "脳", ruby: "のう", highlight: true),
        .init(base: "が", ruby: nil, highlight: false),
        .init(base: "正常", ruby: "せいじょう", highlight: true),
        .init(base: "に", ruby: nil, highlight: false),
        .init(base: "働く", ruby: "はたらく", highlight: true),
        .init(base: "ために。", ruby: "ために", highlight: true)
    ]

    var body: some View {
        RatioAnchoredButtonLayout(
            buttonYRatio: 0.90,           // ✅ Step1 과 동일
            buttonReservedHeight: 84,     // ✅ Step1 과 동일
            horizontalMargin: 16          // ✅ Step1 과 동일
        ) {
            // 콘텐츠는 필요 시 스크롤되도록
            ScrollView {
                VStack(spacing: 10) {
                    // 헤드라인/서브헤드: Step1 과 동일 값
                    Text("Step 4 : 따라 말하기")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .padding(.top, 30)

                    Text("장면에 나온 주요 표현이에요! 복습해 볼까요?")
                        .font(.subheadline)
                        .foregroundStyle(.gray)

                    Spacer().frame(height: 25) // Step1 과 동일 간격

                    // 영상 위치/크기/패딩: Step1 과 동일
                    CustomAVPlayerView(player: viewModel.player)
                        .frame(height: 250)
                        .cornerRadius(20)
                        .padding(.horizontal, 16)

                    // 문장 박스도 같은 가로 축(좌우 16) 위에 놓기
                    VStack(alignment: .leading, spacing: 8) {
                        FuriganaWrapLines(tokens: line1)
                        FuriganaWrapLines(tokens: line2)
                    }
                    .padding(14)
                    .background(Color(red: 1.0, green: 0.9, blue: 0.9))
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 3)
                    .padding(.horizontal, 16)

                    // 마이크 버튼
                    Button {
                        if recognizer.isRecording { recognizer.stopRecording() }
                        else { recognizer.startRecording() }
                    } label: {
                        ZStack {
                            Circle()
                                .fill(recognizer.isRecording
                                      ? Color(red: 1.0, green: 0.45, blue: 0.55)
                                      : Color(red: 1.0, green: 0.86, blue: 0.90))
                                .frame(width: 100, height: 100)
                                .shadow(radius: recognizer.isRecording ? 8 : 2)
                                .animation(.easeInOut(duration: 0.2), value: recognizer.isRecording)

                            LottieView(animationName: "Gradient Music Mic", isPlaying: $recognizer.isRecording)
                                .frame(width: 100, height: 100)
                                .scaleEffect(recognizer.isRecording ? 1.12 : 1.0)
                                .animation(.spring(response: 0.25, dampingFraction: 0.8), value: recognizer.isRecording)
                        }
                    }
                    .buttonStyle(.plain)

                    // 인식 결과 & 정확도
                    let shownText = recognizer.recognizedText.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !shownText.isEmpty {
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "text.bubble.fill")
                                .font(.footnote)
                                .foregroundColor(.accentBlue)
                            Text(shownText)
                                .font(.footnote)
                                .foregroundColor(.black)
                                .multilineTextAlignment(.leading)
                        }
                        .padding(10)
                        .background(Color.white.opacity(0.95))
                        .cornerRadius(10)
                        .padding(.horizontal, 16)
                    }

                    Text("정확도: \(recognizer.calculateSimilarity(to: targetSentence))%")
                        .font(.headline)
                        .foregroundColor(.green)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.horizontal, 16)

                    Spacer(minLength: 0) // 위쪽 정렬 유지
                }
                .frame(maxWidth: .infinity, alignment: .top)
            }
            .onAppear { viewModel.playFromStart() }
            .onDisappear {
                viewModel.pause()
                if recognizer.isRecording { recognizer.stopRecording() }
            }
        } button: {
            // 하단 버튼도 Step1 과 동일한 방식/폭으로 고정
            AppButton(title: "제출하기", action: onComplete)
        }
    }
}
