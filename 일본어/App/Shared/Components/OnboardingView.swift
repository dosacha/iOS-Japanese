// OnboardingView.swift
import SwiftUI
import KakaoSDKUser
import GoogleSignIn
import FirebaseCore
import FirebaseAuth

struct OnboardingView: View {
    @EnvironmentObject var appState: AppState
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var errorMessage = ""
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Text("ようこそ!")
                .font(.system(size: 40, weight: .bold))
            
            Text("이 앱은 듣기부터 작문까지\n일본어를 단계별로 학습할 수 있어요.")
                .font(.title3)
                .multilineTextAlignment(.center)
                .padding()
            
            if isLoading {
                ProgressView("로그인 중입니다...")
                    .padding()
            }
            
            Spacer()
            
            // MARK: - 카카오 로그인
            Button(action: handleKakaoLogin) {
                HStack {
                    Image(systemName: "message.fill")
                    Text("카카오로 시작하기")
                        .fontWeight(.bold)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.yellow)
                .foregroundColor(.black)
                .cornerRadius(10)
                .padding(.horizontal)
            }
            
            // MARK: - 구글 로그인
            Button(action: handleGoogleLogin) {
                HStack {
                    Image(systemName: "globe")
                    Text("구글로 시작하기")
                        .fontWeight(.bold)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal)
            }
            
            Spacer()
        }
        .padding()
        .alert("로그인 실패", isPresented: $showAlert) {
            Button("확인", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    // MARK: - 카카오 로그인 처리
    private func handleKakaoLogin() {
        isLoading = true
        
        if UserApi.isKakaoTalkLoginAvailable() {
            UserApi.shared.loginWithKakaoTalk { (_, error) in
                handleLoginResult(error: error)
            }
        } else {
            UserApi.shared.loginWithKakaoAccount { (_, error) in
                handleLoginResult(error: error)
            }
        }
    }
    
    // MARK: - 구글 로그인 처리
    private func handleGoogleLogin() {
        isLoading = true
        
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            showError("Firebase clientID 가 없다.")
            return
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            showError("루트 ViewController 를 찾을 수 없다.")
            return
        }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
            if let error = error {
                showError("구글 로그인 실패: \(error.localizedDescription)")
                return
            }
            
            // FirebaseAuth 연동 예시
            /*
             guard let idToken = result?.user.idToken?.tokenString,
             let accessToken = result?.user.accessToken.tokenString else {
             showError("Google 토큰을 가져오지 못했다.")
             return
             }
             let credential = GoogleAuthProvider.credential(withIDToken: idToken,
             accessToken: accessToken)
             Auth.auth().signIn(with: credential) { _, error in
             if let error = error {
             showError("Firebase 로그인 실패: \(error.localizedDescription)")
             return
             }
             completeLogin()
             }
             */
            
            print("✅ 구글 로그인 성공: \(result?.user.profile?.name ?? "알 수 없음")")
            completeLogin()
        }
    }
    
    // MARK: - 공통 로그인 결과 처리
    private func handleLoginResult(error: Error?) {
        if let error = error {
            showError("카카오 로그인 실패: \(error.localizedDescription)")
        } else {
            print("✅ 카카오 로그인 성공")
            completeLogin()
        }
    }
    
    private func completeLogin() {
        isLoading = false
        appState.markLoggedIn()   // ✅ 전역 로그인 상태 + didLoginOnce 저장
    }
    
    private func showError(_ message: String) {
        isLoading = false
        errorMessage = message
        showAlert = true
    }
}
