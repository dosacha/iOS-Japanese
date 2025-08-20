// JStudyApp.swift
import SwiftUI
import KakaoSDKAuth
import GoogleSignIn

@main
struct JStudyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var appState = AppState()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            Group {
                if appState.isChecking {
                    // 세션 점검 중에는 깜빡임 방지용 빈 화면/스플래시
                    Color.black.ignoresSafeArea()
                } else if appState.isLoggedIn {
                    NavigationStack { MainView() }
                } else {
                    OnboardingView()
                }
            }
            .environmentObject(appState)
            .task {
                appState.refreshSession()              // 첫 구동 시 세션 복구
            }
            .onChange(of: scenePhase) { phase in
                if phase == .active {
                    appState.refreshSession()          // 포그라운드 복귀 시 재확인
                }
            }
            .onOpenURL { url in                        // URL 핸들링(보강)
                if AuthApi.isKakaoTalkLoginUrl(url) {
                    _ = AuthController.handleOpenUrl(url: url)
                    return
                }
                if GIDSignIn.sharedInstance.handle(url) {
                    return
                }
            }
        }
    }
}
