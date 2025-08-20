import SwiftUI


struct FuriganaTextView: View {
    let units: [FuriganaUnit]
    var tokenSpacing: CGFloat = 6
    /// 줄과 줄 사이에 후리가나가 들어갈 여유 공간 (본문 기준 줄 높이에 추가 여백)
    var lineSpacing: CGFloat = 12
    /// 좌/우 정렬(말풍선 정렬 방향에 맞춤)
    var hAlignment: HorizontalAlignment = .leading

    private var bubbleAlignment: Alignment {
        hAlignment == .trailing ? .trailing : .leading
    }

    var body: some View {
        FlowWrapLayout(tokenSpacing: tokenSpacing, lineSpacing: lineSpacing) {
            ForEach(units, id: \.self) { u in
                TokenView(unit: u)
                    .fixedSize() // 토큰 내부 줄바꿈 금지
            }
        }
        // 부모가 주는 폭 안에서만 줄바꿈되도록
        .frame(maxWidth: CGFloat.infinity, alignment: bubbleAlignment)
    }
}

/// 본문을 기준으로 사이즈가 결정되고, 후리가나는 overlay로 얹힘
private struct TokenView: View {
    let unit: FuriganaUnit

    // 후리가나 위치 조정 (값을 더 크게 하면 본문과 간격이 넓어짐)
    private let furiganaYOffset: CGFloat = -12
    private let topPaddingForFurigana: CGFloat = 14 // 말풍선 두께도 조금 더 확보

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .top) {
                // 본문 텍스트
                Text(unit.text)
                    .font(.system(size: 17))

                // 후리가나
                if let f = unit.furigana, !f.isEmpty {
                    Text(f)
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                        .fixedSize()
                        .offset(y: furiganaYOffset) // 간격 조정
                        .allowsHitTesting(false)
                }
            }
        }
        .padding(.top, topPaddingForFurigana) // 히라가나 공간 확보
        .fixedSize()
    }
}

struct FlowWrapLayout: Layout {
    let tokenSpacing: CGFloat
    let lineSpacing: CGFloat

    init(tokenSpacing: CGFloat, lineSpacing: CGFloat) {
        self.tokenSpacing = tokenSpacing
        self.lineSpacing = lineSpacing
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? 0
        var x: CGFloat = 0
        var y: CGFloat = 0
        var lineHeight: CGFloat = 0

        for sv in subviews {
            let sz = sv.sizeThatFits(.unspecified)

            if x > 0, maxWidth > 0, x + tokenSpacing + sz.width > maxWidth {
                // 줄바꿈
                x = 0
                y += lineHeight + lineSpacing
                lineHeight = 0
            }
            if x > 0 { x += tokenSpacing }
            x += sz.width
            lineHeight = max(lineHeight, sz.height)
        }

        y += lineHeight
        return CGSize(width: maxWidth, height: y)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let maxWidth = bounds.width
        var x: CGFloat = 0
        var y: CGFloat = 0
        var lineHeight: CGFloat = 0

        for sv in subviews {
            let sz = sv.sizeThatFits(.unspecified)

            if x > 0, maxWidth > 0, x + tokenSpacing + sz.width > maxWidth {
                // 줄바꿈
                x = 0
                y += lineHeight + lineSpacing
                lineHeight = 0
            }

            if x > 0 { x += tokenSpacing }
            let origin = CGPoint(x: bounds.minX + x, y: bounds.minY + y)
            sv.place(at: origin, proposal: ProposedViewSize(width: sz.width, height: sz.height))
            x += sz.width
            lineHeight = max(lineHeight, sz.height)
        }
    }

    typealias Cache = ()
}
