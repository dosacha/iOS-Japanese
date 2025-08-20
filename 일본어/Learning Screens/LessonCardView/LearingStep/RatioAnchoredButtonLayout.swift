// RatioAnchoredButtonLayout.swift
import SwiftUI

/// 화면 비율로 버튼을 고정 배치하는 공통 레이아웃
/// - buttonYRatio: 세로 위치 비율 (0.0~1.0)
/// - buttonReservedHeight: 콘텐츠가 버튼과 겹치지 않도록 확보할 하단 여유 높이
/// - horizontalMargin: 좌우 여백 (버튼 폭 계산에 사용)
struct RatioAnchoredButtonLayout<Content: View, ButtonView: View>: View {
    let buttonYRatio: CGFloat
    let buttonReservedHeight: CGFloat
    let horizontalMargin: CGFloat
    @ViewBuilder var content: () -> Content
    @ViewBuilder var button: () -> ButtonView

    init(
        buttonYRatio: CGFloat = 0.90,
        buttonReservedHeight: CGFloat = 84,
        horizontalMargin: CGFloat = 16,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder button: @escaping () -> ButtonView
    ) {
        self.buttonYRatio = buttonYRatio
        self.buttonReservedHeight = buttonReservedHeight
        self.horizontalMargin = horizontalMargin
        self.content = content
        self.button = button
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // 버튼 영역만큼만 바닥 여유 확보 (콘텐츠가 버튼 밑으로 숨지 않게)
                content()
                    .padding(.bottom, buttonReservedHeight + geo.safeAreaInsets.bottom)

                // 비율 위치 버튼: 레이아웃에 영향 X (겹쳐 놓기)
                button()
                    .frame(width: geo.size.width - horizontalMargin * 2)
                    .position(x: geo.size.width * 0.5,
                              y: geo.size.height * buttonYRatio)
                    .zIndex(1)
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .ignoresSafeArea(.keyboard) // 키보드 올라올 때 튐 방지
        }
    }
}
