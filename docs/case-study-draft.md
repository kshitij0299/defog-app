# Defog case study — working outline

Private draft, 28 September 2026. This is an evidence-based structure for a future portfolio piece, not a finished success story. The owner’s original motivation and role description are pending. Application implementation remains unchanged.

Update, 29 September: redesigned screens are paused for audit review and component-system agreement. The owner requested SF Pro Rounded typography, native Apple controls, editable alternatives, and linked screen examples. See [Components review](components-review.md). This is a process decision, not a measured product result.

## 1. The product and its original motivation

Defog turns a typed or spoken brain dump into tasks and ongoing goals. It combines quick capture with gentle progress tracking, with optional model processing through an OpenAI-compatible provider.

**Owner voice pending:** what prompted the project, who it was intended for, and which design/development work the owner did. Source for implemented behavior: [product](product.md) and [architecture](architecture.md).

## 2. What existed before this redesign

The current baseline is a native SwiftUI/SwiftData app on `live-view` at `11ba317`. It has a working local typed capture → preview → review → save flow, task schedule buckets, goal progress and optional model configuration. Prior iterations are documented in [design history](design-history.md); commit history establishes changes, not their effectiveness.

Historical survey, interview, persona and test claims require original notes before publication. The old simulated percentages and multipliers are not measured outcomes and are excluded from the narrative.

## 3. What the current walkthrough found

An expert walkthrough used synthetic content in an iPhone17Pro simulator with local storage and no API key. It identified opportunities around contextual voice permissions, capture navigation, first-use guidance, save clarity, truthful progress feedback and model setup. The [audit](ux-audit.md) distinguishes observations, UX-05 as a hypothesis, and UX-09–12 as source risks.

This is not a user study. Voice recognition, remote model quality, CloudKit, notification delivery, Dynamic Type and full VoiceOver behavior have not been validated. Baseline screenshots establish the observed states only.

## 4. Design decisions to explore

The proposed design keeps the task/goal distinction and review before saving. It will explore three destination tabs with a separate capture action; a visible unsaved preview and explicit Save count; factual low-data progress summaries; and model configuration with persistent field labels, processing mode and actionable failures.

Each change should connect a specific audit item to a prototype screen and a question to test. Native Apple components should provide navigation and controls, while Defog-specific content remains calm and readable. These are proposals, not implemented improvements.

## 5. Prototype review and future validation

Record the owner’s prototype decision and revisions. Test whether people can start capture, identify what is saved, correct a categorization, log progress and recover from model failure. After approval and implementation, attach matched before/after captures and real observations. Add quantitative results only if they are actually measured with a documented method.

## Private evidence appendix

The initial goal-overlap claim was withdrawn after a settled clean-launch check. Figma reconstruction errors were corrected separately. Captures 10/11 and 17 must never be presented as an app before/after improvement, because no code changed. See [evidence ledger](case-study-evidence.md) and [capture notes](evidence/2026-09-28/README.md).

This correction belongs in the working evidence record. It is not the central portfolio story or a product result.
