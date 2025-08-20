// LottieView.swift

import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    var animationName: String
    var loopMode: LottieLoopMode = .loop
    @Binding var isPlaying: Bool

    class Coordinator {
        var animationView: LottieAnimationView?

        init(_ parent: LottieView) {
            animationView = LottieAnimationView(name: parent.animationName)
            animationView?.loopMode = parent.loopMode
            animationView?.contentMode = .scaleAspectFit
        }

        func update(isPlaying: Bool) {
            guard let animationView = animationView else { return }
            if isPlaying {
                animationView.play()
            } else {
                animationView.stop()
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    func makeUIView(context: Context) -> UIView {
        let containerView = UIView(frame: .zero)
        if let animationView = context.coordinator.animationView {
            animationView.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(animationView)
            NSLayoutConstraint.activate([
                animationView.widthAnchor.constraint(equalTo: containerView.widthAnchor),
                animationView.heightAnchor.constraint(equalTo: containerView.heightAnchor),
                animationView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
                animationView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
            ])
        }
        return containerView
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.update(isPlaying: isPlaying)
    }
}
