# Research-Informed MATLAB Code Assessment

Use this reference before generating MATLAB Grader assessment item descriptions, templates,
solutions, and tests. It is a compact evidence map, not a full literature review.
The goal is to turn published assessment research into practical generation rules
for MATLAB code assessments.

## Core Assessment Method

Every generated item must make four things explicit:

1. **Learning objective**: the MATLAB concept or engineering computation being assessed.
2. **Observable evidence**: variables, function outputs, object state, method behavior,
   errors, plots, tables, or constraints that demonstrate the objective.
3. **Assessment purpose**: formative, summative, or mixed.
4. **Test strategy**: randomized checks, edge cases, hardcoding detection, tolerance,
   and any required or prohibited constructs.

Apply the resolved content language from the course profile to student-facing
descriptions, MATLAB comments, learner-visible assessment names, and optional
feedback. Preserve MATLAB identifiers, code, file names, keywords, and MATLAB
Grader test type labels.

This follows constructive alignment: assessment tasks should directly require the
student behavior named in the learning objective. If the objective is about vectorized
array operations, do not assess only numeric output if a loop-based solution would pass
unless implementation method is intentionally unconstrained. If the objective is
algorithm correctness, prefer output behavior over style checks.

## Formative Assessment Rules

Use formative design when the item is for practice, tutoring, homework drafts,
recitation, lab preparation, self-checking, or revision.

- Keep the task small enough that feedback can lead to another attempt.
- Include a "Before you submit" or equivalent self-check prompt in the description.
- Use diagnostic test names that identify the concept being checked.
- Prefer visible, interpretable checks over opaque trick cases.
- Include one transfer or hardcoding-detection check, but do not make the item depend
  mainly on traps.
- Where possible, give students a way to inspect the relevant MATLAB evidence:
  variable value, class, size, function output, object property, warning, or error.
- Feedback implied by test names should identify goal, current evidence, and next
  action, such as "Check vector orientation for row and column inputs."
- Test names and optional feedback should be in the resolved content language.

## Summative Assessment Rules

Use summative design when the item is for exams, graded assessment item sets,
final submissions, or high-stakes grading.

- Align each test with the stated learning objective and avoid assessing unrelated
  behavior.
- Use independent tests so one setup mistake does not create misleading duplicate
  failures.
- Include randomized inputs and at least one different-range hardcoding-detection test.
- Include edge cases when they are part of the objective or domain.
- Use tolerances for floating-point results and exact checks for class, size, and
  discrete values.
- Avoid revealing the full hidden test strategy in the student-facing description.
- Avoid grading code style, function presence, or keyword absence unless the objective
  explicitly requires a method or prohibits a shortcut.
- Keep tests deterministic in structure even when inputs are randomized: each test should
  compute its expected value from the generated input.
- Optional feedback may diagnose a validated misconception, but must not reveal an answer,
  hidden test, or implementation route.
- Test names and optional feedback should be in the resolved content language.

## Mixed Formative and Summative Rules

Use mixed design when the instructor wants the same item to support practice and later
grading.

- Write the student-facing description with formative self-checks.
- Keep the generated tests robust enough for summative use.
- Separate conceptual hints from answer-revealing details.
- Use test names that are diagnostic but not so specific that they give away a hidden
  implementation.
- Include hardcoding detection and edge cases, but keep at least one basic correctness
  check that helps learners verify progress.

## MATLAB Code Evidence Model

Choose evidence based on assessment item type:

| Assessment item type | Primary evidence | Secondary evidence |
| --- | --- | --- |
| Script | Workspace variables: existence, class, size, value, tolerance | Required or prohibited functions when objective-specific |
| Function | Return values across scalar, vector, matrix, and edge inputs | Input validation behavior when required |
| Class Definition | Concrete class instantiation, public properties, methods, constructor defaults | Value vs handle behavior, superclass list |
| Class Inheritance | Concrete subclass instantiation, required superclass membership, inherited and added properties | Referenced abstract superclass behavior |
| Object Usage | Objects created from referenced classes, object property values, value/copy behavior | Required commands such as `whos` |
| Class Methods | Object state after method calls and referenced-file setup | Constructor/helper pretests, multiple input scenarios |

Learner-authored `classdef` files must be plain `.m` files, not Live Script `.m` or `.mlx` files. Abstract classes may be referenced superclasses, but a learner-submitted abstract class should not be generated as an auto-graded item when the tests must instantiate it.

Use MATLAB Grader-friendly checks:

- `assessVariableEqual` for values, cells, strings, arrays, structs, and object properties
  that can be evaluated in the assessment workspace.
- Randomized setup values with expected outputs computed in the test.
- `randperm(19)-10` when detecting swapped values, orientation mistakes, or hardcoding.
  Skew the sample when assessing location statistics; this distribution has mean and median exactly 0.
- `randi([lo, hi])` when the range matters more than permutation.
- Explicit numeric tolerance when comparing floating-point values. When using
  `assessVariableEqual`, use the full parameter names `RelativeTolerance` and
  `AbsoluteTolerance`; do not use shortened names such as `RelTol` or `AbsTol`.

## Assessment configuration pattern

For each requirement, create one distinct, objective-aligned MATLAB Grader assessment:

1. Use Variable equals reference solution only for direct equality of one Script-submission workspace variable.
2. Add a transfer, shape, type, or contract check only when it measures separate evidence.
3. Use MATLAB Code for every Function-submission output check. Assign test inputs, invoke the learner function and `reference.<functionName>` with those inputs, and compare the outputs with `assessVariableEqual`. For Script-only custom checks, derive expectations from `referenceVariables`.
4. Use MATLAB Code for class-submission checks. Instantiate learner and reference objects when concrete and compare observable `superclasses`, `properties`, `methods`, constructor defaults, or method-updated state.
5. For Object Usage Script items, compare learner-created object properties against `referenceVariables` and use whole-variable equality only when one object variable is the direct intended evidence.
6. Add Function or Keyword present/absent only when the objective explicitly requires or prohibits a named construct.

Do not use fixed test counts. Avoid redundant checks that fail for the same reason.

## Feedback from incorrect variants

Use targeted incorrect variants created during validation as candidates for optional feedback.
Attach feedback to the one assessment row that exposes the misconception, and omit it when
the failure does not support a useful, distinct diagnosis. Formative feedback may identify a
next check; summative feedback identifies only the unmet requirement or misconception.

## Description Pattern

Student-facing descriptions should include:

- The task and the assessed MATLAB concept.
- Required file, function, class, or variable names.
- Expected input/output contract.
- Any constraints required by the learning objective.
- Formative self-checks when the assessment purpose includes formative use.
- Only non-answer-revealing hints for summative use.
