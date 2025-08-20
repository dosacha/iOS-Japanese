import SwiftUI

struct KanaCellView: View {
    let character: KanaCharacter
    
    var body: some View {
        VStack(spacing: 5) {
            Text(character.kana)
                .font(.system(size: 36))
                .foregroundColor(.black)                  // 🔹 글씨 검정
            Text(character.pronunciation)
                .font(.footnote)
                .fontWeight(.medium)
                .foregroundColor(Color.black.opacity(0.6)) // 🔹 회색 보조 텍스트
        }
        .frame(minWidth: 0, maxWidth: .infinity)
        .frame(height: 80)
        .background(Color(red: 238/255, green: 238/255, blue: 238/255))// 🔹 버튼 배경회색
        .cornerRadius(6)         // 🔹 모서리 살짝 둥글게
    }
}
