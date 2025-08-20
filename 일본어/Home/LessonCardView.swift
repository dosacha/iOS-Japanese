import SwiftUI

// MARK: - 오늘의 장면 학습 카드 (버튼 그림자 제거 + 가운데 정렬)
struct LessonCardView: View {
    var action: () -> Void

    // 색상 프리셋
    private let cardPinkTop    = Color(red: 1.00, green: 0.92, blue: 0.94) // 연핑크 상단
    private let cardPinkBottom = Color(red: 1.00, green: 0.88, blue: 0.90) // 연핑크 하단
    private let buttonFill     = Color(red: 1.00, green: 0.97, blue: 0.94) // 버튼 베이지 톤

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            // 상단 타이틀
            Text("오늘의 학습")
                .font(.subheadline).bold()
                .foregroundColor(.black.opacity(0.7))

            // 메인 콘텐츠 (좌: 타겟 이미지, 우: 진행률 링)
            HStack(spacing: 16) {
                Image("target") // Assets에 'target' 추가
                    .resizable()
                    .scaledToFit()
                    .frame(width: 140, height: 140)

                Spacer(minLength: 0)

                ZStack {
                    Circle()
                        .stroke(Color.black.opacity(0.12), lineWidth: 12)
                        .frame(width: 116, height: 116)

                    Text("0%")
                        .font(.system(size: 28, weight: .heavy, design: .rounded))
                        .foregroundColor(.black)
                }
            }

            // 시작하기 버튼: 가운데 정렬 + 그림자 제거
            HStack {
                Spacer()
                Button(action: action) {
                    HStack(spacing: 10) {
                        Image(systemName: "play.fill")
                            .font(.headline)
                            .foregroundColor(.gray.opacity(0.9))
                        Text("시작하기")
                            .font(.system(size: 22, weight: .heavy, design: .rounded))
                            .foregroundColor(.black)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .frame(minWidth: 220) // 필요시 버튼 너비 고정 느낌
                    .background(buttonFill)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Color.black.opacity(0.08), lineWidth: 1)
                    )
                    // 🔻 그림자 제거
                    //.shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
                }
                .buttonStyle(.plain)
                Spacer()
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 255/255, green: 183/255, blue: 198/255),
                            Color(red: 255/255, green: 238/255, blue: 241/255)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        )
        .contentShape(Rectangle())
    }
}
