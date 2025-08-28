import SwiftUI

struct CompletionView: View {
    var onRestart: () -> Void
    var onExit: () -> Void
    
    var body: some View {
        ZStack {
            Color(hex: "#FFDCDC").ignoresSafeArea()

            VStack(spacing: 20) {
                Spacer()

                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .foregroundColor(Color(red: 255/255, green: 107/255, blue: 129/255))

                Text("학습 완료!")
                    .font(.largeTitle).fontWeight(.bold)
                    .foregroundColor(.black)

                Spacer()

                VStack(spacing: 12) {
                    AppButton(
                        title: "처음으로 돌아가기",
                        backgroundColor: Color(red: 255/255, green: 107/255, blue: 129/255),
                        action: onRestart
                    )
                    AppButton(
                        title: "메인으로 돌아가기",
                        backgroundColor: .black,
                        action: onExit
                    )
                }
                .padding(.horizontal)
                .padding(.bottom, 28)
            }
        }
        .transition(.opacity)
        .toolbar(.hidden, for: .navigationBar)

    }
}

extension Color {
    init(hex: String) {
        let s = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        let scanner = Scanner(string: s.hasPrefix("#") ? String(s.dropFirst()) : s)
        var rgb: UInt64 = 0; _ = scanner.scanHexInt64(&rgb)
        self.init(
            red: Double((rgb >> 16) & 0xFF) / 255.0,
            green: Double((rgb >> 8) & 0xFF) / 255.0,
            blue: Double(rgb & 0xFF) / 255.0
        )
    }
}
