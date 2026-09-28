# Defog redesign: working status

Updated: 2026-09-28. Source baseline: `11ba317` on `live-view`.

## Approved sequence

1. Verify Muse Spark 1.3 Free / xhigh workers.
2. Create source-verified product, architecture, development, and design-history documentation.
3. Walk through the running iOS app and capture baseline evidence.
4. Reconstruct the current app as editable Figma screens on the user-supplied new page.
5. Document UX issues, evidence, impact, severity, and recommendations.
6. Create redesigned screens and a clickable prototype on separate pages in the same file.
7. Obtain the user's design approval before changing application implementation.
8. Implement approved changes, validate behavior, and finish the case study.

Case-study evidence and decisions are recorded alongside the design work. Historical research and simulated results need provenance checks.

## Git

- Foundation branch: `codex/project-foundation`.
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

## Not yet established

- Completion of the full simulator walkthrough. Initial screenshots now cover first-launch permissions, onboarding, storage, Home, Brain Dump, confirmation, and goal detail/overview. A goal-detail safe-area overlap is observed; audit in progress.
- First composed Figma screen visual validation; the supplied page is confirmed empty and Apple iOS26/27 libraries are available.
- Whether old research participant counts and outcomes are supported by original evidence.

Do not interpret this setup record as a completed UX audit or validated redesign.
