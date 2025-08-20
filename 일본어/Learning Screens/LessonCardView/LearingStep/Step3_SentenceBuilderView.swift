// Step3_SentenceBuilderView.swift
import SwiftUI
import AVKit

struct Step3_SentenceBuilderView: View {
    var onComplete: () -> Void

    private let originalWords = ["안","녕","하하하","하","하","하","하","하","하","하","하","세","요"]
    let correctSentence = ["안","녕","하하하","하","하","하","하","하","하","하","하","세","요"]

    @State private var selectedWords: [String] = []
    @State private var availableWords: [String] = []
    @State private var hasSubmitted = false
    @State private var highlightColor: Color? = nil
    @State private var shakeOffset: CGFloat = 0
    @State private var showResultView = false
    @State private var resultType: ResultType? = nil
    @State private var draggedItem: String? = nil
    @State private var hasFinishedIntroVideo = false
    @State private var showStep3Content = false

    // 데모 플레이어 (필요하면 PlayerViewModel 로 교체 가능)
    @State private var player = AVPlayer(
        url: Bundle.main.url(forResource: "ハイキュー北信介名言 [it3tKC0ycu4]", withExtension: "mp4")!
    )

    enum ResultType { case correct, wrong }

    var body: some View {
        RatioAnchoredButtonLayout(
            buttonYRatio: 0.90,
            buttonReservedHeight: 84,
            horizontalMargin: 16
        ) {
            // ▶︎ 콘텐츠
            VStack(spacing: 10) {
                Text("Step 3: 문장 완성하기")
                    .font(.title).fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding(.top, 30)

                Text("단어를 순서에 맞게 배열하여 문장을 완성하세요.")
                    .font(.subheadline)
                    .foregroundStyle(.gray)

                if !hasFinishedIntroVideo {
                    Spacer().frame(height: 25)
                    CustomAVPlayerView(player: player)
                        .frame(height: 250)
                        .cornerRadius(20)
                        .padding(.horizontal)
                        .transition(.opacity)
                    Spacer()
                }

                if hasFinishedIntroVideo {
                    Spacer()

                    // 선택 영역
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 70), spacing: 6)], spacing: 6) {
                        ForEach(Array(selectedWords.enumerated()), id: \.offset) { pair in
                            let word = pair.element
                            Text(word)
                                .font(.system(size: 18, weight: .medium))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .foregroundColor(.black)
                                .background(
                                    hasSubmitted
                                    ? (highlightColor ?? Color(red: 1, green: 0.8627, blue: 0.8627))
                                    : Color(red: 1, green: 0.8627, blue: 0.8627)
                                )
                                .cornerRadius(8)
                                .onDrag {
                                    draggedItem = word
                                    return NSItemProvider(object: word as NSString)
                                }
                                .onDrop(of: [.text], delegate: WordDropDelegate(
                                    currentItem: word,
                                    items: $selectedWords,
                                    draggedItem: $draggedItem
                                ))
                                .scaleEffect(showStep3Content ? 1 : 0.8)
                                .opacity(showStep3Content ? 1 : 0)
                                .animation(.easeOut.delay(Double(pair.offset) * 0.03), value: showStep3Content)
                        }
                    }
                    .offset(x: shakeOffset)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white.opacity(0.3))
                    .cornerRadius(8)
                    .padding()

                    // 후보 영역
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 70), spacing: 6)], spacing: 6) {
                        ForEach(Array(availableWords.enumerated()), id: \.offset) { pair in
                            let index = pair.offset
                            let word = pair.element
                            Button {
                                selectedWords.append(word)
                                availableWords.remove(at: index)
                            } label: {
                                Text(word)
                                    .font(.system(size: 18, weight: .medium))
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .foregroundColor(.black)
                                    .background(Color(red: 1, green: 0.8627, blue: 0.8627))
                                    .cornerRadius(8)
                            }
                            .scaleEffect(showStep3Content ? 1 : 0.8)
                            .opacity(showStep3Content ? 1 : 0)
                            .animation(.easeOut.delay(Double(index) * 0.02), value: showStep3Content)
                        }
                    }
                    .padding()
                }
            }
            .padding(.bottom, 12)
            .allowsHitTesting(!showResultView)
        } button: {
            // ▶︎ 하단 비율 고정 버튼 영역 (두 개 버튼을 함께 배치)
            if hasFinishedIntroVideo {
                HStack(spacing: 12) {
                    // 다시 하기
                    Button {
                        resetSentence()
                    } label: {
                        Text("다시 하기")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    .frame(height: 52)
                    .background(Color.gray.opacity(0.6))
                    .foregroundColor(.white)
                    .cornerRadius(15)
                    .disabled(hasSubmitted)
                    .opacity(hasSubmitted ? 0.5 : 1)

                    // 제출하기
                    AppButton(title: "제출하기") {
                        checkAnswer()
                    }
                    // AppButton 이 가진 외부 padding 상쇄 (비율 레일에 딱 맞추려면 필요)
                    .padding(.horizontal, -16)
                    .padding(.bottom, -10)
                    .frame(height: 52)
                }
            } else {
                // 인트로 영상 중에는 버튼 숨김 (레이아웃 안정)
                EmptyView()
            }
        }
        // ▶︎ 결과 모달 (오버레이)
        .overlay {
            if showResultView {
                Color.black.opacity(0.35)
                    .ignoresSafeArea()
                    .transition(.opacity)

                VStack {
                    Spacer()
                    VStack(spacing: 16) {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(resultType == .wrong ? Color.red : Color.green)
                                .frame(width: 24, height: 24)
                                .overlay(
                                    Image(systemName: resultType == .wrong ? "xmark" : "checkmark")
                                        .foregroundColor(.white)
                                        .font(.system(size: 14, weight: .bold))
                                )
                            Text(resultType == .wrong ? "오답입니다" : "정답입니다")
                                .font(.headline).fontWeight(.bold)
                                .foregroundColor(resultType == .wrong ? .red : .green)
                            Spacer()
                        }

                        if resultType == .wrong {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("정답:").fontWeight(.bold).foregroundColor(.black)
                                LazyVGrid(columns: [GridItem(.adaptive(minimum: 70), spacing: 6)], spacing: 6) {
                                    ForEach(Array(correctSentence.enumerated()), id: \.offset) { _, word in
                                        Text(word)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(Color.white)
                                            .cornerRadius(8)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(Color.red, lineWidth: 2)
                                            )
                                    }
                                }
                            }
                        }

                        Button {
                            withAnimation(.interpolatingSpring(stiffness: 200, damping: 18)) {
                                showResultView = false
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                onComplete()
                            }
                        } label: {
                            Text(resultType == .wrong ? "확인" : "계속 학습하기")
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(resultType == .wrong ? Color.red : Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                                .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray5))
                    .cornerRadius(20)
                    .shadow(radius: 10)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(.easeInOut(duration: 0.25), value: showResultView)
            }
        }
        // ▶︎ 라이프사이클
        .onAppear {
            resetSentence()
            withAnimation(.easeOut(duration: 0.6).delay(0.2)) {
                showStep3Content = true
            }
            NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: player.currentItem,
                queue: .main
            ) { _ in
                withAnimation(.easeInOut(duration: 0.6)) {
                    hasFinishedIntroVideo = true
                }
            }
            player.play()
        }
    }

    // MARK: - Actions
    func checkAnswer() {
        hasSubmitted = true
        guard !selectedWords.isEmpty else {
            highlightColor = .red
            showShake()
            resultType = .wrong
            withAnimation(.spring()) { showResultView = true }
            return
        }

        if selectedWords == correctSentence {
            highlightColor = .green
            resultType = .correct
        } else {
            highlightColor = .red
            showShake()
            resultType = .wrong
        }
        withAnimation(.spring()) { showResultView = true }
    }

    func showShake() {
        withAnimation(.default.repeatCount(3, autoreverses: true)) { shakeOffset = 10 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { shakeOffset = 0 }
    }

    func resetSentence() {
        selectedWords.removeAll()
        availableWords = originalWords.shuffled()
        hasSubmitted = false
        highlightColor = nil
        shakeOffset = 0
    }
}

// MARK: - Drag & Drop
struct WordDropDelegate: DropDelegate {
    let currentItem: String
    @Binding var items: [String]
    @Binding var draggedItem: String?

    func dropEntered(info: DropInfo) {
        guard let draggedItem, draggedItem != currentItem,
              let fromIndex = items.firstIndex(of: draggedItem),
              let toIndex = items.firstIndex(of: currentItem) else { return }

        withAnimation {
            items.move(fromOffsets: IndexSet(integer: fromIndex),
                       toOffset: toIndex > fromIndex ? toIndex + 1 : toIndex)
        }
    }

    func performDrop(info: DropInfo) -> Bool {
        draggedItem = nil
        return true
    }
}
