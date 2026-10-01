# Design skills used for Defog

Installed and reviewed on 2026-09-29 at the owner's request. Project copies live in `.agents/skills/`; global copies of the two new skills live in `~/.codex/skills/`. The current session read the installed files directly. A fresh session may be needed for automatic skill discovery.

| Skill | Source | Use here |
|---|---|---|
| Unslop 2.3.0 | https://github.com/theclaymethod/unslop | Diagnose concrete copy defects, rewrite the requested labels, check preservation and scan the final UI copy. |
| Mobile App UX Auditor | https://github.com/AjnasNB/mobile-app-ux-auditor-skill | Mobile navigation, input, onboarding, accessibility and recovery checklist; static source scan as leads only. |
| Onboard | Existing local `~/.codex/skills/onboard/SKILL.md` | Short optional introduction, contextual guidance, and permission recovery. |
| Clarify | Existing local `~/.codex/skills/clarify/SKILL.md` | Useful labels, factual processing status and specific recovery instructions. |

Figma Use, Generate Design, Generate Library and SwiftUI guidance come from the installed Figma plugin. They govern native Apple instances, shared components, typography, variables and safe-area composition. They are not copied into this repository.

The owner requested Unslop without specifying its publisher. After asking which version and receiving no selection, the coordinator used the editorial `theclaymethod/unslop` implementation and announced that assumption. It is not a general-purpose detector of authorship or a replacement for design judgment. No broad collection of unrelated skills was installed.

## Durable usage

Before new Defog interface copy, read Unslop's core contract and rewrite instructions, then the crisp-human preset. Name the actual user action or state; preserve valid domain labels and useful counts. Do not replace removed filler with another slogan. Keep factual claims tied to source or mark them as proposed behavior.

Use Onboard for first use, Clarify for labels/errors, and Mobile App UX Auditor for a scoped review. Do not treat heuristic scanner output as observed bugs or measured user research. Its scan of this SwiftUI source included false positives, including SwiftUI TextField being classified as Flutter and decorative backgrounds being flagged for safe-area use.

The final UI copy is in `design/figma/redesign-1-ai/revision-2/ui-copy.txt`. Scan results are in `copy-checks.json`. The phrase scanner found no violations. Short-label/repetition warnings are protected because this file concatenates UI labels from separate screens. The rewrite diff is intentionally large for the selected defective labels: the owner explicitly requested replacing them. “All” in “Let it all out” was a slogan, not a scope guarantee. No numerical slop score is presented as a quality metric.

Unslop's silhouette scanner needs `evals/fixtures/silhouette/human_reference.json`; that runtime fixture is included. Project copies contain skill instructions and required runtime references/scripts, rather than upstream evaluation suites. `skill-manifest.json` records hashes for the checked-in snapshot.

## Context7 and workers

Context7 is configured in the local Codex and Cursor configurations, but no Context7 tool was callable in this session. Configuration is not a successful connectivity check. Apple primary documentation was used directly for the design research.

Muse Spark 1.3 Free through OpenCode, variant `xhigh`, reviewed the revision brief using selected source-verified documentation. The call completed in 140 seconds, with three steps and **zero reported model cost**. No paid fallback was used. Its useful feedback—storage choice, draft preservation, speech permission recovery and existing Settings scope—is recorded in the revision brief. The coordinator authored and visually checked the Figma work.

The final Muse review also completed successfully (120 seconds, two steps, zero reported model cost). Accepted its storage-reversibility correction and live-preview timing clarification. Rejected false positives that treated the goal's segmented Timeline/Calendar control as a fifth app tab, a goal named “Read more” as interface guidance, and static recording specimens as claims of real audio capture. A missing log in its scoped inputs was not evidence that the coordinator had not verified cost. Costs are reported by OpenCode, not a billing guarantee.
