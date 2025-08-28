import SwiftUI
import KakaoSDKCommon
import KakaoSDKAuth
import GoogleSignIn
import FirebaseCore

// MARK: - 앱 델리게이트 (SDK 초기화 및 URL 핸들링)
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        // Firebase 초기화
        FirebaseApp.configure()
        
        // Kakao SDK 초기화
        KakaoSDK.initSDK(appKey: "5210a7642e95b931c26085b96a2c5ec6")

        return true
    }
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        // Kakao 로그인 처리
        if AuthApi.isKakaoTalkLoginUrl(url) {
            return AuthController.handleOpenUrl(url: url)
        }

        // Google 로그인 처리
        if GIDSignIn.sharedInstance.handle(url) {
            return true
        }

        return false
    }
}
