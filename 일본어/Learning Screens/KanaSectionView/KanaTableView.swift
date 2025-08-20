import SwiftUI

// MARK: - 히라가나/가타카나 표 뷰
struct KanaTableView: View {
    let title: String
    let gridData: [KanaGridItem]
    
    @State private var selectedCharacter: KanaCharacter?

    // 5열 고정
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 5)

    var body: some View {
        ZStack {
            // ✅ 전체 배경: 연핑크(#FFDADA)
            Color(red: 1.0, green: 0.8549, blue: 0.8549)
                .ignoresSafeArea()
            
            // 본문
            ScrollView {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(gridData) { item in
                        switch item {
                        case .character(let char):
                            Button {
                                withAnimation(.spring(response: 0.28, dampingFraction: 0.88)) {
                                    selectedCharacter = char
                                }
                            } label: {
                                KanaCellView(character: char)  // 🔹 버튼 타일(흰 배경+검정 글씨)
                            }

                        case .empty:
                            Rectangle()
                                .fill(Color.clear)
                                .frame(height: 80)
                        }
                    }
                }
                .padding()
            }
            // 선택 시 배경 살짝 블러
            .blur(radius: selectedCharacter == nil ? 0 : 4)
            .animation(.easeInOut(duration: 0.2), value: selectedCharacter != nil)

            // ✅ 팝업: 딤 + 카드 등장
            if let c = selectedCharacter {
                // 딤 배경
                Color.black.opacity(0.25)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.18)) { selectedCharacter = nil }
                    }

                // 상세 카드 (색상/폰트는 KanaDetailView 내에서 조정)
                KanaDetailView(character: c) {
                    withAnimation(.easeInOut(duration: 0.18)) { selectedCharacter = nil }
                }
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.95).combined(with: .opacity),
                    removal: .opacity
                ))
                .zIndex(1)
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
