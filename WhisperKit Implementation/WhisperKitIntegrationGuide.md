# WhisperKit Re-Integration Guide

This folder preserves all WhisperKit code removed from the active iOS build so that a future developer or agent can re-enable local on-device transcription.

## Folder Contents

| File | Purpose |
|---|---|
| `WhisperKitTranscriptionEngine.swift` | Full engine class (real + stub), `WhisperKitDownloadState` enum, and PCM capture helper |
| `WhisperKitIntegrationGuide.md` | This guide |
| `add_whisperkit.rb` | Ruby script that adds the WhisperKit Swift Package to the Xcode project |

## Re-Integration Steps

### 1. Add the WhisperKit Swift Package

Run the helper script from the repository root:

```bash
ruby "WhisperKit Implementation/add_whisperkit.rb"
```

Or add manually in Xcode: **File → Add Package Dependencies** → `https://github.com/argmaxinc/WhisperKit.git` (up to next major from `0.9.0`).

### 2. Restore the Engine to the Active Build

Copy `WhisperKitTranscriptionEngine.swift` into `defog iOS/Services/` and add it to the Xcode target.

### 3. Re-add WhisperKit State to `TranscriptionService`

Add the following properties back to `TranscriptionService`:

```swift
var whisperKitDownloadProgress: Float = 0.0
var isWhisperKitReady = false
var isDownloadingWhisperKit = false
var whisperKitDownloadState: WhisperKitDownloadState = .idle

private let whisperKitEngine = WhisperKitTranscriptionEngine()
```

Restore the methods `downloadWhisperKit()`, `prepareWhisperKitIfNeeded()`, and `userFacingErrorMessage(_:)` — their implementations are preserved in `WhisperKitTranscriptionEngine.swift`'s original commit history or can be reconstructed from the engine's API.

### 4. Restore UserPreferences Keys

Add back to `UserPreferences.swift`:

```swift
static var whisperKitEnabled: Bool {
    get { UserDefaults.standard.bool(forKey: "whisperKitEnabled") }
    set { UserDefaults.standard.set(newValue, forKey: "whisperKitEnabled") }
}

static var whisperKitDownloaded: Bool {
    get { UserDefaults.standard.bool(forKey: "whisperKitDownloaded") }
    set { UserDefaults.standard.set(newValue, forKey: "whisperKitDownloaded") }
}
```

### 5. Restore Settings UI

Add a **VOICE INPUT** section back to `SettingsView.swift` with download/toggle controls for WhisperKit.

### Key Type & Symbol Names

- `WhisperKitTranscriptionEngine` — engine class
- `WhisperKitDownloadState` — enum for download/preparation lifecycle
- `UserPreferences.whisperKitEnabled` / `.whisperKitDownloaded` — feature flags
- `TranscriptionService.downloadWhisperKit()` — triggers model download
- `TranscriptionService.prepareWhisperKitIfNeeded()` — initialises engine after download
