import SwiftUI
import AVFoundation

struct ConversationView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var visibleMessages: [ConversationMessage] = []
    @State private var allMessagesShown = false
    @State private var showKeywordPopup = false
    @State private var showKeywordsSheet = false   // ✅ 핵심단어 시트 표시 여부

    private let synthesizer = AVSpeechSynthesizer()

    // 예시 데이터 (한 문장 = 한 말풍선)
    private let allMessages: [ConversationMessage] = [
        ConversationMessage(
            id: 1,
            japanese: "こんにちは！はじめまして。",
            korean: "안녕하세요! 처음 뵙겠습니다.",
            isUser: false,
            furigana: [
                FuriganaUnit(text: "今", furigana: "こん"),
                FuriganaUnit(text: "日", furigana: "にち"),
                FuriganaUnit(text: "は", furigana: nil),
                FuriganaUnit(text: "！", furigana: nil),
                FuriganaUnit(text: "初めまして", furigana: "はじめまして"),
                FuriganaUnit(text: "。", furigana: nil)
            ]
        ),
        ConversationMessage(
            id: 2,
            japanese: "こちらこそ、よろしくお願いします！",
            korean: "저야말로 잘 부탁드립니다!",
            isUser: true,
            furigana: [
                FuriganaUnit(text: "こちらこそ", furigana: nil),
                FuriganaUnit(text: "、", furigana: nil),
                FuriganaUnit(text: "よろしく", furigana: nil),
                FuriganaUnit(text: "お願いします", furigana: "おねがいします"),
                FuriganaUnit(text: "！", furigana: nil)
            ]
        ),
        ConversationMessage(
            id: 3,
            japanese: "どこから来ましたか？",
            korean: "어디에서 오셨나요?",
            isUser: false,
            furigana: [
                FuriganaUnit(text: "どこ", furigana: nil),
                FuriganaUnit(text: "から", furigana: nil),
                FuriganaUnit(text: "来ました", furigana: "きました"),
                FuriganaUnit(text: "か？", furigana: nil)
            ]
        ),
        ConversationMessage(
            id: 4,
            japanese: "ソウルから来ました！",
            korean: "서울에서 왔어요!",
            isUser: true,
            furigana: [
                FuriganaUnit(text: "ソウル", furigana: nil),
                FuriganaUnit(text: "から", furigana: nil),
                FuriganaUnit(text: "来ました", furigana: "きました"),
                FuriganaUnit(text: "！", furigana: nil)
            ]
        )
    ]

    var body: some View {
        ZStack(alignment: .bottom) {
            // 배경
            LinearGradient(
                colors: [Color(red: 255/255, green: 220/255, blue: 230/255), .white],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                header
                Divider().opacity(0.2)
                messagesArea
            }

            // 하단 고정 팝업
            if showKeywordPopup {
                BottomActionPopup(
                    title: "핵심단어 보러가기",
                    subtitle: "오늘 대화에서 핵심단어를 복습해요",
                    actionTitle: "열기",
                    onTap: {                      // ✅ 팝업 버튼 터치 시 시트 열기
                        showKeywordsSheet = true
                    }
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
            }
        }
        // ✅ 핵심: 시트가 닫히면 이 화면을 Pop → HomeView로 복귀
        .sheet(isPresented: $showKeywordsSheet, onDismiss: {
            dismiss()
        }) {
            NavigationStack {
                KeywordsScreen()  // 이 안에서 저장 후 dismiss()만 호출하면 됨
            }
        }
        .onAppear { showMessagesSequentially() }
    }

    // MARK: Header
    private var header: some View {
        HStack {
            Text("오늘의 회화").font(.system(size: 20, weight: .semibold))
            Spacer()
            Text(allMessagesShown ? "음성 버튼 사용 가능" : "말풍선 표시 중…")
                .font(.footnote)
                .foregroundColor(allMessagesShown ? .green : .gray)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    // MARK: Messages
    private var messagesArea: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 20) {
                    ForEach(visibleMessages) { msg in
                        ConversationBubbleView(
                            message: msg,
                            voiceEnabled: allMessagesShown,
                            onSpeak: { speak(message: msg) }
                        )
                        .id(msg.id)
                        .transition(.move(edge: msg.isUser ? .trailing : .leading).combined(with: .opacity))
                        .animation(.easeOut(duration: 0.25), value: visibleMessages.count)
                    }
                }
                .padding(.top, 12)
            }
            .onChange(of: visibleMessages.count) { _ in
                if let last = visibleMessages.last {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }
        }
    }

    // MARK: Sequential show (간격 넉넉히)
    private func showMessagesSequentially() {
        visibleMessages = []
        allMessagesShown = false
        showKeywordPopup = false

        Task {
            for (i, msg) in allMessages.enumerated() {
                try? await Task.sleep(nanoseconds: 900_000_000) // 0.9초 간격
                withAnimation(.spring(response: 0.32, dampingFraction: 0.88)) {
                    visibleMessages.append(msg)
                }
                if i == allMessages.count - 1 {
                    try? await Task.sleep(nanoseconds: 250_000_000)
                    allMessagesShown = true
                    try? await Task.sleep(nanoseconds: 300_000_000)
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                        showKeywordPopup = true
                    }
                }
            }
        }
    }

    // MARK: TTS
    private func speak(message: ConversationMessage) {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        let u = AVSpeechUtterance(string: message.japanese)
        u.voice = AVSpeechSynthesisVoice(language: "ja-JP")
        u.rate = AVSpeechUtteranceDefaultSpeechRate * 0.9
        synthesizer.speak(u)
    }
}

// 그대로 유지
struct BottomActionPopup: View {
    var title: String
    var subtitle: String
    var actionTitle: String
    var onTap: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(.black)

            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.gray)

            Button(action: onTap) {
                Text(actionTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        Color(red: 255/255, green: 107/255, blue: 129/255) // #FF6B81
                    )
                    .cornerRadius(12)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
    }
}
