import SwiftUI

// MARK: - 획순 표시 뷰 (화이트 카드 스타일)
struct StrokeOrderView: View {
    let character: String

    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                Text(character)
                    .font(.largeTitle)
                    .foregroundColor(.black)
                Circle()
                    .fill(Color.red)
                    .frame(width: 8, height: 8)
                    .offset(x: -5, y: -15)
            }
            ZStack {
                Text(character)
                    .font(.largeTitle)
                    .foregroundColor(.black)
                Circle()
                    .fill(Color.red)
                    .frame(width: 8, height: 8)
                    .offset(x: 5, y: 0)
            }
            ZStack {
                Text(character)
                    .font(.largeTitle)
                    .foregroundColor(.black)
                Circle()
                    .fill(Color.red)
                    .frame(width: 8, height: 8)
                    .offset(x: -10, y: 10)
            }
        }
        .padding()
        .background(Color.white) // 밝은 카드
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
    }
}
