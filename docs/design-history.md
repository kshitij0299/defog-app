# Defog — Design History

> Status: historical record + present process. Old docs are evidence, not instructions.
> See also: [development.md](development.md), [case-study-evidence.md](case-study-evidence.md).
> App paths like `defog iOS/Views/` refer to the iOS repo root.

Historical claims below come from the owner-supplied `Defog-Case-Study-Kit/old-case-study-context.md`; original research records and old portfolio implementation have not been independently verified.

## 1. Historical product narrative (old portfolio)

- Old portfolio (`pastel-pivot-folio`, `src/components/DefogCaseStudy.tsx`, `src/pages/ProjectDetail.tsx` `id: 'defog'`) described Defog as a **web app (native coming soon)**, year 2025.
- Hero copy: `BUILT TO TURN THOUGHTS INTO TASKS` / `FROM VOICE, TO ORGANIZED ACTION.` Role: UI/UX Design · Branding.
- That framing is **outdated for 2026**. The product is now a **native SwiftUI iOS app** (`defog.xcodeproj`, `defog iOS/`).
- Do not describe the shipped product as the old Figma Make site (`dice-vector-81290348.figma.site`) or old React shell (`ui_shell_prototype_legacy/`).
- Old site assets (Cloudinary persona image, Figma board embed, `defog-video-1.mp4`, `defog-a-1.json` / `defog-a-2.json`) are **historical process only**. If reused, label `Early exploration`.

## 2. Implementation milestones (source-supported)

Git history proves **code changed**, not that users validated it. Source: repository commit history (`git log --date=short`).

| Date | Commit | What changed |
|------|--------|--------------|
| 2026-03-30 | `11ba317` | Live Brain Dump preview flow + shared task UI helpers (current baseline) |
| 2026-03-29 | `4b70cc4` | Refactor UI components and layout styling |
| 2026-03-25 | `c8a1623` | Unify Settings / Daily Summary full-screen flow |
| 2026-03-25 | `e030df9` | Fix tab bar flicker, Brain Dump completion handling |
| 2026-03-24 | `0ec3993`–`a0c8a80` | Inline editing, keyboard dismissal, Liquid Glass tabs, remove floating add button |
| 2026-03-24 | `e349751` | Move Settings to top-right toolbar |
| 2026-03-19 | `987f3da` / `906bf65` | Remove WhisperKit from active build, preserve as legacy (T15) |
| 2026-03-16 | `a64d84c` / `2c40007` | BrainDumpViewModel refactor (T14), README rewrite (T13) |
| 2026-02-26 | `0b7fcd1` | BYOM defaults, brain dump navigation |
| 2026-02-26 | `6f74d1d` | Initial iOS app core structure |
| 2026-02-23 | `5d33416`–`0a96004` | Initial commits + files from Figma Make |

Behavioral ground truth lives in `defog iOS/Models/`, `defog iOS/Services/`, `defog iOS/Views/`, `defog iOS/ViewModels/`.

## 3. Research claims requiring original evidence

Do not repeat as verified target-audience research without sources:

- Surveys **45 participants**; **5 interviews** (creatives, founders, students).
- **78%** abandon rigid to-dos in two weeks; **65%** use notebooks/Notes as faster.
- Persona **Alex the Overwhelmed Creator**; empathy map image.
- Competitors Todoist / Apple Reminders / Otter.ai; **click fatigue 4–6 taps → 1 tap** heuristic.
- Usability test **4 users**, mid-fi, screen share; **unsure when AI finished** → glow + thinking state; WCAG AA contrast claim.

## 4. Simulated outcomes — do not assert as real

From old §06 `Solution & Results`, explicitly labeled simulated:

- **85%** decrease time-to-capture; **4.2×** daily tasks; **73%** retention week 1.
- Qualitative lines like transformed how users capture their day are **marketing tone**.
- Do not reuse in the new case study without a citable study. Track in [case-study-evidence.md](case-study-evidence.md).

## 5. Useful historical ideas (preserved as hypotheses)

- Planners vs thinkers; reduce upfront planning tax.
- **Tasks finite** vs **Goals as living threads** with entries over time.
- Voice-first capture; calm UI; minimal cognitive load.
- Trust via **Review & Confirm** editing before commit; transparent loading.
- Honest AI framing: **optional remote LLM (OpenRouter BYOM) + local rule fallback**, Apple `SFSpeech` for voice — not always-on-device LLM.

## 6. Present approved process and Figma destination

- Figma file `v6VyKHrnxzBtkDuCl8nneS`; new work at **node/page `967:1893`**. Existing pages are **historical only**.
- **No app implementation changes until user prototype approval.** Coordinator owns app inspection, Figma execution, visual review.
- Muse Spark 1.3 Free xhigh workers produce drafts; main agent owns Git.
- Onboarding truth (from code): Clear your mind / Tasks are finite / Goals are journeys.

## 7. Context still needed from the owner

- Original research notes supporting participant counts, interviews, and usability-test claims.
- Which earlier decisions came from personal use versus feedback from other people.
- Intended audience and which capture/progress problems matter most to them.

Simulated metrics will not be presented as outcomes. Prototype approval will be recorded as the owner's explicit decision on the redesigned screens; the baseline page is not an approval artifact.
