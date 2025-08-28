// AppState.swift
import Foundation
import Combine
import KakaoSDKAuth
import KakaoSDKUser
import GoogleSignIn

@MainActor
final class AppState: ObservableObject {
    @Published var isLoggedIn = false
    @Published var isChecking = true

    // UserDefaults 로 대체
    private let didLoginOnceKey = "didLoginOnce"
    private var didLoginOnce: Bool {
        get { UserDefaults.standard.bool(forKey: didLoginOnceKey) }
        set { UserDefaults.standard.set(newValue, forKey: didLoginOnceKey) }
    }

    // 로그인 성공 시 호출
    func markLoggedIn() {
        didLoginOnce = true
        isLoggedIn = true
    }

    func refreshSession() {
        isChecking = true

        // 우리 앱에서 한 번도 로그인한 적 없다면 자동복구 하지 않음
        guard didLoginOnce else {
            self.isLoggedIn = false
            self.isChecking = false
            return
        }

        // 1) Kakao 토큰 유효성 확인
        if AuthApi.hasToken() {
            UserApi.shared.accessTokenInfo { _, error in
                if error == nil {
                    self.isLoggedIn = true
                    self.isChecking = false
                } else {
                    self.restoreGoogle()
                }
            }
            return
        }

        // 2) Google 복원
        if GIDSignIn.sharedInstance.hasPreviousSignIn() {
            restoreGoogle()
        } else {
            self.isLoggedIn = false
            self.isChecking = false
        }
    }

    private func restoreGoogle() {
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            self.isLoggedIn = (user != nil && error == nil)
            self.isChecking = false
        }
    }

    func logout() {
        isLoggedIn = false
        // 필요 시 didLoginOnce = false 로 초기화 가능
        // didLoginOnce = false
    }
}
