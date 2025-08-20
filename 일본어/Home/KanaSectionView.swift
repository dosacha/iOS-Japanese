import SwiftUI

struct KanaSectionView: View {
    var onTapHiragana: () -> Void
    var onTapKatakana: () -> Void

    // 원형 버튼 크기 및 폰트 크기
    private let circleSize: CGFloat = 150
    private let symbolFontSize: CGFloat = 84

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 타이틀
            HStack(spacing: 8) {
                Image(systemName: "checkmark.square.fill")
                    .font(.subheadline)
                    .foregroundStyle(Color(red: 232/255, green: 92/255, blue: 116/255)) // 색상
                Text("기초 다지기")
                    .font(.subheadline).bold()
                    .foregroundStyle(.black.opacity(0.75))
            }

            // 원형 버튼들
            HStack(spacing: 28) {
                Button(action: onTapHiragana) {
                    KanaCircleSymbol(
                        symbol: "あ",
                        circleSize: circleSize,
                        fontSize: symbolFontSize
                    )
                }
                .buttonStyle(.plain)

                Button(action: onTapKatakana) {
                    KanaCircleSymbol(
                        symbol: "ア",
                        circleSize: circleSize,
                        fontSize: symbolFontSize
                    )
                }
                .buttonStyle(.plain)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, 4)
        }
        .frame(maxWidth: .infinity)
    }
}

fileprivate struct KanaCircleSymbol: View {
    let symbol: String
    let circleSize: CGFloat
    let fontSize: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .frame(width: circleSize, height: circleSize)
                .overlay(
                    Circle()
                        .stroke(Color(red: 0.90, green: 0.90, blue: 0.92), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 6)

            Text(symbol)
                .font(.system(size: fontSize, weight: .bold, design: .rounded))
                .foregroundColor(.black)
                .minimumScaleFactor(0.6)
                .lineLimit(1)
        }
        .contentShape(Circle())
    }
}
