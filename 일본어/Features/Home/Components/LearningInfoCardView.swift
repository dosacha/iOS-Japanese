import SwiftUI

struct LearningInfoCardView: View {
    let stats: LearningStats  // 실제 데이터 연결

    private let chartSize: CGFloat = 160        // 차트 정사각형 한 변
    private let gridLineCount: Int = 4          // 내부 가로 그리드 라인 수(수평선)


    private let barsLow:  [CGFloat] = [18, 26, 22, 24, 20, 22, 18]  // 하단(진분홍)
    private let barsHigh: [CGFloat] = [20, 18, 24, 40, 26, 44, 22]  // 상단(연분홍)
    private let lineY:    [CGFloat] = [68, 60, 72, 88, 82, 84, 83]  // 라인 차트 Y값(0~100 스케일)

    var body: some View {
        HStack(alignment: .center, spacing: 18) {

            
            ZStack {
                // 배경, 테두리
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(.white)
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(Color(red: 0.85, green: 0.85, blue: 0.88), lineWidth: 2)

                // 내부 그리드 (수평선)
                VStack(spacing: 0) {
                    ForEach(0..<gridLineCount+1, id: \.self) { _ in
                        Rectangle()
                            .fill(Color(red: 0.93, green: 0.93, blue: 0.95))
                            .frame(height: 1)
                        Spacer()
                    }
                }
                .padding(12)

                // 스택 막대
                GeometryReader { geo in
                    let w = geo.size.width
                    let h = geo.size.height
                    let contentInset: CGFloat = 12
                    let contentW = w - contentInset * 2
                    let contentH = h - contentInset * 2

                    let barCount = max(barsLow.count, barsHigh.count)
                    let gap: CGFloat = 8
                    let barWidth = (contentW - CGFloat(barCount - 1) * gap) / CGFloat(barCount)

                    // 막대들
                    HStack(alignment: .bottom, spacing: gap) {
                        ForEach(0..<barCount, id: \.self) { i in
                            let low  = min(max(barsLow[safe: i] ?? 0, 0), 100)
                            let high = min(max(barsHigh[safe: i] ?? 0, 0), 100)

                            VStack(spacing: 0) {
                                // 상단(연분홍)
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(Color(red: 1.0, green: 0.76, blue: 0.80)) // #FFC2CD
                                    .frame(width: barWidth,
                                           height: contentH * (high / 100.0))
                                // 하단(진분홍)
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(Color(red: 1.0, green: 0.42, blue: 0.51)) // #FF6B81
                                    .frame(width: barWidth,
                                           height: contentH * (low / 100.0))
                            }
                            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                        }
                    }
                    .frame(width: contentW, height: contentH, alignment: .bottom)
                    .position(x: w / 2, y: h / 2)

                    // 라인 차트 (회색 점선)
                    Path { path in
                        let xs = stride(from: 0, to: barCount, by: 1).map { CGFloat($0) }
                        let maxX = CGFloat(max(barCount - 1, 1))
                        func point(_ idx: Int) -> CGPoint {
                            let t = xs[idx] / maxX
                            let x = contentInset + t * contentW
                            let yVal = min(max(lineY[safe: idx] ?? 0, 0), 100)
                            let y = contentInset + contentH * (1 - yVal / 100.0)
                            return CGPoint(x: x, y: y)
                        }
                        guard barCount > 1 else { return }
                        path.move(to: point(0))
                        for i in 1..<barCount { path.addLine(to: point(i)) }
                    }
                    .stroke(style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                    .foregroundColor(Color(red: 0.75, green: 0.75, blue: 0.77)) // 회색

                    // 라인 포인트
                    ForEach(0..<max(barsLow.count, barsHigh.count), id: \.self) { i in
                        let maxX = CGFloat(max(barsLow.count - 1, 1))
                        let t = CGFloat(i) / maxX
                        let x = 12 + t * (geo.size.width - 24)
                        let yVal = min(max(lineY[safe: i] ?? 0, 0), 100)
                        let y = 12 + (geo.size.height - 24) * (1 - yVal / 100.0)

                        Circle()
                            .fill(Color(red: 0.83, green: 0.83, blue: 0.85))
                            .frame(width: 5, height: 5)
                            .position(x: x, y: y)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .padding(2) // 테두리와 컨텐츠 사이 여백
            }
            .frame(width: chartSize, height: chartSize)

            VStack(alignment: .leading, spacing: 14) {
                LegendRow(dot: .gray.opacity(0.6),  text: "복습정답률 :")
                LegendRow(dot: Color(red: 1.0, green: 0.76, blue: 0.80), text: "새로 배운 문장 :")
                LegendRow(dot: Color(red: 1.0, green: 0.42, blue: 0.51), text: "복습 문장 :")
                Spacer(minLength: 0)
            }
            .padding(.trailing, 6)
        }
        .padding(8)                            // 바깥 여백
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.0001)) // 빈 공간 탭도 인식
        .contentShape(Rectangle())
    }
}

fileprivate struct LegendRow: View {
    let dot: Color
    let text: String
    var body: some View {
        HStack(spacing: 8) {
            Circle().fill(dot).frame(width: 10, height: 10)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.black.opacity(0.75))
        }
    }
}

fileprivate extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
