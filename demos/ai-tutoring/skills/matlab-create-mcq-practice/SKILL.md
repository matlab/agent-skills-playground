---
name: matlab-create-mcq-practice
description: Use when creating, asking, grading, or explaining multiple choice questions for MATLAB programming practice, concept checks, quizzes, or tutoring exercises.
license: https://www.mathworks.com/content/dam/mathworks/license/pmrl/license.md
metadata:
  author: MathWorks
  version: "1.0"
---

# MATLAB MCQ Practice

## Purpose

Create interactive multiple choice questions that test MATLAB understanding
through prediction, interpretation, debugging, and transfer. Use with
`matlab-tutor-learners` and `matlab-coach-programming`.

For instructors, MCQs are useful when they diagnose a misconception, not just
when they check recall. A strong MATLAB MCQ should reveal how the learner thinks
about arrays, indexing, operator behavior, types, or control flow.

## Question Design

Each question must include:

- A clear learning objective.
- A small MATLAB code snippet or concrete scenario when possible.
- Four answer choices labeled A-D.
- One best answer.
- Distractors based on plausible MATLAB misconceptions.
- Feedback for each option.
- A follow-up prompt that adapts to the learner's answer.

## Interaction Rule

When actively tutoring, ask one MCQ and wait for the learner's answer before
revealing the answer. Do not include the answer key unless the user asks to
generate a quiz artifact instead of running a session.

An MCQ answer key is an authoritative claim about MATLAB behavior.
When a MATLAB session is available, verify each code snippet and its correct
answer by running it before asserting the key or marking a learner wrong; when
no session is available, keep snippets simple enough that the behavior is
certain, and say so if it is not.

## MATLAB Misconception Bank

Use distractors based on:

- Confusing `*` with `.*`, `/` with `./`, or `^` with `.^`.
- Expecting zero-based indexing instead of one-based indexing.
- Confusing row and column vectors.
- Misunderstanding table variable indexing: `T.Var`, `T(:, "Var")`, `T{:, "Var"}`.
- Assuming strings and character vectors behave identically.
- Forgetting that assignment does not display output when suppressed by semicolon.
- Thinking `length` always means number of rows.
- Confusing logical indexing with numeric indexing.
- Expecting loops to be required where vectorized operations are clearer.
- Misreading function scope or workspace behavior.

## MCQ Template

Read [references/mcq-template.md](references/mcq-template.md) when generating a set of questions, a quiz, or a reusable question bank.

## Difficulty Levels

- **Novice**: syntax recognition, output prediction for one or two lines, indexing basics.
- **Developing**: code tracing, function behavior, tables, plotting, common errors.
- **Proficient**: debugging, vectorization tradeoffs, tests, floating-point behavior, data workflows.

## Grading Response Pattern

Use this after the learner answers:

```text
Correct/Not quite.
Why: [one MATLAB-specific explanation].
The tempting misconception is [misconception].
Try this follow-up: [one transfer question].
```

After a correct answer there is no held misconception; name the most tempting
distractor and why a learner might pick it instead.

## Instructor Adoption Notes

- Use MCQs before hands-on work to surface misconceptions quickly.
- Prefer code-prediction questions over vocabulary-only questions.
- Review which distractors students choose; those choices often point to the
  next mini-lesson or script exercise.
