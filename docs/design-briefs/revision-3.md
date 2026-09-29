# Revision 3 — quieter controls and capture flow

Status: design work in progress; no application changes authorized.

Owner feedback on 29 September 2026 supersedes revision 2 where listed below.

- Group Home toolbar actions in one native white glass capsule. Use plain ellipsis controls within task cards.
- Keep Home, Tasks and Goals together; separate Brain Dump in the trailing bubble. This is a deliberate capture shortcut, not a search feature.
- Align metadata under task titles. Keep 44-point targets around visually smaller pills. Distinguish Today, This Week and Someday by text and color. Use a dotted unlinked-goal pill and subtle green linked-goal pills.
- Tighten count badges and trailing alignment. Keep the accepted tab95/home34 slots.
- Use one goal name and one symbol; keep green as a small identity accent.
- Replace the hard content clip at the navigation boundary with a short scroll-edge fade. Show a collapsed centered title state as a Figma approximation; native large-title collapse remains an implementation requirement.
- Capture: empty example plus microphone → entered text or voice → Process → cancellable processing → preview/review → Save. No redundant Done action in the editor. Float the composer/action area above the tab bar with a subtle fade behind overlapping content.
- Voice: plain waveform and transcript; remove Recording label and decorative gradient panel. Use an actual muted Cancel button. Process stops recording and processes the captured transcript.

## Goal naming requirement for later implementation

Prefer short activity names: Read, Run, Guitar. Avoid padding such as Read more or Run regularly. Preserve meaningful subjects and proper names; do not blindly strip words from user-entered titles. Apply the rule to generated suggestions, allow editing, and preserve existing saved names unless the owner explicitly edits them. Classifier behavior is a proposal, not an implemented change.

## References and evidence

- Owner supplied [Apple Reminders flow on Mobbin](https://mobbin.com/flows/d3ee4640-b9c8-48a6-bc02-5460d835de85). Three public screens inspected: grouped toolbar controls, compact navigation, and metadata inset beneath task text.
- [Apple: adopting Liquid Glass](https://developer.apple.com/documentation/technologyoverviews/adopting-liquid-glass): toolbar grouping and scroll-edge support.
- [Apple: scroll views](https://developer.apple.com/design/human-interface-guidelines/scroll-views): edge effects separate scrolling content from floating controls; they are not decorative overlays.
- Source: TaskCardView.swift, TaskCardChrome.swift, TaskPillView.swift under defog iOS/Views. Current app already uses colored schedule pills, a dashed unlinked-goal treatment and metadata under task text.
- Simulator capture /tmp/defog-revision3-live.png shows the current Brain Dump permission state, not the Tasks screen. Do not present source verification as a new Tasks simulator observation.
