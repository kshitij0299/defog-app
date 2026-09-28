# Figma working artifacts

- File: `v6VyKHrnxzBtkDuCl8nneS`.
- [Current baseline page](https://www.figma.com/design/v6VyKHrnxzBtkDuCl8nneS/defog?node-id=967-1893): twelve editable frames, still a fidelity-review draft.
- [Audit and evidence page](https://www.figma.com/design/v6VyKHrnxzBtkDuCl8nneS/defog?node-id=987-241): eleven findings plus the withdrawn UX-01 record.
- [Reverified goal](https://www.figma.com/design/v6VyKHrnxzBtkDuCl8nneS/defog?node-id=984-436): corrected against settled capture 17.
- No redesigned page or interactive prototype is ready yet. No app implementation changes.

## Which artifacts to trust

`native-assets.json` records verified library keys and the owner’s canvas convention. `current-state.json` records the current frame inventory and known gaps. Simulator evidence and current SwiftUI source take precedence over scripts/specifications.

`construction-history/` contains the initial draft scripts, worker specifications and an old ledger. These are historical construction records, **not a supported regeneration pipeline**. They contain superseded layout assumptions and hand-built controls that were subsequently replaced. Do not run them to overwrite the file, infer app defects from them, or treat old node IDs as current without inspecting the canvas.

The repair scripts record targeted MCP operations on known node IDs. They also require inspection before reuse; later edits may supersede them. The live Figma document contains further corrections performed through native instance properties.

## Evidence correction

The original goal overlap claim was withdrawn after a clean launch. Capture 17 shows the picker and progress action correctly separated from navigation. Captures 10/11 differ; their cause is unknown. The draft translation copied those overlaps and introduced other errors. These are not valid before/after app-improvement claims.

## Baseline conventions

402×874 iPhone17Pro, rectangular frame; Apple status62, tab95 at y745–840, home34 at y840–874. The bottom slots are a user-requested Figma convention and differ from runtime screenshots. Native Apple instances are required where appropriate; Defog-specific custom cards retain their source structure. The Settings endpoint remains a native text-field instance, with a shortened visible value to represent truncation; the actual source default is `https://openrouter.ai/api/v1/chat/completions`.

## Remaining review

Recheck all twelve frames against settled simulator states, including keyboard/accessory state, incomplete lower Settings content and source-only Goals/Daily Summary states. Complete missing onboarding, calendar, processing, errors and empty states before claiming baseline coverage. Then build the separate redesign and wire its prototype.

## Checkpoint validation

Goal detail was reopened in the unchanged simulator and captured again. Goal, Settings, Review & Confirm, live preview and the corrected audit board were rendered and inspected after targeted repairs. Local documentation links resolve; all six JSON artifacts parse. This verifies the documented corrections, not complete baseline fidelity or an implemented redesign.
