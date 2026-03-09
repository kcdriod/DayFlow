import Foundation
import Speech
import AVFoundation
import Observation

enum VoiceState {
    case idle, listening, processing
}

@Observable
final class VoiceRecognizer: NSObject {
    var state: VoiceState = .idle
    var transcript: String = ""
    var errorMessage: String? = nil

    private let recognizer = SFSpeechRecognizer(locale: .current)
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?
    private let engine = AVAudioEngine()

    func startRecording() {
        guard state == .idle else { stopRecording(); return }

        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            guard let self else { return }
            guard status == .authorized else {
                self.errorMessage = "Speech recognition not authorized"
                return
            }
            AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
                guard let self else { return }
                guard granted else {
                    self.errorMessage = "Microphone not authorized"
                    return
                }
                Task { @MainActor in
                    self.beginRecording()
                }
            }
        }
    }

    private func beginRecording() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.record, mode: .measurement, options: .duckOthers)
            try session.setActive(true, options: .notifyOthersOnDeactivation)

            let req = SFSpeechAudioBufferRecognitionRequest()
            req.shouldReportPartialResults = true
            request = req

            let inputNode = engine.inputNode
            let fmt = inputNode.outputFormat(forBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: fmt) { [weak req] buffer, _ in
                req?.append(buffer)
            }

            engine.prepare()
            try engine.start()
            state = .listening
            transcript = ""

            task = recognizer?.recognitionTask(with: req) { [weak self] result, error in
                guard let self else { return }
                if let result {
                    Task { @MainActor in
                        self.transcript = result.bestTranscription.formattedString
                    }
                }
                if error != nil || result?.isFinal == true {
                    Task { @MainActor in
                        self.stopRecording()
                    }
                }
            }
        } catch {
            errorMessage = error.localizedDescription
            state = .idle
        }
    }

    func stopRecording() {
        engine.stop()
        engine.inputNode.removeTap(onBus: 0)
        request?.endAudio()
        task?.cancel()
        request = nil
        task = nil
        try? AVAudioSession.sharedInstance().setActive(false)
        state = transcript.isEmpty ? .idle : .processing
    }
}
