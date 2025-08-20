// Step2_DictationView.swift
import SwiftUI

// MARK: - Step 2 상태 정의
enum QuizState: Equatable {
    case initial
    case incorrect(revealedAnswer: String)
    case correct
    case finishedWrongAnswer
}

// MARK: - Step 2 받아쓰기 뷰 (재구성)
struct Step2_DictationView: View {
    var onComplete: () -> Void
    @ObservedObject var viewModel: PlayerViewModel

    struct QuizChoice: Identifiable, Equatable {
        let id = UUID()
        let furigana: String
        let kanji: String
    }

    @State private var quizState: QuizState = .initial
    @State private var selectedChoice: QuizChoice?

    private let correctAnswer = "最強"
    private let choices: [QuizChoice] = [
        QuizChoice(furigana: "さいきょう", kanji: "最強"),
        QuizChoice(furigana: "さいしょう", kanji: "最小"),
        QuizChoice(furigana: "さいしょ", kanji: "最初")
    ]

    var body: some View {
        RatioAnchoredButtonLayout(
            buttonYRatio: 0.90,
            buttonReservedHeight: 84,
            horizontalMargin: 16
        ) {
            // ⬇︎ 콘텐츠 영역 (기존 구성 유지)
            VStack(spacing: 10) {
                HeaderAndVideoView(viewModel: viewModel)

                SentenceAnswerAreaView(quizState: $quizState, selectedChoice: $selectedChoice)
                    .padding(.horizontal, 24)

                Spacer().frame(height: 10)

                ChoiceButtonsView(
                    choices: choices,
                    quizState: $quizState,
                    selectedChoice: $selectedChoice,
                    onSelect: handleChoiceSelection
                )

                Spacer()
            }
        } button: {
            // ⬇︎ 비율 고정 버튼 (정답 또는 오답 공개 이후에만 노출)
            if quizState == .correct || quizState == .finishedWrongAnswer {
                AppButton(title: "다음으로!", action: onComplete)
            } else {
                // 자리만 유지하고 보이지 않게 (터치 불가)
                AppButton(title: "다음으로!", action: {})
                    .opacity(0)
                    .allowsHitTesting(false)
            }
        }
    }

    private func handleChoiceSelection(choice: QuizChoice) {
        guard case .initial = quizState else { return }

        selectedChoice = choice

        if choice.kanji == correctAnswer {
            HapticManager.instance.notification(type: .success)
            withAnimation(.spring()) {
                quizState = .correct
            }
        } else {
            HapticManager.instance.notification(type: .error)
            withAnimation(.spring()) {
                quizState = .incorrect(revealedAnswer: correctAnswer)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.spring()) {
                    quizState = .finishedWrongAnswer
                }
            }
        }
    }
}

// MARK: - 하위 뷰들 (기존과 동일)
fileprivate struct HeaderAndVideoView: View {
    @ObservedObject var viewModel: PlayerViewModel

    var body: some View {
        VStack(spacing: 10) {
            Text("Step 2 : 빈칸 채우기")
                .font(.title).fontWeight(.bold).foregroundColor(.black)
                .padding(.top, 30)

            Text("들리는 대로 빈칸을 채워보세요")
                .font(.subheadline).foregroundStyle(.gray)

            Spacer().frame(height: 25)

            CustomAVPlayerView(player: viewModel.player)
                .frame(height: 250)
                .cornerRadius(20)
                .padding(.horizontal)
        }
        // ✅ 이 Step 들어오면 0초부터 재생, 나가면 일시정지
        .onAppear { viewModel.playFromStart() }
        .onDisappear { viewModel.pause() }
    }
}

fileprivate struct SentenceAnswerAreaView: View {
    @Binding var quizState: QuizState
    @Binding var selectedChoice: Step2_DictationView.QuizChoice?

    var body: some View {
        HStack(spacing: 20) {
            Text("俺が いれば お前は")

            ZStack {
                switch quizState {
                case .initial:
                    if let choice = selectedChoice {
                        ChoiceView(choice: choice)
                    } else {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(red: 0.77, green: 0.77, blue: 0.77), style: StrokeStyle(lineWidth: 1, dash: [4]))
                            .background(RoundedRectangle(cornerRadius: 12).fill(Color.white))
                            .frame(width: 90, height: 40)
                    }
                case .incorrect(let revealedAnswer):
                    Text(revealedAnswer).font(.title3.bold()).foregroundColor(.red)
                case .correct:
                    if let choice = selectedChoice {
                        ChoiceView(choice: choice, isCorrect: true)
                    }
                case .finishedWrongAnswer:
                    Text("最強").font(.title3.bold()).foregroundColor(.blue)
                }
            }
            .frame(width: 100, height: 40)

            Text("だ！")
        }
        .padding()
        .font(.title2)
        .foregroundColor(.black)
        .background(Color(red: 1.0, green: 0.86, blue: 0.86))
        .overlay(
            RoundedRectangle(cornerRadius: 25)
                .stroke(Color(red: 0.77, green: 0.77, blue: 0.77), lineWidth: 1)
        )
        .cornerRadius(25)
    }
}

fileprivate struct ChoiceButtonsView: View {
    let choices: [Step2_DictationView.QuizChoice]
    @Binding var quizState: QuizState
    @Binding var selectedChoice: Step2_DictationView.QuizChoice?
    let onSelect: (Step2_DictationView.QuizChoice) -> Void

    var body: some View {
        HStack(spacing: 16) {
            ForEach(choices) { choice in
                Button(action: { onSelect(choice) }) {
                    let isSelected = (selectedChoice == choice)
                    ChoiceView(choice: choice, isSelected: isSelected, quizState: quizState)
                }
                .disabled(quizState != .initial)
            }
        }
        .padding(.horizontal, 16)
    }
}

fileprivate struct ChoiceView: View {
    let choice: Step2_DictationView.QuizChoice
    var isSelected: Bool = false
    var isCorrect: Bool = false
    var quizState: QuizState? = nil

    var body: some View {
        VStack(spacing: 2) {
            Text(choice.furigana).font(.caption)
            Text(choice.kanji).font(.title3).bold()
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(getBackgroundColor())
        .foregroundColor(.black)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color(red: 0.77, green: 0.77, blue: 0.77), lineWidth: 1)
        )
        .cornerRadius(15)
        .shadow(color: .yellow.opacity(0.8), radius: isCorrect ? 10 : 0)
    }

    private func getBackgroundColor() -> Color {
        guard let state = quizState, isSelected else {
            return Color(red: 1.0, green: 0.86, blue: 0.86)
        }
        switch state {
        case .correct:
            return .green.opacity(0.3)
        case .incorrect:
            return .red.opacity(0.3)
        default:
            return Color(red: 1.0, green: 0.86, blue: 0.86)
        }
    }
}

// MARK: - Haptic
fileprivate class HapticManager {
    static let instance = HapticManager()
    private init() {}

    func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
}
