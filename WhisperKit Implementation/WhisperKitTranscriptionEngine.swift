import Foundation
#if canImport(WhisperKit)
import WhisperKit
#endif

// MARK: - WhisperKit Download State

enum WhisperKitDownloadState: Equatable {
    case idle
    case preparing
    case downloading(progress: Float)
    case ready
    case failed(message: String)
    case unavailable(message: String)
}

// MARK: - WhisperKit Transcription Engine (real implementation)

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
        for i in 1...100 {
            try await _Concurrency.Task.sleep(nanoseconds: 50_000_000)
            progressHandler(Float(i) / 100.0)
        }
        whisperKit = try await WhisperKit()
    }

    func transcribe(audio: [Float]) async throws -> String {
        guard let whisperKit = whisperKit else {
            throw NSError(domain: "WhisperKit", code: -1, userInfo: nil)
        }
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

// MARK: - PCM Capture Helper

/// Captures raw PCM audio buffers from the microphone for WhisperKit transcription.
/// When re-integrating WhisperKit, install a tap on the audio engine's input node and
/// accumulate Float samples in a buffer, then pass that buffer to
/// `WhisperKitTranscriptionEngine.transcribe(audio:)`.
///
/// Example usage:
/// ```
/// let inputNode = audioEngine.inputNode
/// let format = inputNode.outputFormat(forBus: 0)
/// var pcmBuffer: [Float] = []
/// inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
///     guard let channelData = buffer.floatChannelData?[0] else { return }
///     let samples = Array(UnsafeBufferPointer(start: channelData, count: Int(buffer.frameLength)))
///     pcmBuffer.append(contentsOf: samples)
/// }
/// ```
