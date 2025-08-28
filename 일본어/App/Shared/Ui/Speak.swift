import AVFoundation

func speak(_ text: String) {
    let utterance = AVSpeechUtterance(string: text)
    utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
    utterance.rate = 0.45

    let synthesizer = AVSpeechSynthesizer()
    synthesizer.speak(utterance)
}
