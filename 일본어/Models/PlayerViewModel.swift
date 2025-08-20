// PlayerViewModel.swift
import AVKit

class PlayerViewModel: ObservableObject {
    @Published var playbackRate: Float = 1.0 {
        didSet { player.rate = playbackRate }
    }

    let player: AVPlayer
    private var isInFullscreen: Bool = false

    init() {
        if let url = Bundle.main.url(forResource: "ハイキュー北信介名言 [it3tKC0ycu4]", withExtension: "mp4") {
            self.player = AVPlayer(url: url)
        } else {
            self.player = AVPlayer()
        }

        // 전체화면 상태 감지(커스텀 뷰에서 보내는 노티로 대체 가능)
        NotificationCenter.default.addObserver(self, selector: #selector(enteredFullscreen), name: UIWindow.didBecomeVisibleNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(exitedFullscreen), name: UIWindow.didBecomeHiddenNotification, object: nil)
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    @objc private func enteredFullscreen()  { isInFullscreen = true }
    @objc private func exitedFullscreen()   { isInFullscreen = false }

    // 일반 재생
    func play() {
        player.play()
        player.rate = playbackRate
    }

    // 화면 전환 없이 사용자가 나갔다 돌아오는 등의 일반 상황에서:
    // 풀스크린 중이면 건드리지 않음(기존 동작 유지)
    func pause() {
        if !isInFullscreen { player.pause() }
    }

    // Step 전환/종료 시에는 무조건 멈춰야 함
    func forcePause() {
        player.pause()
    }

    // Step 전환 직전에 호출: 멈추고 처음으로 되감기
    func stopAndReset() {
        player.pause()
        player.seek(to: .zero, toleranceBefore: .zero, toleranceAfter: .zero)
    }

    // 필요 시: 다음 Step 진입 시 항상 처음부터 재생
    func playFromStart() {
        player.seek(to: .zero, toleranceBefore: .zero, toleranceAfter: .zero) { [weak self] _ in
            self?.play()
        }
    }
}
