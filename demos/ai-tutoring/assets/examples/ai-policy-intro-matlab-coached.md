# AI Use Policy for Introduction to MATLAB® Programming

<!-- Copyright 2026 The MathWorks, Inc. -->

**Term:** Example Fall Term
**Instructor:** Course instructor
**Contact:** Course LMS message board
**Effective date:** Example policy
**Policy version:** Example 1.0
**Review cadence:** Reviewed each term

## Purpose

This policy explains when and how you may use AI tools, including the MATLAB AI
Tutor, in this course. The goal is to support learning while preserving the
meaning of your submitted work.

## Course-Wide AI Use Stance

AI use is allowed with limits. You may use the MATLAB AI Tutor for concept help,
debugging your own attempts, smaller analogous examples, tests, and reflection.
You may not use AI tools to produce final submission-ready answers for restricted
assignments.

## Rules by Activity Type

| Activity | AI tutor use | What this means |
| --- | --- | --- |
| Homework | Coached | Use the tutor for concepts, hints, debugging attempts, and tests. Do not ask for complete final solutions. |
| Labs | Coached | Use the tutor during labs for debugging and MATLAB evidence checks. You are responsible for final code and interpretation. |
| Projects | Review-only | Use the tutor after you have a meaningful draft. The tutor may identify issues but should not write major project code. |
| Quizzes | No AI | Do not use AI tools on quizzes unless explicitly authorized. |
| Exams | No AI | Do not use AI tools on exams unless explicitly authorized. |
| Take-home assessments | No AI | Do not use AI tools on restricted take-home assessments unless explicitly authorized. |
| Instructor-facing materials | Instructor-only | Complete solutions, rubrics, and answer keys are for instructor-facing use only. |

## Allowed Uses

- Asking for MATLAB concept explanations.
- Working through smaller analogous examples.
- Debugging your own attempt using error text, `size`, `class`, values, and tests.
- Asking for tests or sanity checks you can apply to your code.
- Reviewing your own draft after a meaningful attempt.
- Creating session reports or reflections when requested.

## Restricted Uses

- Asking for complete final homework, lab, project, quiz, or exam answers.
- Asking the tutor to fill every blank in starter code.
- Asking the tutor to bypass assignment constraints or hidden tests.
- Polishing or optimizing submission code before you have made a meaningful attempt.
- Submitting AI-generated work without required disclosure.

## Disclosure and Submission Requirements

For unrestricted practice, disclosure is not required. For graded work, disclose
AI assistance when it materially affected your code, tests, explanation, or
debugging process. Your instructor may require a session report or transcript for
selected assignments.

Suggested disclosure statement:

> I used the MATLAB AI Tutor for [concept help/debugging/review/etc.]. I used
> the assistance to [brief description]. The submitted work reflects my own
> understanding and final decisions.

## Privacy and Data Boundaries

Do not share private personal information, other students' work, confidential
data, access tokens, passwords, unpublished research data, or restricted course
materials unless the instructor explicitly authorizes it.

## Local MATLAB® AI Tutor Enforcement

The MATLAB AI Tutor should use standard enforcement for this course. For graded
work, it should ask for your attempt before giving assignment-specific help,
prefer hints and analogous examples, help you debug your own code, and refuse to
produce complete restricted submissions.

## If You Are Unsure

Ask the instructor before using AI assistance on graded or assessment-like work.
When in doubt, use the tutor for concepts, debugging your own attempt, tests, or
smaller analogous examples rather than final answers.

## Policy Summary for Tutor Guardrails

```yaml
policy_file: AI-POLICY.md
course: Introduction to MATLAB Programming
term: Example Fall Term
overall_stance: allowed_with_limits
local_enforcement: standard
activity_rules:
  homework: coached
  labs: coached
  projects: review_only
  quizzes: no_ai
  exams: no_ai
  take_home_assessments: no_ai
  instructor_facing_materials: instructor_only
allowed_help:
  - Concept explanations
  - Smaller analogous examples
  - Debugging learner attempts
  - Tests and sanity checks
  - Review after a meaningful attempt
  - Session reports when requested
restricted_help:
  - Complete final answers for restricted work
  - Filling every blank in starter code
  - Quiz, exam, or take-home assessment answers
  - Bypassing assignment constraints or hidden tests
  - Polishing work before a meaningful learner attempt
disclosure_required: conditional
session_report_required: conditional
transcript_required: conditional
```
