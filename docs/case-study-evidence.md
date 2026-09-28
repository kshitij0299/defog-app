# Defog — Case Study Evidence Ledger

> Lightweight ledger. Facts vs claims vs pending. No invented metrics.
> Pair with [design-history.md](design-history.md) and [development.md](development.md).

## How to use issue IDs

1. File or pick an issue ID (e.g. `DEFOG-001`) per design question.
2. Attach **before screenshot** (Simulator 26.2 clean run) → link file path.
3. Reference **design change** at Figma file `v6VyKHrnxzBtkDuCl8nneS`, node/page `967:1893`.
4. Attach **after screenshot** from the same device/data seed.
5. Record **validation** (observation, user quote, or `Pending`) — never infer validation from git history.

| ID | Before | Figma change | After | Validation |
|----|--------|--------------|-------|------------|
| `DEFOG-___` | `pending` | `pending` | `pending` | `Pending` |

## Current factual entries

| ID / Date | Claim | Source | Status |
|-----------|-------|--------|--------|
| `BASE-11ba317` | Baseline `live-view` at `11ba317`: live Brain Dump preview + shared task helpers | `git log --date=short` | Fact |
| `BASE-HIST` | Prior changes T13–T15, WhisperKit removal, Liquid Glass tabs, Settings moves | `git log --date=short` | Fact (change only) |
| `BUILD-001` | Xcode 26.2 (17C52), `defog-cli` Debug, signing disabled, Simulator 26.2, `/tmp/defog-build-baseline`, success; Testables empty | [Verified build command](development.md#verified-build) | Fact |
| `INTENT-001` | No app implementation until prototype approval; coordinator owns Figma/visual review | Owner instructions, 2026-09-28 | Fact |
| `INTENT-FIGMA` | New work at node/page `967:1893`; existing pages historical only | Owner instructions / coordinator observation, 2026-09-28 | Fact |
| `BEHAV-001` | Brain dump → categorize (BYOM or legacy fallback) → Review & Confirm → Tasks/Goals | `defog iOS/Services/`, `defog iOS/Views/`, `defog iOS/ViewModels/` | Fact (code-read) |
| `BEHAV-002` | Tasks finite (`today/thisWeek/someday`) + optional `linkedGoal`; goal completion logs `GoalEntry`; onboarding copy as in code | `defog iOS/Models/`, `defog iOS/Views/` | Fact (code-read) |

## Current walkthrough and correction record

| ID | Evidence | Status |
|---|---|---|
| `WALK-001` | Local typed capture → preview → review → save worked with synthetic content; no API key. | Expert walkthrough, not usability validation |
| `CORR-UX01` | [Settled goal capture 17](evidence/2026-09-28/17-goal-detail-reverified.png) shows the picker below navigation and the action above tabs after reopening. Captures 10/11 are superseded for layout; their cause is unknown. | Original defect claim withdrawn |
| `FIGMA-CORR` | The owner caught baseline translation errors. Goal structure, native picker, navigation symbols, timeline marker, typography and action positions were corrected. Settings rows/fields and Review card metadata also needed translation corrections. | Design-production corrections, not app improvements |
| `FIGMA-BASE` | Twelve editable baseline frames on page `967:1893`; incomplete coverage and fidelity review. Apple instances used for matching native controls. | Draft |
| `AUDIT-001` | [Eleven findings](ux-audit.md): expert observations, UX-05 as hypothesis, UX-09–12 as source risks. UX-01 retained only as a correction record. | Formative; no measured outcomes |
| `FIGMA-SLOTS` | Owner requires full tab95 and home34 component slots, y745–840 and y840–874. | Canvas convention; differs from runtime capture |
| `APP-UNCHANGED` | Application source remains unchanged through the documentation/Figma phase. | No implemented improvement yet |

## Historical claims requiring corroboration

| Claim | Old source | Needed |
|-------|------------|--------|
| 45 surveys, 5 interviews; 78%/65% bullets; persona Alex | `old-case-study-context.md` §03 | Original survey/interview notes |
| 4–6 taps → 1 tap; Todoist/Reminders/Otter framing | §02 | Method or screenshots |
| 4-user mid-fi test; thinking-state fix; WCAG AA | §05 | Test notes, dates |
| 85% / 4.2× / 73% simulated results | §06 | Study or relabel non-authoritative |

## Future evidence placeholders (all Pending)

- `PENDING-PROTO`: prototype approval decision + date.
- Additional before-state coverage remains pending; 17 existing captures are indexed in [the capture notes](evidence/2026-09-28/README.md).
- `PENDING-AFTER`: after screenshots post-approved Figma changes.
- `PENDING-VALID`: user validation quotes/observations per issue ID.
- `PENDING-METRICS`: only metrics observed after approval; none claimed now.
