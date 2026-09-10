---
name: matlab-create-hands-on-exercises
description: Use when prompting a learner to complete hands-on MATLAB coding exercises, guided practice, debugging drills, code tracing, small MATLAB projects, or MATLAB-script assessment during tutoring. Use when the tutor should create a complete runnable MATLAB script, execute it through MATLAB tools, compare the produced outputs with expected outputs, and evaluate MATLAB programming style.
license: https://www.mathworks.com/content/dam/mathworks/license/pmrl/license.md
metadata:
  author: MathWorks
  version: "1.0"
---

# MATLAB Hands-On Exercises

## Purpose

Guide learners through active MATLAB practice. Exercises must be complete,
runnable MATLAB scripts when assessment is involved, and the tutor must execute
those scripts through MATLAB tools before judging correctness.

The goal is to provide MATLAB Grader-style formative assessment without requiring
MATLAB Grader: create an exercise, run the learner's code in MATLAB, compare
script outputs against expected values, inspect programming style with Code
Analyzer in MATLAB, and give targeted feedback.

For instructors, this skill turns tutoring into a small formative assessment.
Students still receive coaching, but the tutor also checks whether the code
actually runs and whether the produced outputs match the learning objective.

## Exercise Loop

1. State the goal in one sentence.
2. Define expected outputs and assessment criteria before the learner starts.
3. Give a complete script scaffold with a clearly marked learner section.
4. Ask the learner to predict, fill in, or revise the learner section.
5. Save the complete script as a temporary `.m` file.
6. Apply the execution preflight in
   [references/execution-safety.md](references/execution-safety.md), which
   includes running `check_matlab_code`; do not run it a second time.
7. Run `run_matlab_file` on the script and inspect the MATLAB output.
8. Compare produced variables, values, sizes, classes, errors, and required or
   forbidden functions against the assessment criteria.
9. Give targeted feedback and one extension or revision prompt.

Never mark an assessable exercise correct from visual inspection alone. If the
exercise has expected output, run the complete script in MATLAB and evaluate the
actual output.

## Exercise Types

- **Trace**: Predict workspace variables after each line.
- **Edit**: Modify a snippet to meet a requirement.
- **Debug**: Diagnose an error message and fix the root cause.
- **Refactor**: Replace fragile or verbose code with clearer MATLAB.
- **Test**: Write a `matlab.unittest` test for a function.
- **Analyze**: Import or summarize a tiny dataset.
- **Visualize**: Create or improve a plot.

Use the shortest exercise that can reveal the misconception. A five-line script
that exposes row-versus-column behavior is often more useful than a large
project when the goal is concept formation.

## Starter Exercise Pattern

Read [references/exercise-patterns.md](references/exercise-patterns.md) for reusable exercise formats.

Read [references/script-assessment-patterns.md](references/script-assessment-patterns.md)
when creating a complete runnable script, output checks, MATLAB Grader-style
assessments, tolerance-based comparisons, or Code Analyzer feedback.

Read [references/execution-safety.md](references/execution-safety.md) before
running learner-provided or generated MATLAB scripts.

## Safety and Academic Integrity

- For homework-like prompts, ask for the learner's attempt first.
- Treat learner code as untrusted input. Perform the execution safety preflight
  before running scripts.
- Do not run large or destructive code. Keep practice files small and temporary.
- Always explain what MATLAB script was run, which checks passed or failed, and
  what the output means.
- Avoid file I/O, network calls, `delete`, `rmdir`, shell commands, or long
  simulations unless the learner's explicit task requires them and the path is
  temporary and scoped.

## Feedback

Feedback should be specific:

- Identify the MATLAB rule involved.
- Point to the exact expression or line.
- Report the relevant MATLAB output, variable value, size, class, error, or Code
  Analyzer message.
- Explain how to inspect evidence next time.
- Give one revised attempt or next prompt.

## Assessment Policy

Assess scripts with the same broad categories MATLAB Grader uses for script
assessment:

- expected variable exists;
- expected variable has the right class, size, and value;
- numeric values are compared with an explicit tolerance;
- required functions or keywords are present when the learning objective calls
  for them;
- prohibited functions or shortcuts are absent when the exercise is about a
  specific programming concept;
- custom checks verify plots, tables, errors, or edge cases when variable
  equality is insufficient.

For course pilots, make the expected output explicit before the learner starts.
This helps instructors compare student attempts, AI feedback, and MATLAB
execution evidence.
