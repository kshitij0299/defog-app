# Development and verification

Verified on 2026-09-28 against `live-view` commit `11ba317`. The native app lives in `defog iOS/`; `ui_shell_prototype_legacy/` is an old React reference.

## Environment

- Xcode 26.2 (17C52); installed iOS simulator runtimes 26.1 and 26.2.
- Deployment target: iOS 26.1. `SWIFT_VERSION = 5.0` is the Swift language mode, not the installed compiler version.
- Project: `defog.xcodeproj`. Schemes: `defog`, `defog iOS`, `defog-cli`.
- `defog-cli` is shared and builds the `defog iOS` target. Its Testables list is empty; no automated tests were run.
- `xcodebuild -list -project defog.xcodeproj -disableAutomaticPackageResolution` passed.

## Verified build

This exact build passed; the destination is an installed iPhone 17 Pro on iOS 26.2:

```sh
xcodebuild -project defog.xcodeproj -scheme defog-cli -configuration Debug \
  -destination 'platform=iOS Simulator,id=9A2A75BC-1933-4530-9BA8-0D8DE54D3622' \
  -derivedDataPath /tmp/defog-build-baseline CODE_SIGNING_ALLOWED=NO build
```

Use `xcrun simctl list devices available` to choose a destination on another Mac. Alternatively select `defog-cli` and an iOS 26.1+ simulator in Xcode. A generic simulator destination is a build template, not the destination used for this recorded run.

The app bundle is `/tmp/defog-build-baseline/Build/Products/Debug-iphonesimulator/defog iOS.app`; bundle identifier `com.defog.defog-iOS`. Build logs are temporary at `/tmp/defog-build-baseline.log`, not committed. A successful build does not establish UX correctness, remote AI quality, or sync reliability.

## Baseline walkthrough

A separate simulator named **Defog UX Baseline** was created on iOS 26.2 (iPhone 17 Pro; `1DDD302C-0656-4274-A7E4-D422C10075F3`). It isolates the walkthrough from existing app data. Screenshots use a 402 × 874 point viewport, rendered at 3×.

Initial configuration: fresh install, microphone and speech-recognition permissions declined, local storage, light appearance, default text size, no AI key. Synthetic input:

```text
Buy groceries today
Call the dentist this week
Learn guitar
```

Observed: local rules produce two tasks with Today/This Week schedules and a Guitar goal; confirmation saves them. Evidence is in [evidence/2026-09-28](evidence/2026-09-28). Subsequent findings belong in the UX audit; code inspection alone is not a reproduced bug.

## AI and voice configuration

Settings → AI Settings accepts an OpenAI-compatible chat-completions endpoint, key, and model ID. Defaults: `https://openrouter.ai/api/v1/chat/completions`, `openai/gpt-4o-mini`. Without a key the app uses local rules. Connection testing does not establish extraction quality.

Use placeholders in docs; never commit keys or simulator preference stores. Model comparison should use the same synthetic examples and evaluate extraction, goal linking, completions, malformed responses, latency, and fallback behavior. No replacement model has been selected or validated yet.

Speech uses Apple's SFSpeech framework with server recognition permitted (`requiresOnDeviceRecognition = false`). It is not an on-device-only guarantee. Granted-permission voice recording has not yet been verified in this walkthrough.

## Verification matrix

| Area | Required checks |
|---|---|
| Capture | Text, live preview, final review, correction, cancellation, repeated edits |
| Categorization | No-key rules, remote model, connection failure, malformed result |
| Tasks | Edit, schedule, link/unlink goal, complete/reopen, remove, persistence after relaunch |
| Goals | Quick/detailed entry, Timeline/Calendar, archive/unarchive, progress overview |
| Accessibility | Control names, touch targets, VoiceOver, larger Dynamic Type, contrast |
| Layout | Light/dark, keyboard shown/hidden, small/large devices, safe areas |
| Storage | Local persistence; separately verify iCloud migration and sync before claiming reliability |

Local-to-iCloud migration currently omits task-to-goal links; the UI offers no iCloud-to-local migration. Dates use the device's calendar and timezone. Today/This Week/Someday are schedule buckets, not persisted due dates.

## Working rules

See [AGENTS.md](../AGENTS.md) for Git ownership, model delegation, and the design approval boundary. Keep documentation/design changes separate from app implementation. Preserve the existing untracked `.derivedData/`. Update documentation when behavior changes, and record what was actually verified rather than listing checks as implicitly passed.
