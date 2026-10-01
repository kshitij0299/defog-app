# Settings correction — 1 October 2026

The owner reported inconsistent text insets and preferred the current app's Settings structure. This correction restores inline model setup and groups the remaining preferences without changing application code.

- [Settings prototype](https://www.figma.com/proto/v6VyKHrnxzBtkDuCl8nneS/defog?node-id=1097-1082&starting-point-node-id=1097%3A1082)
- [Linked component examples and preservation notes](https://www.figma.com/design/v6VyKHrnxzBtkDuCl8nneS/defog?node-id=1202-3408)

## Evidence and decisions

Reopened Defog UX Baseline on iOS 26.2 and inspected Settings on 1 October. The live screen agrees with `defog iOS/Views/SettingsView.swift`: endpoint, API key, model ID and test sit together; no separate Processing mode selector exists. The captured key field is empty. The source and Simulator are evidence for existing behavior; revised names, order and 40pt text inset are design proposals.

Changes:

- Removed the duplicate Processing mode / AI model navigation. Settings now contains an inline native form. Empty-key and connected states share a component set; the focused sample edit screen uses the same form.
- Native Apple rows, fields, switches, buttons and alert remain instances. Section labels, row text and helper text align at 24pt outer + 16pt inner inset. Trailing values stay right aligned. Preference labels use SF Pro body text; headings and button labels retain SF Pro Rounded.
- Separated Appearance, AI model, Reminders, Storage & sync, Data and App tour. Version is informational with no chevron or action.
- Restored the local-storage upgrade confirmation, instead of linking Settings to first-launch storage selection. The sample successful state hides the upgrade action. No real migration occurs.
- Added a compact connected summary and notes beside instances explaining the original app behavior to retain: local fallback when the key is empty, test gating on non-empty fields, test reset on edits, denied notification recovery, one-way migration and read-only app tour.

## Checks and limits

Native app code was read and its initial Settings screen observed. Figma screenshots confirm layout and native component use. Structural checks found 402×874 screen bounds, SF Pro/SF Pro Rounded text, and no visible full-UI raster images. Native library hidden image slots are unused.

Browser checks exercised inline model entry, sample connection success, Done returning to the connected Settings summary, iCloud confirmation and its simulated completion, and scrolling. A Figma-only bottom spacer was added after the player exposed a clipped Version row; the final browser check shows both App tour and Version fully above the home indicator. The player emitted a font-substitution notice during a variable-driven state transition; canvas renders use the intended families. This remains a Figma player limitation to check before treating the interactive file as final typography evidence.

The fields use sample values, not editable production inputs. The empty Test button has no action. The failure specimen remains on the canvas. Preference switches are visual examples in this light-mode proposal. App tour currently links the existing onboarding exploration; the annotation requires the current app's read-only tour in implementation. Permission prompts, dark-mode design, migration progress and native scrolling/title behavior remain outside this correction. No AI requests, storage writes or measured UX improvement are claimed.

## Review and Git

Muse Spark 1.3 Contributor Free / xhigh reviewed selected Settings source files; both source and milestone-review calls succeeded with zero reported cost. See `source-review.md`. The coordinator performed Simulator inspection, Figma construction and visual/prototype checks. No paid worker was substituted.

The scripts are ordered construction records, not a rebuild command: `update-settings.js`, `finish-settings.js`, then the independent blocks in `polish.js`, and `scroll-clearance.js`. Prepend `../common.js` to each call; inspect live state before reuse. Node IDs are recorded in the state files. Preserve the owner's other canvas work and the older Components page.
