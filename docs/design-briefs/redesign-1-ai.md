# Agent brief: Redesign 1 by AI

Read [current-app-context.md](current-app-context.md) first. It is a neutral behavioral handoff from the app-as-Figma baseline; the existing redesign and Components pages are not visual templates.

## Assignment

Create a fresh exploration in Figma file `v6VyKHrnxzBtkDuCl8nneS` on a new page named **Redesign 1 by AI**. Build a compact design system and eight representative screens on that same page. Preserve all existing pages and user edits. The owner explicitly authorized this new exploration after the earlier pause; it is still a proposal, not permission to change application code.

## Direction

Mostly native iOS, with a cute but composed personality. Favor warm off-white surfaces, a plum accent, restrained lavender/peach supporting colors, rounded typography and small SF Symbol details. Keep the tone encouraging without exaggerated praise or pressure. Avoid a generic dashboard, productivity scores, invented streak rewards, large decorative cards everywhere, or copying the earlier screens' composition.

Use SF Pro Rounded strongly for app titles, section headings and buttons; SF Pro for body/input and native device chrome. Use actual Apple navigation, buttons, menus, fields, switches, segmented controls and tabs; keep them attached, tinting and customizing supported properties. Defog-specific task and goal content may be composed locally. Repeated elements must be instances of local masters. Do not build the UI as flattened images.

Device: rectangular iPhone 17 Pro, 402×874. Status region 62pt; home indicator 34pt at y840. Where tabs are shown, reserve their full 95pt slot at y745–840. Respect complete component bounds. Full production tokenization remains deferred; document a compact palette, typography, spacing and editable components on the page.

## First screen set

1. Home empty: a useful invitation and clear Brain dump action.
2. Home populated: what needs doing today and ongoing goals, with distinct capture access.
3. Brain Dump with editable text and live unsaved preview.
4. Review: editable categorization, schedule and goal linkage; explicit save count. Preserve completions and goal updates when present, removal/recategorization and Back without saving. This first example contains two tasks and one new goal; no-result and other result categories need later states.
5. Tasks: Today / This Week / Someday; completion and edit affordances.
6. Goals: ongoing pursuits and factual progress.
7. Goal detail: native Timeline/Calendar switch, quick entry and written-note action.
8. Settings: understandable local/model mode, labeled model fields and native preferences. Retain app-tour, archived-goal and storage entry points; lower sections may scroll.

Small state specimens may accompany the system. These eight screens are a first exploration, not full product/state coverage. Connect the core capture → review → save path and main destinations where feasible; label unimplemented prototype interactions honestly.

## Proposed UX changes to test

- Three destination tabs; capture is a separate labeled action.
- Preview is explicitly unsaved. Rename Process to Review, then save with an item count.
- Show active processing mode. Request voice permission only when voice is chosen.
- Label local statistics as progress, never AI analysis. Sparse data gets factual copy.
- Persistent endpoint/key/model labels. Model failures should preserve input and offer an explicit recovery choice in later states.
- Archive confirmation must disclose current task unlinking. Reopen/undo and iCloud migration need explicit behavior decisions and relationship-preservation checks; a clean-looking screen does not resolve these source risks.

These are proposals. Current-app quirks and source risks are documented in the context; do not call them fixed by drawing a screen.

## Acceptance and handoff

Deliver editable Figma masters and linked screens, consistent Rounded typography, intact native instances, clean safe-area layout, and a concise rationale tied to the flow. Compare full-screen renders, correct clipping/overlap, and verify a representative master edit propagates. Record page/node IDs and prototype limitations. Do not change app code or old pages. Ask the owner to assess the direction before expansion.

Coordinator owns visual design, Figma execution and review. Muse Spark 1.3 Free / xhigh may check this text brief for omissions and contradictions; avoid delegating visual direction to it for this pass. Selected source/docs only, no keys or personal app data.
