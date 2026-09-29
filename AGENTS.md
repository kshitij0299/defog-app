# Working on Defog

## Product and source of truth

- The product is the native SwiftUI/SwiftData application in `defog iOS/`.
- `ui_shell_prototype_legacy/` is historical reference, not the current app.
- Prefer current source and observed simulator behavior over old README claims or portfolio material. Cite source paths for implementation claims.
- Keep implemented behavior, proposed changes, historical claims, and observed results distinct. Never present simulated portfolio metrics as measured outcomes.
- Start with `docs/project-status.md` for the current phase, baseline, and known blockers. More product and architecture documentation is being prepared.

## Current redesign boundary

The user approved documentation, simulator inspection, UX auditing, Figma reconstruction, and a redesigned prototype. Application implementation changes wait until the user approves the prototype. Building and running the existing app is authorized.

**Latest scope (2026-09-29): a fresh exploration is authorized.** The owner requested a neutral Markdown/Mermaid flow and wireframe handoff from the current-app baseline, then a new page named `Redesign 1 by AI` with a compact design system and representative screens. This supersedes the earlier pause for this exploration only. Preserve Components and the eight older parked drafts. Application implementation still requires owner approval of the prototype.

- Fresh exploration page: `1095:368`. Start with `docs/design-briefs/current-app-context.md` and `docs/design-briefs/redesign-1-ai.md`; delivery details are in `design/figma/redesign-1-ai/README.md`. It is an unapproved proposal, not measured UX improvement.
- For this pass, Muse checks the text brief; the coordinator owns visual direction and Figma execution. The owner withdrew the suggestion to spin up a separate agent/task.

- Components page: `1053:375`. Local masters, two blank owner alternatives per family, and linked current-app context screens. Preserve the owner's edits.
- Strong SF Pro Rounded identity for app titles, headings and button labels. Native device typography remains native SF Pro. Full tokenization is explicitly deferred until the system is agreed.

- Figma file: `v6VyKHrnxzBtkDuCl8nneS`.
- User-supplied starting node/page: `967:1893`; inspect its type before writing.
- Device target: retain iPhone 17 Pro at 402×874 points per the user’s latest clarification. Working frames are rectangular; include native status bar (62pt region), home indicator (34pt region), and respect safe areas. Do not redo existing captures solely to change the device model. Place full component bounds in separate layout slots: tab bar height95 ends at y840; home indicator height34 starts at y840. Do not overlay these component frames or align only their visible shapes.
- Use the running app as the baseline. Existing old Figma pages are historical reference only; preserve them.
- Native-first Figma rule: whenever an appropriate Apple design-system component exists, import and use an instance, customizing its properties/variants. Do not hand-draw substitutes for segmented controls, switches, navigation controls, standard buttons, fields, or device chrome. Custom auto-layout construction is for Defog-specific UI without a matching native component. Audit and correct existing substitutes before expanding screens.
- Evidence correction: settled capture `17-goal-detail-reverified.png` supersedes captures 10/11 for goal layout. UX-01 is withdrawn as a confirmed app defect. The baseline Figma translation had errors; do not reproduce or cite those as application bugs. Verify settled live UI and distinguish canvas conventions from runtime measurements.
- Create separate pages for audit findings and redesigned screens/prototype as needed.
- Maintain case-study evidence during the work; verify research provenance with the user before claiming outcomes.

## Delegation and cost

- Use OpenCode with `opencode/muse-spark-1.3-contributor-free`, reasoning variant `xhigh`, for bulk source analysis, documentation, construction scripts, coding, and the first review pass.
- Verify a successful worker call before dispatching large jobs. Do not silently substitute a paid model when the free route fails.
- Give each worker a bounded brief, selected inputs, permitted outputs, and acceptance criteria. Prefer two or three independent workers initially.
- Return concise summaries and artifact paths. Avoid copying whole repository contents or long tool logs into the coordinator's context.
- The coordinator owns simulator interaction, UX decisions, Figma MCP execution, visual validation, Git integration, and final review.
- The user specifically wants the coordinator to supervise frontend work closely. Muse may implement tightly specified pieces, but frontend changes require coordinator comparison against the approved Figma screens in Simulator before acceptance.
- The user explicitly authorized sending selected Defog source, design scripts, and documentation to OpenCode Zen (`opencode.ai`) for these workers. Exclude credentials, API keys, personal app data, and unrelated files.

## Git workflow

- The redesign baseline is `live-view` at `11ba317`. Preserve its history.
- Use focused `codex/…` branches. Use separate worktrees for workers that edit independent implementation changes; read-only workers can use scoped snapshots.
- Workers must not switch the shared checkout, merge branches, push, or publish PRs. They report their changes to the coordinator.
- Keep documentation/design artifacts separate from application implementation changes. Commit cohesive milestones with clear messages.
- Review diffs and run checks appropriate to the change before integration. A Muse reviewer handles the first pass; the coordinator checks unresolved concerns and the final result.
- Use PRs for meaningful reviewable milestones. Avoid creating a PR for every worker output.
- Preserve unrelated working-tree changes and generated files. Stage explicit paths, not the entire working tree.
- Use `origin` for this repository. The separate `no-live-origin` remote is historical and must not receive this redesign's changes.

## Build and verification

Verified on 2026-09-28: Xcode 26.2 (17C52), iOS Simulator 26.2, deployment target 26.1.

```sh
xcodebuild -project defog.xcodeproj -scheme defog-cli \
  -configuration Debug -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath /tmp/defog-build CODE_SIGNING_ALLOWED=NO build
```

The baseline build passed using the same scheme/configuration and a specific installed iPhone simulator destination. The shared scheme currently has no testables. A successful build does not establish UX correctness, AI quality, or CloudKit behavior.

Never commit API keys, simulator preference stores, `.derivedData/`, or local worker event logs. Use synthetic walkthrough content when capturing evidence.
