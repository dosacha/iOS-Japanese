import SwiftUI

struct ProfileView: View {
    @State private var name: String = "환둥이"
    @State private var totalMinutes: Int = 94
    @State private var streakDays: Int = 5
    @State private var totalDays: Int = 9
    @State private var avatar: Image? = Image("profile")
    
    private let headerColor = Color(customHex: "#FFD6D6")
    private let panelColor  = Color(customHex: "#ECECEC")
    private let learnedDot  = Color(customHex: "#FFD6D6")
    private let normalDot   = Color(customHex: "#CFCFCF")
    private let todayDot    = Color(customHex: "#BDBDBD")
    
    var body: some View {
        ScrollView(showsIndicators: false) { // 스크롤 가능하게 변경
            VStack(spacing: 0) {
                Text("프로필 설정")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.black)
                    .padding(.top, 14)
                
                ZStack(alignment: .bottom) {
                    Color(customHex: "#FFE3E3")
                        .frame(height: 160)
                        .ignoresSafeArea(edges: .top)
                    
                    ZStack {
                        Circle()
                            .fill(Color(customHex: "#FFD6BA"))
                        if let avatar {
                            avatar
                                .resizable()
                                .scaledToFit()
                                .padding(3)
                        } else {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .padding(24)
                                .foregroundColor(.gray.opacity(0.6))
                        }
                    }
                    .frame(width: 120, height: 120)
                    .overlay(
                        Circle().stroke(Color.black.opacity(0.06), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0), radius: 8, y: 4)
                    .offset(y: 40)
                }
                .padding(.bottom, 40)
                
                HStack(spacing: 8) {
                    Text(name)
                        .font(.system(size: 24, weight: .heavy))
                        .foregroundColor(.black)
                    Button {
                    } label: {
                        Image(systemName: "pencil")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.gray)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, 8)
                
                StatsRow(
                    totalMinutes: totalMinutes,
                    streakDays: streakDays,
                    totalDays: totalDays
                )
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                CalendarView(
                    headerColor: headerColor,
                    panelColor: panelColor,
                    learnedDot: learnedDot,
                    normalDot: normalDot,
                    todayDot: todayDot
                )
                .padding(.top, 20)
                
                Spacer(minLength: 20)
            }
            .background(Color.white)
        }
        
    }
}

// MARK: - 통계 행 뷰
private struct StatsRow: View {
    let totalMinutes: Int
    let streakDays: Int
    let totalDays: Int
    
    var body: some View {
        HStack(spacing: 0) {
            StatItem(
                icon: "clock",
                title: "총 학습 시간",
                value: "\(totalMinutes)분"
            )
            
            Divider()
                .frame(width: 1, height: 72)
                .background(Color.black.opacity(0.1))
            
            StatItem(
                icon: "flame.fill",
                title: "연속 학습일",
                value: "\(streakDays)d"
            )
            
            Divider()
                .frame(width: 1, height: 72)
                .background(Color.black.opacity(0.1))
            
            StatItem(
                icon: "calendar",
                title: "누적 학습일",
                value: "\(totalDays)d"
            )
        }
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.06), radius: 6, y: 2)
        )
    }
}

private struct StatItem: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.gray.opacity(0.6))
            
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
            
            Text(value)
                .font(.system(size: 22, weight: .heavy))
                .foregroundColor(.black)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 12)
    }
}

// MARK: - 캘린더 뷰
struct CalendarView: View {
    let headerColor: Color
    let panelColor: Color
    let learnedDot: Color
    let normalDot: Color
    let todayDot: Color
    
    let days = Array(1...31)
    let highlightedDays: Set<Int> = [1, 2, 4, 5, 6, 7, 8]
    
    var body: some View {
        VStack(spacing: 0) {
            Text("8月")
                .font(.system(size: 24, weight: .bold))
                .frame(maxWidth: .infinity)
                .padding()
                .background(headerColor)
                .cornerRadius(8, corners: [.topLeft, .topRight])
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 12) {
                ForEach(0..<6, id: \.self) { row in
                    ForEach(0..<7, id: \.self) { column in
                        let dayIndex = row * 7 + column - 4
                        
                        if dayIndex >= 1 && dayIndex <= 31 {
                            Text("\(dayIndex)")
                                .frame(width: 36, height: 36)
                                .background(
                                    highlightedDays.contains(dayIndex) ? learnedDot : normalDot
                                )
                                .foregroundColor(.black)
                                .clipShape(Circle())
                        } else {
                            Text("")
                                .frame(width: 36, height: 36)
                        }
                    }
                }
            }
            .padding(.vertical, 16)
            .background(panelColor)
            .cornerRadius(8, corners: [.bottomLeft, .bottomRight])
        }
        .padding(.horizontal)
    }
}

// MARK: - HEX 컬러 확장
extension Color {
    init(customHex hex: String) {
        let s = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        let scanner = Scanner(string: s.hasPrefix("#") ? String(s.dropFirst()) : s)
        var rgb: UInt64 = 0
        _ = scanner.scanHexInt64(&rgb)
        
        self.init(
            red: Double((rgb >> 16) & 0xFF) / 255.0,
            green: Double((rgb >> 8) & 0xFF) / 255.0,
            blue: Double(rgb & 0xFF) / 255.0
        )
    }
}

// MARK: - 모서리 별 cornerRadius 확장
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
