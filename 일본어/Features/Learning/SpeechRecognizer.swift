// SpeechRecognizer.swift

// StringAlignment 유틸 사용 + 안전한 종료 처리 (idempotent finish/weak self/탭 상태 플래그)
// 중복 제거 버전: 정렬/정규화 로직은 StringAlignment.swift 의 것을 사용
// calculateSimilarity / similarityDetail 만 해당 유틸을 호출

import Foundation
import AVFoundation
import Speech

class SpeechRecognizer: NSObject, ObservableObject {
    private let audioEngine = AVAudioEngine()
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ja-JP"))!

    private var hasTapInstalled = false
    private var isFinishing = false

    @Published var isRecording = false
    @Published var recognizedText: String = ""

    override init() {
        super.init()
        SFSpeechRecognizer.requestAuthorization { status in
            if status != .authorized {
                print("음성 인식 권한이 없다.")
            }
        }
        AVAudioApplication.requestRecordPermission { granted in
            if !granted { print("마이크 권한이 없다.") }
        }
    }

    deinit {
        // 더 이상 UI 갱신 스케줄하지 않고 리소스만 정리
        if hasTapInstalled { audioEngine.inputNode.removeTap(onBus: 0) }
        recognitionTask?.cancel()
        request?.endAudio()
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    // MARK: - Recording

    func startRecording() {
        if audioEngine.isRunning { stopRecording(); return }

        // 이전 태스크 정리
        recognitionTask?.cancel()
        recognitionTask = nil
        request = nil
        isFinishing = false

        // 오디오 세션
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .measurement,
                                    options: [.defaultToSpeaker, .mixWithOthers])
            try session.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("AVAudioSession 설정 실패: \(error.localizedDescription)")
            cleanupAfterStop()
            return
        }

        // 요청
        let req = SFSpeechAudioBufferRecognitionRequest()
        req.shouldReportPartialResults = true
        if #available(iOS 13.0, *) { req.requiresOnDeviceRecognition = false }
        self.request = req

        // 입력 탭
        let input = audioEngine.inputNode
        let format = input.outputFormat(forBus: 0)
        input.removeTap(onBus: 0)
        input.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
            self?.request?.append(buffer)
        }
        hasTapInstalled = true

        // 오디오 시작
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine 시작 실패: \(error.localizedDescription)")
            cleanupAfterStop()
            return
        }

        DispatchQueue.main.async { [weak self] in
            self?.isRecording = true
            self?.recognizedText = ""
        }

        // 인식 태스크
        recognitionTask = speechRecognizer.recognitionTask(with: req) { [weak self] result, error in
            guard let self = self else { return }
            if self.isFinishing { return } // 종료 중이면 무시

            if let result = result {
                let text = result.bestTranscription.formattedString
                DispatchQueue.main.async { [weak self] in self?.recognizedText = text }
                if result.isFinal { self.finish() }
            }

            if let error = error {
                print("음성 인식 에러: \(error.localizedDescription)")
                self.finish()
            }
        }

        print("🎙 녹음 시작")
    }

    func stopRecording() {
        finish()
        print("🛑 녹음 종료")
    }

    private func finish() {
        if isFinishing { return }
        isFinishing = true

        if audioEngine.isRunning { audioEngine.stop() }

        if hasTapInstalled {
            audioEngine.inputNode.removeTap(onBus: 0)
            hasTapInstalled = false
        }

        request?.endAudio()
        recognitionTask?.cancel()

        recognitionTask = nil
        request = nil

        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)

        DispatchQueue.main.async { [weak self] in self?.isRecording = false }
    }

    private func cleanupAfterStop() {
        if hasTapInstalled {
            audioEngine.inputNode.removeTap(onBus: 0)
            hasTapInstalled = false
        }
        request?.endAudio()
        recognitionTask?.cancel()
        recognitionTask = nil
        request = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        DispatchQueue.main.async { [weak self] in self?.isRecording = false }
    }

    // MARK: - 채점 (StringAlignment 유틸 사용)

    func calculateSimilarity(to target: String) -> Int {
        let ref = normalizeText(target, option: .japaneseFoldKana)
        let hyp = normalizeText(self.recognizedText, option: .japaneseFoldKana)
        let result = alignCharacters(ref: ref, hyp: hyp)
        return result.accuracyPercent
    }

    func similarityDetail(to target: String) -> (percent: Int, substitutions: Int, insertions: Int, deletions: Int) {
        let ref = normalizeText(target, option: .japaneseFoldKana)
        let hyp = normalizeText(self.recognizedText, option: .japaneseFoldKana)
        let r = alignCharacters(ref: ref, hyp: hyp)
        return (r.accuracyPercent, r.substitutions, r.insertions, r.deletions)
    }
}
