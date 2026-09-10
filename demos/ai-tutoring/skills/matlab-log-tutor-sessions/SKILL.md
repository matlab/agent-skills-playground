---
name: matlab-log-tutor-sessions
description: Use when starting, continuing, updating, exporting, or sharing a running transcript of a MATLAB AI tutoring session, especially when the transcript will be shared with an instructor, attached to a learner session report, or passed to an evaluation workflow for quality review.
license: https://www.mathworks.com/content/dam/mathworks/license/pmrl/license.md
metadata:
  author: MathWorks
  version: "1.0"
---

# MATLAB AI Tutor Transcript Log

## Purpose

Keep a running, evidence-preserving transcript of a MATLAB tutoring session once
tutoring has started. The transcript should capture enough context for an
instructor or evaluator to understand what happened without turning the log into
a polished summary or grade.

Use this skill with:

- `matlab-tutor-learners`
- `matlab-coach-programming`
- `matlab-apply-assignment-guardrails`
- `matlab-create-hands-on-exercises`
- `matlab-coach-debugging`
- `matlab-create-mcq-practice`
- `matlab-report-tutor-sessions`
- `matlab-evaluate-tutor-quality`

## Logging Principles

- Start the transcript when a MATLAB tutoring session begins or when the learner
  asks to record, share, evaluate, or report on the session.
- Preserve the sequence of tutor and learner turns.
- Capture MATLAB evidence exactly enough to support review: code snippets,
  outputs, errors, Code Analyzer warnings, test results, and inspected values.
- Label uncertain, missing, synthetic, or reconstructed content clearly.
- Keep private or unnecessary personal information out of the transcript.
- Do not convert the transcript into feedback, a grade, or a learner report.
- Ask before including sensitive course, identity, or grade information.
- If the user only provides a partial transcript, mark it as partial.

## Transcript Workflow

1. Identify the session context: course, assignment status, learner goal, MATLAB
   topic, and whether the transcript is real, synthetic, partial, or reconstructed.
2. Create or update the transcript artifact using the required structure.
3. Append each meaningful turn in order with speaker, timestamp if available,
   and observed content.
4. Add MATLAB evidence blocks for code, errors, outputs, tests, and tool results.
5. Tag tutor moves when visible: active learning, feedback, guardrail,
   debugging support, transfer, or direct explanation.
6. Add brief session markers for important events such as policy checks,
   learner revisions, verified fixes, unresolved issues, and transfer prompts.
7. End with export notes that state what is complete, partial, omitted, or
   synthetic.

Read [references/transcript-template.md](references/transcript-template.md) for
the required transcript structure, evidence tags, and export format.

## File Naming

Autoname transcript files:

```text
MATLAB AI Tutor Transcript YYYY-MM-DD HHMMSS.md
```

Use local session datetime when available. Use 24-hour time and omit colons from
the time. Example:

```text
MATLAB AI Tutor Transcript 2026-06-03 101500.md
```

## Instructor and Evaluation Use

When a transcript is intended for an instructor or evaluation workflow:

- include the transcript provenance: real, synthetic, partial, reconstructed, or
  mixed;
- include the assignment policy context if it was provided;
- include enough MATLAB evidence to judge correctness;
- mark any hidden, omitted, or unavailable turns;
- preserve exact tutor wording for moments that may affect guardrails, feedback
  quality, or student independence.

Use `matlab-report-tutor-sessions` after this skill when the user wants a
learner-facing progress summary. Use `matlab-evaluate-tutor-quality` when the user
wants a quality review of tutor behavior.
