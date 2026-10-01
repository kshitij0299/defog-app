# Revision 3 verification

29 September 2026. Synthetic example data, Figma player in a separate background tab.

- Empty capture microphone opened the voice state.
- Voice Process opened the processing state, then timed navigation reached Preview.
- Preview → Review → Save reached Home.
- Plain task overflow opened the review menu.
- Dotted goal pill opened goal selection. Choosing Read changed the label to Read and the pill to green.
- Schedule selection changed Today to Someday and updated both label and color.
- Home scrolled beneath the shorter top fade; the old y106 rectangular clip is removed.
- Tapping Home's large heading opened its collapsed-title specimen. Initial toolbar positioning was corrected so actions remain trailing and Home is centered.
- Final rendered evidence checked goal, input-ready, Home, Tasks, Review, Settings and collapsed navigation; earlier passing captures cover empty input, voice and processing.

## Corrections during QA

- Variable-selected variants retained old nested text overrides. Direct variable-bound SF Rounded labels then triggered missing-font behavior in the player. Resetting inherited overrides and keeping a distinct static native menu label in each variant resolved it; goal and schedule changes were rechecked in the player.
- Rounded clipping inherited from the removed green goal panel clipped a text corner. The simplified header now has no rounded clip.
- ON_DRAG competed with scrolling, so the title-state review shortcut is an explicit tap. It is not proposed product behavior.

## Copy review

The project Unslop core contract and crisp preset were applied as a final audit. Phrase scan: zero violations. Structure scan: no flags. Silhouette: too few prose paragraphs to score. Readability flagged repeated terms (tasks, goals, Today, etc.); these are protected functional labels repeated across screens, not a reason to rewrite. No additional copy rewrite was warranted. The owner's functional changes (Process, short activity names, removal of Recording) are documented requirements.

## Limits

Static waveform, sample input and timed processing are illustrations. Actual keyboard editing, voice transcription, classifier output, persistence, scroll-driven title morphing and accessibility behavior are not established by these checks. Context menus retain the prior overlay placement. No Swift source was edited or build rerun for this design-only change.
