Source evidence (`SettingsView.swift`, `UserPreferences.swift`, `NotificationService.swift`) vs proposed layout:

**Actual behavior:**
- Sections in code order: `APP TOUR`, `APPEARANCE`, `BYOM`, `REMINDERS`, `STORAGE & SYNC`, `DATA MANAGEMENT`. No `Processing mode`, no `AI model` header, no local/AI switch.
- App Tour: `What's the difference?` -> `OnboardingView(readOnly:true)`; `Version` is non-interactive `HStack` reading `CFBundleShortVersionString`.
- Appearance: `Dark Mode` via `bindingForDarkMode` -> `UserPreferences.darkMode`.
- BYOM header is `BYOM`, help footnote: `If API key is empty, app falls back to legacy local rules.` Defaults: `https://openrouter.ai/api/v1/chat/completions`, `openai/gpt-4o-mini`. `syncAISettingsIfNeeded()` onAppear loads `UserPreferences.aiAPIKey/aiModel/aiEndpoint`, fills defaults if empty.
- BYOM edit/test: `Endpoint URL`/`API Key`/`Model ID` fields; `canTestBYOM` requires all three non-empty else Test disabled. `testBYOMConnection()` POSTs chat-completions with `Bearer` + OpenRouter `HTTP-Referer/X-Title`, requires 2xx + `"choices"`; success sets `byomTestPassed=true`, message `BYOM is connected...`, `byomCollapsed=true` showing collapsed status + pencil to expand (`shouldShowCollapsedBYOM` also requires non-empty key). Any edit triggers `resetBYOMTestState()` — clears result, expands. Successful test is not required to keep/use values — no save gate.
- Reminders: `bindingForReminders` calls `requestPermission`; denied -> `showNotificationDeniedMsg=true`, shows `Open Settings` -> `NotificationService.openSettings()` (`UIApplication.openSettingsURLString`) + footnote; off -> `cancelInactivityNudge()`.
- Storage: `Current Mode` reads `UserPreferences.storageMode` (`iCloud Sync`/`This device only`, default `.local`). If local, `Upgrade to iCloud` -> alert -> `startMigration()` (guards `ubiquityIdentityToken`, `StorageMigrationService.migrate`, then sets `.iCloud`). No reverse migration in source.
- Data: `Archived Goals` is `NavigationLink` to `ArchivedGoalsView` under `DATA MANAGEMENT`.

**Proposal review:**
- Correct: remove duplicated `Processing mode`; keep single AI entry, preserve endpoint/key/model/test/connected-edit/error flow; no invented mode switch; keep Version non-interactive; x40 alignment is proposed layout only — code only shows nested `.padding(.horizontal)` + `.padding()`, no x-values.
- Mismatch: proposed names/groups (`AI model`, `Storage & sync`, `Archived goals`, `App tour`) are renames/reorders, not source headers. Figma must annotate as proposed, with component note citing source methods above and behaviors: fallback on empty key, test not enforced, edit resets test, denied links iOS Settings, one-way local->iCloud.
