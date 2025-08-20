import SwiftUI

struct HomeView: View {
    @State private var isShowingLearningView = false
    @State private var isShowingConversation = false
    @State private var stats = LearningStats.preview

    // 기초 다지기 네비 상태
    @State private var goHiragana = false
    @State private var goKatakana = false

    // 공통 배경 그라데이션
    private let bgGradient = LinearGradient(
        colors: [Color(red: 255/255, green: 220/255, blue: 230/255), .white],
        startPoint: .top, endPoint: .bottom
    )

    init() {
        // 네비게이션바를 투명하게
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        appearance.shadowColor = .clear
        appearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().tintColor = .black
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // 화면 전체 그라데이션
                bgGradient.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 18) {
                        // 상단 헤더
                        HeaderView(username: "환동이", streakCount: 3)
                            .padding(.top, 8)

                        // 오늘의 학습
                        SectionHeader(title: "오늘의 학습", systemImage: "book.fill")
                        LessonCardView {
                            isShowingLearningView = true
                        }

                        // 오늘의 회화
                        SectionHeader(title: "오늘의 회화", systemImage: "text.bubble.fill")
                        ConversationCardLeftAligned {
                            isShowingConversation = true
                        }

                        SectionHeader(title: "학습정보", systemImage: "chart.bar.xaxis")
                        NavigationLink {
                            LearningOverviewView(
                                stats: LearningOverview(
                                    todayProgress: stats.todayProgress,
                                    totalProblems: stats.totalProblems,
                                    todayLearnedSeconds: stats.todayLearnedMinutes * 60, // 분 → 초 변환
                                    minutesLearnedTotal: stats.minutesLearnedTotal
                                ),
                                onStartToday: { isShowingLearningView = true }
                            )
                        } label: {
                            LearningInfoCardView(stats: stats)
                        }
                        .buttonStyle(.plain)

                        //기초 다지기 (버튼 2개)
                        KanaSectionView(
                            onTapHiragana: { goHiragana = true },
                            onTapKatakana: { goKatakana = true }
                        )

                        //네비게이션 링크 (히라가나)
                        NavigationLink("", isActive: $goHiragana) {
                            KanaTableView(
                                title: "ひらがな",
                                gridData: KanaDataProvider.getData(for: .hiragana)
                            )
                        }
                        .hidden()

                        //네비게이션 링크 (가타카나)
                        NavigationLink("", isActive: $goKatakana) {
                            KanaTableView(
                                title: "カタカナ",
                                gridData: KanaDataProvider.getData(for: .katakana)
                            )
                        }
                        .hidden()
                    }
                    .padding(.horizontal, 18)
                    .padding(.bottom, 24)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            // iOS 16+
            .toolbarBackground(.hidden, for: .navigationBar)
            // iOS 17+
            .toolbarBackgroundVisibility(.hidden, for: .navigationBar)
            .fullScreenCover(isPresented: $isShowingLearningView) {
                LearningFlowView()
            }
            .sheet(isPresented: $isShowingConversation) {
                ConversationView()
            }
        }
    }
}

fileprivate struct SectionHeader: View {
    let title: String
    let systemImage: String
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: systemImage)
                .font(.subheadline)
                .foregroundStyle(Color(red: 232/255, green: 92/255, blue: 116/255))
            Text(title)
                .font(.subheadline).bold()
                .foregroundStyle(.black.opacity(0.75))
            Spacer()
        }
        .padding(.top, 6)
    }
}

// 오늘의 회화 카드 디자인
fileprivate struct ConversationCardLeftAligned: View {
    var onTapLearn: () -> Void
    var cardMinHeight: CGFloat = 130

    var body: some View {
        VStack(alignment: .leading, spacing: 8) { // ✅ 전체 간격 좁힘
            // 한국어 문장 (왼쪽 정렬)
            Text("오늘은 기분이 좋아요")
                .font(.subheadline)
                .foregroundStyle(.black.opacity(0.6))
                .multilineTextAlignment(.leading)

            // 일본어 문장 (왼쪽 정렬)
            Text("今日は 気分が いいです。")
                .font(.title2).bold()
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
                .multilineTextAlignment(.leading)

            // 학습하기 버튼 (왼쪽 정렬)
            Button(action: onTapLearn) {
                HStack(spacing: 6) { // ✅ 버튼 내부 간격도 약간 좁힘
                    Image(systemName: "play.fill")
                    Text("학습하기")
                        .fontWeight(.semibold)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.white)
                .foregroundStyle(.black.opacity(0.85))
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(Color.black.opacity(0.15), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
            }
            .buttonStyle(.plain)
        }
        .padding(20)
        .frame(maxWidth: .infinity, minHeight: cardMinHeight, alignment: .leading)
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
        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 8)
        .contentShape(Rectangle())
    }
}
