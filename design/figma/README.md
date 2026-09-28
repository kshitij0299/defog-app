# Figma working artifacts

- File: `v6VyKHrnxzBtkDuCl8nneS`.
- [Current baseline page](https://www.figma.com/design/v6VyKHrnxzBtkDuCl8nneS/defog?node-id=967-1893): twelve editable frames, still a fidelity-review draft.
- [Audit and evidence page](https://www.figma.com/design/v6VyKHrnxzBtkDuCl8nneS/defog?node-id=987-241): eleven findings plus the withdrawn UX-01 record.
- [Reverified goal](https://www.figma.com/design/v6VyKHrnxzBtkDuCl8nneS/defog?node-id=984-436): corrected against settled capture 17.
- [Components workbench](https://www.figma.com/design/v6VyKHrnxzBtkDuCl8nneS/defog?node-id=1053-375): current review deliverable, with local masters, two owner alternatives per family and linked app examples. [Guide](../../docs/components-review.md).
- Eight unapproved draft screens exist on page `1024:2614`; they are paused and unwired. Audit review and component-system agreement come first. No app implementation changes.

## Which artifacts to trust

`native-assets.json` records verified library keys and the owner’s canvas convention. `current-state.json` records the current frame inventory and known gaps. Simulator evidence and current SwiftUI source take precedence over scripts/specifications.

`construction-history/` contains the initial draft scripts, worker specifications and an old ledger. These are historical construction records, **not a supported regeneration pipeline**. They contain superseded layout assumptions and hand-built controls that were subsequently replaced. Do not run them to overwrite the file, infer app defects from them, or treat old node IDs as current without inspecting the canvas.

The repair scripts record targeted MCP operations on known node IDs. They also require inspection before reuse; later edits may supersede them. The live Figma document contains further corrections performed through native instance properties.

`components/` records the workbench scripts and exact node ledgers. `validation.json` and `propagation-test.json` record final structural counts and actual master propagation tests. Full custom tokenization is intentionally deferred. The scripts are historical, not safe to replay over owner edits. `redesign-pilot.js` and `redesign-core.js` are parked draft construction records, not the next approved work.

## Evidence correction

The original goal overlap claim was withdrawn after a clean launch. Capture 17 shows the picker and progress action correctly separated from navigation. Captures 10/11 differ; their cause is unknown. The draft translation copied those overlaps and introduced other errors. These are not valid before/after app-improvement claims.

## Baseline conventions

402×874 iPhone17Pro, rectangular frame; Apple status62, tab95 at y745–840, home34 at y840–874. The bottom slots are a user-requested Figma convention and differ from runtime screenshots. Native Apple instances are required where appropriate; Defog-specific custom cards retain their source structure. The Settings endpoint remains a native text-field instance, with a shortened visible value to represent truncation; the actual source default is `https://openrouter.ai/api/v1/chat/completions`.

## Remaining review

Recheck all twelve baseline frames against settled simulator states, including keyboard/accessory state, incomplete lower Settings content and source-only Goals. Daily Summary now has capture 19. Components examples are not new baseline evidence. Obtain audit/component-system agreement before resuming redesigned screens and prototype wiring.

## Checkpoint validation

Goal detail was reopened in the unchanged simulator and captured again. Goal, Settings, Review & Confirm, live preview and the corrected audit board were rendered and inspected after targeted repairs. Local documentation links resolve; all six JSON artifacts parse. This verifies the documented corrections, not complete baseline fidelity or an implemented redesign.
