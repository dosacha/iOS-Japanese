import SwiftUI
import UIKit

struct MainView: View {
    @State private var selectedTab: Int = 0

    init() {
        // 탭바 불투명 + 흰 배경 (배경 어둡게 제거)
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.white
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            // 홈
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Label("홈", systemImage: "house")
            }
            .tag(0)

            // 단어장
            NavigationStack {
                VocabularyView()
            }
            .tabItem {
                Label("단어장", systemImage: "book")
            }
            .tag(1)

            // 복습
            NavigationStack {
                ReviewView()
            }
            .tabItem {
                Label("복습", systemImage: "flame")
            }
            .tag(2)

            // 프로필
            NavigationStack {
                ProfileView()
            }
            .tabItem {
                Label("프로필", systemImage: "person")
            }
            .tag(3)
        }
        // 선택된 아이콘만 로즈핑크(#FF6B81)로, 비선택 아이콘은 iOS 기본 회색
        .tint(Color(red: 1.0, green: 0.42, blue: 0.51))
    }
}
