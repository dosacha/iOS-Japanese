// Step1_ListeningView.swift
import SwiftUI

struct Step1_ListeningView: View {
    var onComplete: () -> Void
    @ObservedObject var viewModel: PlayerViewModel

    var body: some View {
        RatioAnchoredButtonLayout(
            buttonYRatio: 0.90,
            buttonReservedHeight: 84,
            horizontalMargin: 16
        ) {
            VStack(spacing: 10) {
                Text("Step 1: 몰입해서 듣기")
                    .font(.title).fontWeight(.bold).foregroundColor(.black)
                    .padding(.top, 30)

                Text("자막 없이 장면에 집중하며 들어보세요.")
                    .font(.subheadline).foregroundStyle(.gray)

                Spacer().frame(height: 25)

                CustomAVPlayerView(player: viewModel.player)
                    .frame(height: 250)
                    .cornerRadius(20)
                    .padding(.horizontal, 16)

                HStack {
                    Text("배속: \(String(format: "%.1fx", viewModel.playbackRate))")
                        .font(.footnote).foregroundColor(.gray)
                    Slider(value: $viewModel.playbackRate, in: 0.5...2.0, step: 0.25)
                }
                .padding(.horizontal, 16)

                Spacer()
            }
            .onAppear { viewModel.play() }
            .onDisappear { viewModel.pause() } // 풀스크린 중이면 유지, 아니면 일시정지
            .transition(.asymmetric(insertion: .move(edge: .trailing),
                                    removal: .move(edge: .leading)))
        } button: {
            AppButton(title: "내용 파악 완료! 다음으로", action: onComplete)
        }
    }
}
