import SwiftUI

// MARK: - Model
struct LearningOverview {
    var todayProgress: Double
    var totalProblems: Int
    var todayLearnedSeconds: Int
    var minutesLearnedTotal: Int
}

struct LearningOverviewView: View {
    var stats: LearningOverview
    
    var onStartToday: (() -> Void)? = nil

    @State private var segment: Segment = .history
    enum Segment: String, CaseIterable { case history = "학습내역", allWords = "모든 어휘" }

    struct DayStat: Identifiable {
        let id = UUID()
        let label: String
        let newWords: Int
        let reviewWords: Int
        let correctness: Double
    }

    private let chartData: [DayStat] = [
        .init(label: "16일 전",     newWords: 4, reviewWords: 5, correctness: 0.62),
        .init(label: "2025-08-06", newWords: 7, reviewWords: 4, correctness: 0.78),
        .init(label: "오늘",        newWords: 6, reviewWords: 7, correctness: 0.55),
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                HStack { Spacer()
                    Text("어휘 학습 정보")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(.black.opacity(0.85))
                    Spacer()
                }
                .padding(.top, 8)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                    StatTile(icon: "trophy.fill", iconTint: .brandPink, bgTint: .brandLight2,
                             title: "학습 달성률",
                             value: stats.todayProgress == 0 ? " - " : "\(Int(stats.todayProgress*100))%")
                    StatTile(icon: "note.text", iconTint: .brandPink, bgTint: .brandLight2,
                             title: "총 학습 문제", value: "\(stats.totalProblems)개")
                    StatTile(icon: "clock.fill", iconTint: .brandPink, bgTint: .brandLight2,
                             title: "오늘 학습 시간", value: secondsToMinuteSecond(stats.todayLearnedSeconds))
                    StatTile(icon: "timer", iconTint: .brandPink, bgTint: .brandLight2,
                             title: "총 학습 시간", value: "\(stats.minutesLearnedTotal)분 7초")
                }

                VStack(spacing: 10) {
                    Picker("", selection: $segment) {
                        ForEach(Segment.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                    }
                    .pickerStyle(.segmented)

                    HStack(spacing: 14) {
                        Legend(color: .brandPink.opacity(0.85), label: "새로 배운 문장")
                        Legend(color: .brandPink.opacity(0.28), label: "복습 문장")
                        Legend(color: .gray.opacity(0.9), label: "복습 정답률")
                        Spacer()
                    }
                    .font(.caption)
                    .padding(.horizontal, 4)
                }

                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.08), radius: 8, y: 3)

                    VStack(spacing: 12) {
                        GeometryReader { geo in
                            let maxBar = max(chartData.map { max($0.newWords, $0.reviewWords) }.max() ?? 1, 1)
                            let maxHeight = geo.size.height - 36
                            let count = chartData.count

                            ZStack {
                                ForEach(0..<4) { i in
                                    let y = 12 + (maxHeight * CGFloat(i) / 3.0)
                                    Path { p in
                                        p.move(to: CGPoint(x: 0, y: y))
                                        p.addLine(to: CGPoint(x: geo.size.width, y: y))
                                    }
                                    .stroke(Color.gray.opacity(0.12), lineWidth: 1)
                                }

                                Path { path in
                                    for (i, d) in chartData.enumerated() {
                                        let x = geo.size.width * (CGFloat(i) / CGFloat(max(count - 1, 1)))
                                        let y = 12 + maxHeight * (1 - CGFloat(d.correctness))
                                        if i == 0 { path.move(to: CGPoint(x: x, y: y)) }
                                        else { path.addLine(to: CGPoint(x: x, y: y)) }
                                    }
                                }
                                .stroke(.gray, style: StrokeStyle(lineWidth: 2, lineJoin: .round))

                                ForEach(Array(chartData.enumerated()), id: \.offset) { i, d in
                                    let x = geo.size.width * (CGFloat(i) / CGFloat(max(count - 1, 1)))
                                    let y = 12 + maxHeight * (1 - CGFloat(d.correctness))
                                    Circle().fill(.gray).frame(width: 6, height: 6).position(x: x, y: y)
                                }

                                HStack(alignment: .bottom, spacing: (geo.size.width - 56) / CGFloat(count) - 28) {
                                    ForEach(chartData) { d in
                                        let h = maxHeight * CGFloat(max(d.newWords, d.reviewWords)) / CGFloat(maxBar)
                                        let unit: CGFloat = max(20, min(24, (geo.size.width / CGFloat(count)) * 0.22))
                                        ZStack(alignment: .bottom) {
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(Color.brandPink.opacity(0.28))
                                                .frame(width: unit, height: h * CGFloat(d.reviewWords) / CGFloat(max(d.newWords, d.reviewWords)))
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(Color.brandPink.opacity(0.85))
                                                .frame(width: unit, height: h * CGFloat(d.newWords) / CGFloat(max(d.newWords, d.reviewWords)))
                                        }
                                    }
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                                .padding(.horizontal, 28)
                                .padding(.bottom, 18)
                            }
                        }
                        .frame(height: 190)

                        HStack {
                            ForEach(chartData) { d in
                                Text(d.label).font(.caption2).foregroundStyle(.gray)
                                if d.id != chartData.last?.id { Spacer() }
                            }
                        }
                        .padding(.horizontal, 28)
                        .padding(.bottom, 6)
                    }
                    .padding(.vertical, 8)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 280)
            }
            .padding(16)
        }
        .background(Color.brandPaper.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) { Text("어휘 학습 정보").font(.headline) }
        }
    }

    private func secondsToMinuteSecond(_ secs: Int) -> String {
        let m = secs / 60
        let s = secs % 60
        return "\(m)분 \(s)초"
    }
}

// MARK: - Components
private struct StatTile: View {
    let icon: String
    let iconTint: Color
    let bgTint: Color
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(iconTint)
                .frame(width: 32, height: 32)
                .background(bgTint)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(.caption).foregroundStyle(.secondary)
                Text(value).font(.system(size: 22, weight: .bold)).foregroundStyle(.black.opacity(0.9))
            }
            Spacer()
        }
        .padding(14)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.black.opacity(0.05), lineWidth: 1))
        .shadow(color: .black.opacity(0.04), radius: 3, y: 1)
    }
}

private struct Legend: View {
    let color: Color; let label: String
    var body: some View {
        HStack(spacing: 6) { Circle().fill(color).frame(width: 8, height: 8); Text(label) }
    }
}

// MARK: - Colors
extension Color {
    static let brandPink   = Color(hexString: "#FF6F8D")
    static let brandLight2 = Color(hexString: "#FFE2E6")
    static let brandPaper  = Color(hexString: "#FFF7F4")

    init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a,r,g,b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a,r,g,b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a,r,g,b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a,r,g,b) = (255,255,255,255)
        }
        self.init(.sRGB, red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255, opacity: Double(a)/255)
    }
}
