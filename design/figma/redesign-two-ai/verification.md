# Verification — 1 October 2026

This records Figma evidence, not native-app outcomes.

## Structural checks

- Redesign 1 retains its original page and nodes. Both copies initially contained all 82 roots; component-tree pairing reported no mismatches.
- 48 local masters and 66 prototype variables were isolated for each copy. Primitive visual styles/tokens were reused without edits.
- Working audit: 1,827 instances inspected at that point, zero references to the original 48 local masters; zero navigation links into original/preserved screen IDs. Additional masters added afterward use working/native masters only.
- New screen frames retain 402×874; native status region 62 and home region 34. Existing tab frames stay at y745–840, home at y840–874.
- Native Apple row accessories supply the date/time controls. New form and recovery examples use local component instances.

## Player observations

- Home → New task → sample title → goal picker works.
- Creating a goal from the picker returns to the task draft. A stale native detail label was subsequently repaired with explicit row variants.
- Selecting Guitar visibly updates the task form after the variant repair.
- Save returns to Home, shows the new task with Guitar, and changes the task count from 7 to 8.
- Editing the saved goal link and discarding returns to Home with Guitar and count 8 unchanged.
- The zero-item recovery scenario displays task/goal counts 0/0 and a disabled Save. Restore preview brings back both tasks and the goal with Save 3 items. The polished state was rechecked: the empty section label and instructions are hidden.
- Native nested text variables stayed stale in Player despite the correct state. Selection/count/save-action variants provide static labels per state instead. This is a Figma workaround, not an app requirement.
- Three-branch return navigation was replaced with individual guarded actions after Player chose the wrong destination. The corrected Home return was exercised.

## Visual checks

Reviewed Home, the manual task form, optional date/time screen and connection-failure screen. The final form uses disclosure chevrons and native rows. Creation is a plum primary action; Brain Dump remains the separated waveform shortcut. A duplicated title on the new Draw detail was removed.

## Review triage

Muse source review and manual-flow review both completed using the free model with xhigh and reported $0. Draft/saved coupling, goal visibility, creation origin and date clearing were corrected. Preserve the previous schedule group when removing a date. Do not put implementation/prototype disclaimers inside product copy.

The Unslop phrase scan found zero matches in the new UI labels. Human review changed “Your task hasn’t been saved” to “Your changes haven’t been saved” because the same exit state is used while editing an existing task. Ordinary labels and concrete instructions were retained.

## Limits

This is a fixed-data exploration, not an exhaustive behavioral model. Only one synthetic manual task/goal is modeled. Free typing, full date selection, notifications, actual persistence, network failures and speech recognition need implementation and validation after approval. Existing copied screens retain earlier documented limits. No Swift source or app build was changed for this milestone.
