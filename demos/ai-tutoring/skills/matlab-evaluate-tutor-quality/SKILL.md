---
name: matlab-evaluate-tutor-quality
description: Use when reviewing, auditing, scoring, or improving a real or synthetic MATLAB AI tutor transcript, tutoring prompt, generated lesson, exercise, feedback sequence, or skill behavior for MATLAB accuracy, active learning, assignment guardrails, feedback quality, debugging support, transfer prompts, and instructor-facing quality recommendations.
license: https://www.mathworks.com/content/dam/mathworks/license/pmrl/license.md
metadata:
  author: MathWorks
  version: "1.0"
---

# MATLAB AI Tutor Evaluation

## Purpose

Evaluate whether a MATLAB tutor interaction helps a learner think, practice, and
transfer understanding. Prioritize concrete findings about pedagogy, MATLAB
accuracy, safety, and missed opportunities. This skill can review real tutoring
transcripts, synthetic transcripts, partial transcripts, prompts, exercises,
generated feedback, and skill behavior.

For instructors, this skill is a quality-control tool. It helps decide whether a
tutor session is ready for students, whether a prompt needs stronger guardrails,
and whether generated feedback is accurate enough to support course learning
goals.

Use this skill for reviews of transcripts, prompts, exercises, feedback text,
skill instructions, and tutor outputs. Use `matlab-log-tutor-sessions` first
when a running transcript needs to be created, cleaned up, or exported before
evaluation.

## Repeatable Review Workflow

1. Establish transcript provenance: real, synthetic, partial, reconstructed, or
   mixed. State any limits this creates for the review.
2. Identify learner goal, level, task type, assignment status, and visible
   MATLAB topics.
3. Check MATLAB accuracy: syntax, semantics, terminology, API behavior, edge
   cases, and whether execution or documentation verification was needed.
4. Check active learning: prediction, explanation, inspection, debugging,
   revision, testing, or transfer.
5. Check assignment guardrails: whether the tutor preserved the learning goal,
   asked for learner work, used hints appropriately, and avoided restricted
   complete solutions.
6. Check feedback quality: verdict, reason, misconception, evidence, next step,
   and whether feedback led to learner revision.
7. Check debugging support: error text, line numbers, `size`, `class`, values,
   minimal reproductions, tests, and verification of repairs.
8. Check transfer prompts: whether the tutor changed one meaningful dimension
   and asked the learner to apply the idea again.
9. Produce an instructor-facing quality report with severity-ranked findings,
   scores, evidence, and recommended prompt or skill updates.

## Evaluation Dimensions

- **MATLAB correctness**: Syntax, semantics, terminology, and idiomatic usage.
- **Learning design**: Learner must predict, inspect, explain, revise, or test.
- **Feedback**: Specific, evidence-based, misconception-aware, and actionable.
- **Debugging support**: Uses error text, line numbers, `size`, `class`, values,
  and minimal reproductions.
- **Assignment guardrails**: Avoids direct restricted solutions and asks for the
  learner's attempt.
- **Transfer**: Includes a related follow-up that changes context or data shape.
- **Cognitive load**: Keeps explanations short and does not ask multiple
  unrelated questions at once.
- **Transcript evidence**: Distinguishes observed behavior from synthetic,
  reconstructed, missing, or inferred content.

## Output Format

For quick reviews, lead with findings. Use this shape:

```text
Findings
- [Severity] [Dimension]: [Issue and why it matters]. Evidence: [quote or reference].

Strengths
- [What the tutor did well, if useful.]

Recommended revision
- [Concrete replacement prompt, feedback, or session move.]

Score
- Active learning: [1-4]
- MATLAB accuracy: [1-4]
- Feedback quality: [1-4]
- Guardrails: [1-4 or N/A]
- Transfer: [1-4]
```

For instructor-facing quality reports, use this shape:

```text
Instructor-Facing Quality Report

Review scope
- Transcript status: [Real | Synthetic | Partial | Reconstructed | Mixed]
- Learner goal:
- Assignment status:
- MATLAB topics:
- Evidence limits:

Findings
- [Severity] [Dimension]: [Issue and instructional impact]. Evidence: [quote, turn, or line].

Scores
- MATLAB accuracy: [1-4]
- Active learning: [1-4]
- Assignment guardrails: [1-4 or N/A]
- Feedback quality: [1-4]
- Debugging support: [1-4 or N/A]
- Transfer prompts: [1-4]

Recommended prompt or skill updates
- [Specific update to tutor prompt, guardrail policy, debugging workflow, feedback pattern, or transfer requirement.]

Keep, revise, or investigate
- Keep:
- Revise:
- Investigate:
```

Read [references/evaluation-rubric.md](references/evaluation-rubric.md) for the
full scoring rubric, transcript review workflow, and calibration examples.

Read [references/transcript-review-examples.md](references/transcript-review-examples.md)
when the user asks for examples, calibration, instructor training material, or
help interpreting scores across MATLAB accuracy, active learning, assignment
guardrails, feedback quality, debugging support, and transfer prompts.

This demo includes example calibration artifacts, at paths relative to the demo
folder that contains `skills/` (not this skill folder):

- `assets/examples/transcript-review-calibration.md`
- `assets/examples/quality-report-calibration.md`

## Instructor Adoption Notes

- Review a small sample of sessions before using the tutor broadly.
- Look for evidence that the student had to think, not only that the tutor gave
  a fluent explanation.
- Treat scores as formative evidence for improving prompts, exercises, and
  course policies.
