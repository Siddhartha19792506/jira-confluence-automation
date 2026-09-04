# Walkthrough Validation Rules

Use these checks to validate every walkthrough.md file.

## Rule 1: Required Sections
- The file must contain these headings exactly once:
  - `## Overview`
  - `## Steps`
  - `## Summary`
  - `## Quiz`

## Rule 2: Steps Quality
- `## Steps` must include at least 3 numbered steps.
- Each step must start with `1.`, `2.`, `3.` style markdown numbering.

## Rule 3: Summary Completeness
- `## Summary` must be present and contain at least 1 complete sentence.
- Minimum summary length: 12 words.

## Rule 4: Quiz Coverage
- `## Quiz` must include at least 2 questions.
- Each question should end with a `?`.

## Rule 5: File Structure and Naming
- File name must be `walkthrough.md`.
- The file must start with a single H1 title (`# ...`) describing module and lesson.
