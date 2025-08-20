import SwiftUI

/// 한 문장 = 한 개의 말풍선
struct ConversationBubbleView: View {
    let message: ConversationMessage
    let voiceEnabled: Bool
    let onSpeak: () -> Void

    private var bubbleColor: Color {
        message.isUser ? .white : Color(red: 243/255, green: 244/255, blue: 248/255)
    }

    // GeometryReader 없이 안정적인 최대 폭 계산
    private var maxBubbleWidth: CGFloat {
        let screen = UIScreen.main.bounds.width
        let horizontalSafe: CGFloat = 24 + 32 // 좌우 padding + 반대쪽 여유
        let maxWidth = screen - (horizontalSafe * 2)
        return min(maxWidth, 500) // 태블릿 상한선
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if message.isUser { Spacer(minLength: 32) }

            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 8) {

                // ✅ 한 문장을 하나의 말풍선으로
                FuriganaTextView(
                    units: message.furigana,
                    tokenSpacing: 6,
                    lineSpacing: 8,
                    hAlignment: message.isUser ? .trailing : .leading
                )
                .padding(.vertical, 10)
                .padding(.horizontal, 12)
                .background(bubbleColor)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.black.opacity(0.04), lineWidth: message.isUser ? 0.5 : 0)
                )
                .frame(maxWidth: maxBubbleWidth,
                       alignment: message.isUser ? .trailing : .leading)

                // 음성 버튼
                HStack(spacing: 6) {
                    Button(action: {
                        if voiceEnabled { onSpeak() }
                    }) {
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.footnote)
                            .foregroundColor(.white)
                            .padding(6)
                            .background(
                                Circle().fill(
                                    voiceEnabled
                                    ? Color(red: 255/255, green: 107/255, blue: 129/255) // #FF6B81
                                    : Color.gray.opacity(0.5)
                                )
                            )
                    }
                    .buttonStyle(.plain)
                    .disabled(!voiceEnabled)
                    .opacity(voiceEnabled ? 1 : 0.6)
                }

                // 한국어 번역
                Text(message.korean)
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(message.isUser ? .trailing : .leading)
            }
            .frame(maxWidth: maxBubbleWidth,
                   alignment: message.isUser ? .trailing : .leading)

            if !message.isUser { Spacer(minLength: 32) }
        }
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity, alignment: message.isUser ? .trailing : .leading)
    }
}
