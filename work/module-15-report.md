# Module 15 Completion Report

## Script Metadata
- Filename: tools/walkthrough_bulk_validator.py
- Language: Python
- Purpose: Bulk-processes markdown walkthrough files and validates required sections/structure (Overview, Steps, Summary, Quiz), minimum numbered steps, and minimum quiz questions.

## Script Contents
```python
#!/usr/bin/env python3
"""Bulk validator for walkthrough.md files.

Scans markdown files and checks for required sections and basic structure.
"""

from __future__ import annotations

import argparse
import glob
import os
import re
from dataclasses import dataclass


@dataclass
class ValidationResult:
    path: str
    ok: bool
    issues: list[str]


def read_text(path: str) -> str:
    with open(path, "r", encoding="utf-8") as f:
        return f.read()


def count_numbered_steps(text: str) -> int:
    return len(re.findall(r"^\s*\d+\.\s+", text, flags=re.MULTILINE))


def count_quiz_questions(text: str) -> int:
    return len(re.findall(r"^\s*(?:\d+\.|-\s+).+\?\s*$", text, flags=re.MULTILINE))


def has_heading(text: str, heading: str) -> bool:
    pattern = rf"^##\s+{re.escape(heading)}\s*$"
    return re.search(pattern, text, flags=re.MULTILINE) is not None


def validate_file(path: str, min_steps: int, min_quiz_questions: int) -> ValidationResult:
    text = read_text(path)
    issues: list[str] = []

    if not re.search(r"^#\s+.+", text, flags=re.MULTILINE):
        issues.append("missing H1 title")

    for section in ("Overview", "Steps", "Summary", "Quiz"):
        if not has_heading(text, section):
            issues.append(f"missing section: {section}")

    steps_count = count_numbered_steps(text)
    if steps_count < min_steps:
        issues.append(f"insufficient numbered steps: found {steps_count}, need {min_steps}")

    quiz_count = count_quiz_questions(text)
    if quiz_count < min_quiz_questions:
        issues.append(
            f"insufficient quiz questions: found {quiz_count}, need {min_quiz_questions}"
        )

    return ValidationResult(path=path, ok=len(issues) == 0, issues=issues)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Validate walkthrough.md files in bulk.")
    parser.add_argument(
        "--root",
        default="modules",
        help="Root directory to scan recursively. Default: modules",
    )
    parser.add_argument(
        "--pattern",
        default="**/walkthrough.md",
        help="Glob pattern under root. Default: **/walkthrough.md",
    )
    parser.add_argument(
        "--min-steps",
        type=int,
        default=3,
        help="Minimum numbered steps required. Default: 3",
    )
    parser.add_argument(
        "--min-quiz-questions",
        type=int,
        default=2,
        help="Minimum quiz questions required. Default: 2",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    search_pattern = os.path.join(args.root, args.pattern)
    files = sorted(glob.glob(search_pattern, recursive=True))

    print("Walkthrough Bulk Validation")
    print(f"Root: {args.root}")
    print(f"Pattern: {args.pattern}")
    print(f"Files found: {len(files)}")

    if not files:
        print("No files matched the search pattern.")
        return 1

    failures = 0
    for path in files:
        result = validate_file(path, args.min_steps, args.min_quiz_questions)
        if result.ok:
            print(f"PASS: {result.path}")
        else:
            failures += 1
            print(f"FAIL: {result.path}")
            for issue in result.issues:
                print(f"  - {issue}")

    print(f"Summary: {len(files) - failures} passed, {failures} failed")
    return 0 if failures == 0 else 2


if __name__ == "__main__":
    raise SystemExit(main())
```

## Parameters
| Parameter | Description | Default |
|-----------|-------------|---------|
| --root | Root directory to scan recursively. | modules |
| --pattern | Glob pattern under root for file matching. | **/walkthrough.md |
| --min-steps | Minimum number of numbered steps required per file. | 3 |
| --min-quiz-questions | Minimum number of quiz questions required per file. | 2 |

## Test Run Output
```text
Walkthrough Bulk Validation
Root: modules/module15
Pattern: **/walkthrough.md
Files found: 3
PASS: modules/module15\lesson-01\walkthrough.md
PASS: modules/module15\lesson-02\walkthrough.md
PASS: modules/module15\lesson-03\walkthrough.md
Summary: 3 passed, 0 failed
```
