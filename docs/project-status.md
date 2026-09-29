# Defog redesign: working status

Updated: 2026-09-29. Source baseline: `11ba317` on `live-view`.

**Current phase: owner review of revision 3.** The latest pass reduces glass in content, groups Home toolbar actions, separates the Brain Dump shortcut, restores aligned task metadata pills, simplifies goal headers, and adds input → Process → Preview → Review states. The page now has 32 screen/state frames and five overlays. See [revision delivery](../design/figma/redesign-1-ai/revision-3/README.md) and [owner requirements](design-briefs/revision-3.md). Application implementation is unchanged.

## Approved sequence

1. Verify Muse Spark 1.3 Free / xhigh workers.
2. Create source-verified product, architecture, development, and design-history documentation.
3. Walk through the running iOS app and capture baseline evidence.
4. Reconstruct the current app as editable Figma screens on the user-supplied new page.
5. Document UX issues, evidence, impact, severity, and recommendations.
6. Review the audit and Components workbench, preserving linked app examples and owner alternatives.
7. Latest request: extract current-app flows and structural wireframes into Markdown/Mermaid, then explore a fresh design system and representative screens together on `Redesign 1 by AI`. Review this direction before expanding it.
8. Obtain the user's screen/prototype approval before changing application implementation.
9. Implement approved changes, validate behavior, and finish the case study.

Case-study evidence and decisions are recorded alongside the design work. Historical research and simulated results need provenance checks.

## Git

- Foundation branch: `codex/project-foundation`.
- Fresh exploration branch: `codex/redesign-1-ai`, based on the foundation branch so this milestone remains independently reviewable.
- Product remote: `origin` (`kshitij0299/defog-app`).
- Existing `.derivedData/` is untracked and predates this work; leave it untouched.
- No application source changes have been made.

## Verified environment

- Xcode 26.2, build 17C52.
- Installed iOS simulator runtimes: 26.1 and 26.2.
- Schemes: `defog`, `defog iOS`, `defog-cli`.
- `defog-cli` Debug build passed for iOS Simulator 26.2 with signing disabled and build output under `/tmp/defog-build-baseline`.
- The shared scheme has an empty testables list.
- The current deployment target is 26.1; the README's iOS 17 claim is stale.

## Worker setup status

OpenCode 1.18.25 successfully ran its standard Plan agent using `opencode/muse-spark-1.3-contributor-free` with `--variant xhigh`. The synthetic pilot, two documentation workers, and the documentation reviewer completed with zero reported model cost. Initial no-tool pilots with restrictive custom permissions returned HTTP403; their root cause is not established. No paid fallback was used. A newer CLI was installed only under `/tmp` during diagnosis; the working worker route uses the existing CLI.

The user explicitly approved sending selected source, documentation, and design scripts to OpenCode Zen. Credentials, personal app data, and unrelated files are excluded. Workers use scoped copies under `/tmp/defog-workers`, and their temporary event logs are not committed. The coordinator reviews outputs before applying them. The user specifically requires close coordinator supervision of Muse's frontend implementation.

Product, architecture, development, screen-inventory, design-history, and case-study-evidence docs have been drafted and reviewed. Coordinator integration rejects reviewer claims based solely on files missing from a scoped review snapshot; absence from that snapshot is not absence from the repository or user-supplied material.

## Design destination and historical inputs

- [User-supplied new Figma page](https://www.figma.com/design/v6VyKHrnxzBtkDuCl8nneS/defog?node-id=967-1893).
- Preserve old pages; the user says their content is mostly obsolete.
- Historical context was supplied in `Defog-Case-Study-Kit` within the user's external case-study folder.
- Traycer tickets are open in Cursor and may explain older decisions. They have not been inspected; treat them as historical until verified.

## Current design work

- [Editable baseline](https://www.figma.com/design/v6VyKHrnxzBtkDuCl8nneS/defog?node-id=967-1893): 12 reconstructed frames. This is still a fidelity-review draft, not complete state coverage.
- [Audit and evidence](https://www.figma.com/design/v6VyKHrnxzBtkDuCl8nneS/defog?node-id=987-241): eleven findings (expert observations, one design hypothesis, four source risks) and one withdrawn claim.
- Nineteen simulator captures are preserved in `docs/evidence/2026-09-28/`. They use synthetic content and local processing with no API key.
- **Evidence correction:** after a clean relaunch, capture 17 shows the goal picker and progress actions clear of navigation. The earlier UX-01 claim is withdrawn. Captures 10/11 show a different state whose cause is unknown. The Figma translation had additional errors; the corrected goal frame is `984:436`. Do not turn those errors into app findings.
- Apple component instances now cover status, tabs, home indicator, navigation buttons, goal segmented control, Settings fields/rows/switch and onboarding page control. Preserve actual Defog-specific custom UI where it is present in source. Check layout after editing instance variants/properties.
- Keep 402×874 rectangular frames. The agreed Figma bottom slots are tab95 at y745–840 and home34 at y840–874. This convention differs from runtime screenshots and is documented, not claimed as pixel-identical capture.
- The free Muse documentation reviewer completed the evidence-correction review with zero reported model cost. Primary owns UI reconstruction corrections and verification.
- [Components workbench](https://www.figma.com/design/v6VyKHrnxzBtkDuCl8nneS/defog?node-id=1053-375): 30 component families (55 main components, including variants), 60 blank owner work areas, seven text styles, eleven linked screen examples and three context details. See [component guide](components-review.md).
- SF Pro Rounded leads titles, headings and button labels. The earlier token deferral was superseded for this light-mode proposal: revision 2 adds 30 palette, spacing and radius variables. Full dark-mode and implementation mapping remain deferred. Existing Apple semantic bindings remain in native instances; seven pre-existing legacy variables were preserved.
- Eight earlier drafts on page `1024:2614` are paused, unapproved and unwired. They are not the current review deliverable.
- Original first pass (superseded by revision 2): [Redesign 1 by AI](https://www.figma.com/design/v6VyKHrnxzBtkDuCl8nneS/defog?node-id=1095-368): eight fresh screens, 15 component families (20 mains including variants), seven text styles and eight paint styles. Native Apple controls remain nested instances; Defog content uses new local masters. No old screen was cloned as the visual template.
- [Neutral context](design-briefs/current-app-context.md) maps all 12 baseline frames into three Mermaid diagrams and structural wireframes, labeling Figma, walkthrough and source evidence. [Agent brief](design-briefs/redesign-1-ai.md) is ready for another designer/agent to use independently.
- The original first-pass prototype had 25 navigation/back links and two starting points. The core capture → review → save path and Settings scrolling were exercised in the Figma player. Every screen was rendered and checked; a goal-card master edit propagated to three instances and was restored. [Delivery and limits](../design/figma/redesign-1-ai/README.md).
- Muse Spark 1.3 Free / xhigh reviewed this context brief with zero reported model cost. Its review-category, lifecycle-risk and Settings-scope feedback was incorporated. The coordinator did this pass's visual design and Figma construction; no separate agent/task was spawned.

## Revision 3 update

Owner feedback from the Apple Reminders reference now supersedes revision 2's four-tab grouping and voice-gradient treatment. A separate capture bubble, grouped Home toolbar, plain task overflow, aligned metadata variants, compact counts and short goal names are in Figma. The input/processing sequence has two new states; three collapsed-title specimens use an explicit design-review shortcut. Two free Muse/xhigh runs reported zero model cost. See the revision-3 delivery and verification record for limitations and QA corrections.

## Remaining work

- Finish baseline fidelity and state coverage. Goal detail, Review and Settings received targeted visual checks after correction. Live preview received a native keyboard accessory and spacing correction; the updated render was checked against capture 07. Source-only reconstructed states need settled simulator evidence.
- Owner reviews [Redesign 1 by AI](https://www.figma.com/design/v6VyKHrnxzBtkDuCl8nneS/defog?node-id=1095-368), including its system and linked screens. The [audit](ux-audit.md) and Components workbench remain available for reference and owner alternatives.
- After direction agreement, cover missing states, interactions, accessibility and full tokenization. No Figma exploration establishes usability improvement; the current prototype contains fixed sample content and only a subset of interactions.
- Verify historical research provenance with the owner before writing outcomes into the portfolio narrative.
- After prototype approval only: implement, run app-level checks, validate with users, and record genuine results.

No app implementation was changed. Do not interpret the Figma draft as a validated redesign or the walkthrough as a user study.
