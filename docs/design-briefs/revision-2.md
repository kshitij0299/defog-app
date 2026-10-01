# Redesign 1: owner feedback, revision 2

The owner approved the warm visual direction and requested these changes on 29 September 2026. This updates Figma only; application implementation still requires approval.

## Locked scope

- Separate two-step onboarding, without tabs. Skip and completion both open Brain Dump. App tour remains available from Settings.
- Four persistent destinations: Home, Tasks, Goals, Brain Dump. Brain Dump is a draft workspace, not a modal action masquerading as a tab. Native four-tab component; no duplicate full-width capture buttons.
- Capture states: empty composer, typed example/preview, recording, and collapsed recorded transcript/preview. Recording hides the editor, uses a static vector waveform over a soft gradient, shows one live-caption area and Done/Cancel. Done preserves a visible transcript; tap it to edit. Figma does not record sound.
- Use plain titles: Brain Dump, Preview, Review, Home, Tasks, Goals, Settings. Specific hints explain what to enter or what an action does. No encouragement filler on routine screens.
- Consistent task/goal identity and count components used beside headings and in preview/review. Counts describe objects or entries, not invented completion percentages.
- Native task menus with reachable actions; move the overflow affordance into a 44pt target at the trailing edge. Preserve current source behavior: schedule and goal-link menus; overflow contains Delete followed by confirmation. Editable text remains a separate interaction.
- Single SF Symbol for each goal category. Guitar uses `music.note`; the connected Figma symbol catalog has `guitars` but no `guitar`. Do not crop the multi-guitar glyph or assert automatic semantic selection is built into UIImage.
- Populate Home/Tasks/Goals with realistic synthetic content. Show the everyday-use fixture separately from first-use assumptions; prototype examples are not persisted user data.
- Guidance is a reusable, dismissible accessory above tabs, with first-use/task/goal/confirmation variants and a white-to-transparent backdrop. It never covers the last reachable list item. No fabricated intelligent prediction or achievement claim.
- Your Day opens a summary. Settings uses grouped factual sections and an AI model setup/test/status flow. Keep endpoint, API key and model labels; preserve connection success/failure feedback from the existing app. Capture offers Set up AI linking to model settings.
- Tokenize this light-mode proposal's palette, spacing and corner roles; preserve native Apple semantic variables. Keep SF Pro Rounded typography styles. Full dark-mode and implementation mapping remain later work.

## Copy corrections

| Original | Revision | Reason |
|---|---|---|
| Home on the first introductory screen | Defog onboarding | Wrong location label |
| Let it all out. | Brain Dump | Name the workspace |
| A sentence, a list, a small ramble. | Type or record what you need to do. | Explain supported input |
| Using local rules | Set up AI | Give the requested next action; explain basic processing in Settings |
| Preview · not saved | Preview | Owner preference; saving remains explicit in Review |
| Make it yours. | Review | Name the task |
| 2 tasks and 1 goal. Nothing saved yet. | Task 2 / Goal 1 indicators | Reuse domain identity and count components |
| One thing at a time. | Remove | Adds no information |
| 2 open tasks. Plenty of breathing room. | Task count indicator | Keep the count; remove unsupported reassurance |
| Nothing waiting here. That’s okay. | No tasks for Someday | Explain the empty state |
| Make yourself at home. / Local rules are on | Settings / Processing | Name the location and setting |
| There’s room for one small thing today. | Tap a task’s circle to mark it done. | Contextual instruction, shown only when useful |

## Skills and evidence

Unslop editorial rewrite/inspection, Onboard, Clarify, Mobile App UX Auditor and Figma use/library/SwiftUI guidance are used. Global and project installations are recorded in `docs/design-skills.md`. The static scanner found heuristic signals, including false positives: it classifies SwiftUI TextField as Flutter and flags decorative background ignoresSafeArea. Counts are not verified app defects.

Apple's [tab guidance](https://developer.apple.com/design/human-interface-guidelines/tab-bars?changes=_5) supports destination tabs; its [onboarding guidance](https://developer.apple.com/design/human-interface-guidelines/onboarding?changes=_7) supports short optional introductions, contextual tips and permissions at the relevant action. [SF Symbols](https://developer.apple.com/sf-symbols/) supplies icons; its app's semantic search is a design-time tool, not evidence of a public runtime auto-icon API.

For future icon suggestions: map a small allowlist of categories and synonyms locally (guitar/practice → music.note); let the user change it. If a BYOM interpretation already happens, request a category from the same allowlist in that response, then map it to a verified SF Symbol. This adds no separate model request. Unknown categories use a neutral fallback. Multilingual matching and symbol availability need implementation tests.

## Review decisions and boundaries

The introductory explanation has two steps, followed by the existing product's storage choice. Skip bypasses the explanation, not the storage decision. The everyday fixture includes existing items in addition to the three-item capture example; it is not an empty account after first launch.

Persistent drafts across tab changes are a proposed requirement, not a claim about current implementation. Retain typed text before appending a voice transcript; preserve partial input on recoverable errors. Disable Review for whitespace or no recognized items. Request speech/microphone permissions when recording is invoked and offer typing after denial. Do not promise on-device-only speech: current recognition does not require it.

The short processing label is **Basic processing**, with **Set up AI** beside it. Settings explains the rules plainly. The original app expects a full chat-completions endpoint; the form example retains that contract. Connection success and failure are explicit specimens. Figma does not send a model request or store a credential. The current source stores AI preferences in UserDefaults, so this design makes no Keychain claim.

Keep appearance, the 3-day inactivity reminder preference, storage, archives, tour and version in Settings. New icon suggestions need a stored category/icon field and a user override; this is future implementation work, not an existing Goal model capability. The prototype uses `music.note`, `book.closed` and `figure.run`.

Review's existing completion/goal-update categories, drag linking, no-result behavior, lifecycle edge cases and full Calendar coverage remain requirements for later state design. This revision focuses on the owner's requested navigation, input, copy, identity and Settings corrections. App source risks from the audit remain unresolved until approved implementation work.

The free review caught a storage reversibility overclaim. The setup screen now asks where to keep data without promising bidirectional switching. Existing migration drops task-to-goal links and only supports local-to-iCloud; that source risk is unchanged. The Settings storage link is a visual choice specimen, not a modeled migration flow. Live-preview helper copy says results appear “after a moment,” matching the current delay more closely.
