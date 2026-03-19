import Foundation
import Speech
import AVFoundation
import SwiftUI
import SwiftData
#if canImport(WhisperKit)
import WhisperKit
#endif

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
    
    // WhisperKit State
    var whisperKitDownloadProgress: Float = 0.0
    var isWhisperKitReady = false
    var isDownloadingWhisperKit = false
    var whisperKitDownloadState: WhisperKitDownloadState = .idle
    
    private let sfSpeechEngine = SFSpeechTranscriptionEngine()
    private let whisperKitEngine = WhisperKitTranscriptionEngine()
    
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
    
    func downloadWhisperKit() async {
        guard whisperKitEngine.isSupported else {
            await MainActor.run {
                self.isWhisperKitReady = false
                self.isDownloadingWhisperKit = false
                self.whisperKitDownloadState = .unavailable(message: "WhisperKit is not available in this build.")
            }
            return
        }

        guard !isDownloadingWhisperKit else { return }
        if isWhisperKitReady {
            await MainActor.run {
                self.whisperKitDownloadProgress = 1.0
                self.whisperKitDownloadState = .ready
            }
            return
        }

        await MainActor.run {
            self.whisperKitDownloadProgress = 0.0
            self.isDownloadingWhisperKit = true
            self.whisperKitDownloadState = .downloading(progress: 0.0)
        }

        do {
            try await whisperKitEngine.downloadModel { progress in
                _Concurrency.Task { @MainActor in
                    self.whisperKitDownloadProgress = progress
                    self.whisperKitDownloadState = .downloading(progress: progress)
                }
            }
            await MainActor.run {
                UserPreferences.whisperKitDownloaded = true
                UserPreferences.whisperKitEnabled = true
                self.isWhisperKitReady = true
                self.isDownloadingWhisperKit = false
                self.whisperKitDownloadProgress = 1.0
                self.whisperKitDownloadState = .ready
            }
        } catch {
            print("Failed to download WhisperKit: \(error)")
            await MainActor.run {
                UserPreferences.whisperKitDownloaded = false
                self.isWhisperKitReady = false
                self.isDownloadingWhisperKit = false
                self.whisperKitDownloadState = .failed(message: userFacingErrorMessage(error))
            }
        }
    }

    func prepareWhisperKitIfNeeded() async {
        guard whisperKitEngine.isSupported else {
            await MainActor.run {
                self.isWhisperKitReady = false
                self.whisperKitDownloadState = .unavailable(message: "WhisperKit is not available in this build.")
            }
            return
        }

        await MainActor.run {
            self.whisperKitDownloadState = .preparing
        }
        await whisperKitEngine.prepare()
        await MainActor.run {
            self.isWhisperKitReady = whisperKitEngine.isAvailable
            self.whisperKitDownloadProgress = whisperKitEngine.isAvailable ? 1.0 : 0.0
            if whisperKitEngine.isAvailable {
                self.whisperKitDownloadState = .ready
            } else {
                self.whisperKitDownloadState = .failed(message: "Model initialization failed. Retry download.")
            }
        }
    }

    private func userFacingErrorMessage(_ error: Error) -> String {
        let message = (error as NSError).localizedDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        if message.isEmpty || message.hasPrefix("The operation couldn") {
            return "Download failed. Check network/storage and retry."
        }
        return message
    }
}

enum WhisperKitDownloadState: Equatable {
    case idle
    case preparing
    case downloading(progress: Float)
    case ready
    case failed(message: String)
    case unavailable(message: String)
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
        
        // Setup transcription stream
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
        
        // Give a little time to finish processing latest phrases
        try? await _Concurrency.Task.sleep(nanoseconds: 200_000_000)
        return "" // In a real scenario we might wait for the last result here
    }
}

#if canImport(WhisperKit)
class WhisperKitTranscriptionEngine {
    var whisperKit: WhisperKit?
    var isAvailable: Bool { whisperKit != nil }
    var isSupported: Bool { true }
    
    func prepare() async {
        do {
            whisperKit = try await WhisperKit()
        } catch {
            print("Failed to initialize WhisperKit: \(error)")
        }
    }
    
    func downloadModel(progressHandler: @escaping (Float) -> Void) async throws {
        // Mock download simulate for WhisperKit
        for i in 1...100 {
            try await _Concurrency.Task.sleep(nanoseconds: 50_000_000)
            progressHandler(Float(i) / 100.0)
        }
        // Initialize after "download"
        whisperKit = try await WhisperKit()
    }
    
    func transcribe(audio: [Float]) async throws -> String {
        guard let whisperKit = whisperKit else { throw NSError(domain: "WhisperKit", code: -1, userInfo: nil) }
        
        let result = try await whisperKit.transcribe(audioArray: audio)
        return result.text
    }
}
#else
class WhisperKitTranscriptionEngine {
    var isAvailable: Bool { false }
    var isSupported: Bool { false }

    func prepare() async {}

    func downloadModel(progressHandler: @escaping (Float) -> Void) async throws {
        throw NSError(
            domain: "WhisperKit",
            code: -1,
            userInfo: [NSLocalizedDescriptionKey: "WhisperKit is not available in this build."]
        )
    }

    func transcribe(audio: [Float]) async throws -> String {
        throw NSError(
            domain: "WhisperKit",
            code: -1,
            userInfo: [NSLocalizedDescriptionKey: "WhisperKit is not available in this build."]
        )
    }
}
#endif
