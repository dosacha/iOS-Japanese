// LearningFlowView.swift
import SwiftUI

struct LearningFlowView: View {
    @Environment(\.dismiss) var dismiss
    @State private var currentStep: Int = 1
    private let totalSteps: Int = 6

    // 모든 Step 에서 공유할 PlayerViewModel
    @StateObject private var viewModel = PlayerViewModel()

    // Step 이동 함수에서 먼저 "강제 정지/리셋"
    private func advanceToNextStep() {
        // Step 전환 직전에 반드시 멈추고(소리 포함) 위치 리셋
        viewModel.stopAndReset()

        withAnimation(.easeInOut(duration: 0.3)) {
            if currentStep < totalSteps {
                currentStep += 1
            } else {
                currentStep = 0 // 완료 화면
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // xmark + 상단 진행바
            HStack(spacing: 12) {
                Button(action: {
                    // 나가기 직전에도 정지/리셋
                    viewModel.stopAndReset()
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.headline)
                        .foregroundColor(.gray)
                }

                ProgressView(value: Double(currentStep), total: Double(totalSteps))
                    .tint(Color(red: 255/255, green: 107/255, blue: 129/255))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
                    .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)

            // 혹시 다른 경로로 currentStep 이 바뀔 때도 방어
            Group {
                switch currentStep {
                case 1:
                    Step1_ListeningView(onComplete: advanceToNextStep, viewModel: viewModel)
                case 2:
                    Step2_DictationView(onComplete: advanceToNextStep, viewModel: viewModel)
                case 3:
                    Step3_SentenceBuilderView(onComplete: advanceToNextStep)
                case 4:
                    Step4_VocabularyView(onComplete: advanceToNextStep, viewModel: viewModel)
                case 5:
                    Step5_CompositionView(onComplete: advanceToNextStep)
                default:
                    CompletionView(
                        onRestart: {
                            // 재시작 시에도 리셋 보장
                            viewModel.stopAndReset()
                            withAnimation { currentStep = 1 }
                        },
                        onExit: {
                            viewModel.stopAndReset()
                            dismiss()
                        }
                    )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .background {
            LinearGradient(
                gradient: Gradient(colors: [Color(red: 255/255, green: 220/255, blue: 230/255), .white]),
                startPoint: .top,
                endPoint: UnitPoint(x: 0.6, y: 0.6)
            )
            .ignoresSafeArea()
        }
        // 방어선 2: 어떤 이유로든 currentStep 값이 바뀌면 즉시 강제 일시정지
        .onChange(of: currentStep) { _ in
            viewModel.forcePause()      // 꼭 멈추고
            // viewModel.playFromStart() // 다음 Step 입장 시 매번 처음부터 자동 재생하고 싶으면 이 줄 사용
        }
    }
}
