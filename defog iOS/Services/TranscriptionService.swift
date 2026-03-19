import Foundation
import Speech
import AVFoundation
import SwiftUI
import SwiftData

@Observable
class TranscriptionService {
    var isRecording = false
    var isProcessing = false
    var partialTranscript = ""
    var finalTranscript = ""
    var aggregatedText = ""
    
    private var baseText = ""
    
    var isMicrophoneAuthorized = false
    var isSpeechAuthorized = false
    var permissionDenied = false
    
    private let sfSpeechEngine = SFSpeechTranscriptionEngine()
    
    private var recordingTask: _Concurrency.Task<Void, Error>?
    
    init() {
        checkPermissions()
    }
    
    func checkPermissions() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            _Concurrency.Task { @MainActor in
                self.isSpeechAuthorized = (authStatus == .authorized)
                self.permissionDenied = (authStatus == .denied || authStatus == .restricted)
            }
        }
        AVAudioApplication.requestRecordPermission { granted in
            _Concurrency.Task { @MainActor in
                self.isMicrophoneAuthorized = granted
                if !granted {
                    self.permissionDenied = true
                }
            }
        }
    }
    
    func requestPermissionsIfNeeded() {
        checkPermissions()
    }
    
    func startRecording(baseText: String = "") {
        guard !isRecording else { return }
        self.baseText = baseText
        self.aggregatedText = baseText
        partialTranscript = ""
        finalTranscript = ""
        isRecording = true
        isProcessing = false
        
        recordingTask = _Concurrency.Task {
            do {
                for try await transcript in sfSpeechEngine.transcribeStream() {
                    if _Concurrency.Task.isCancelled { break }
                    await MainActor.run {
                        self.partialTranscript = transcript
                        self.aggregatedText = self.baseText + transcript
                    }
                }
            } catch {
                print("Error recording: \(error)")
                await self.stopRecording()
            }
        }
    }
    
    func stopRecording() async {
        guard isRecording else { return }
        isRecording = false
        recordingTask?.cancel()
        recordingTask = nil
        
        let sfResult = await sfSpeechEngine.stop()
        await MainActor.run {
            let finalSfText = sfResult.isEmpty ? self.partialTranscript : sfResult
            self.finalTranscript = finalSfText
            self.partialTranscript = finalSfText
            self.aggregatedText = self.baseText + finalSfText
        }
    }
}

class SFSpeechTranscriptionEngine {
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    func transcribeStream() -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            do {
                try startListening(continuation: continuation)
            } catch {
                continuation.finish(throwing: error)
            }
        }
    }
    
    private func startListening(continuation: AsyncThrowingStream<String, Error>.Continuation) throws {
        recognitionTask?.cancel()
        self.recognitionTask = nil
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            throw NSError(domain: "SFSpeech", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to create request"])
        }
        recognitionRequest.shouldReportPartialResults = true
        
        if #available(iOS 13, *) {
            recognitionRequest.requiresOnDeviceRecognition = false
        }
        
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
            var isFinal = false
            
            if let result = result {
                continuation.yield(result.bestTranscription.formattedString)
                isFinal = result.isFinal
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                self.recognitionRequest = nil
                self.recognitionTask = nil
                continuation.finish(throwing: error)
            }
        }

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
    }
    
    func stop() async -> String {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        
        try? await _Concurrency.Task.sleep(nanoseconds: 200_000_000)
        return ""
    }
}
