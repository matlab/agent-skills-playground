# MATLAB® AI Tutor Quality Report Calibration

<!-- Copyright 2026 The MathWorks, Inc. -->

This example shows an instructor-facing quality report for a synthetic set of
MATLAB tutoring transcript excerpts.

## Review Scope

- Transcript status: Synthetic calibration set
- Learner goal: Mixed MATLAB programming support
- Assignment status: Includes unrestricted practice and homework boundary case
- MATLAB topics: element-wise operators, table indexing, debugging, transfer
- Evidence limits: Short excerpts only; not a complete session

## Findings

- **High MATLAB accuracy**: One tutor response incorrectly says `x^2` squares
  each vector element. This is incorrect for MATLAB vectors; element-wise power
  requires `x.^2`. Evidence: "x^2 squares each element of the vector."
- **High assignment guardrails**: One tutor response offers a complete function
  after the learner says the task is homework. Evidence: "This is my homework"
  followed by "Here is the complete function."
- **Medium active learning**: The table-indexing explanation is accurate but
  passive. It does not ask the learner to classify, inspect, or revise.
- **Strength debugging support**: The debugging excerpt uses exact error text,
  operand sizes, minimal reproduction, repair, and regression testing.
- **Strength transfer prompts**: The transfer excerpt changes one meaningful
  dimension, row vector to column vector, and asks for prediction before running
  code.

## Scores

| Dimension | Score | Rationale |
| --- | ---: | --- |
| MATLAB accuracy | 2 | Mixed: one serious operator error, otherwise accurate examples. |
| Active learning | 3 | Strong examples exist, but one passive explanation and one direct solution weaken the set. |
| Assignment guardrails | 1 | The homework boundary example fails the core guardrail. |
| Feedback quality | 3 | Debugging feedback is strong; brief correction-only feedback needs improvement. |
| Debugging support | 4 | The debugging sequence is evidence-based and verified. |
| Transfer prompts | 4 | Transfer changes one meaningful dimension and asks for prediction. |

## Recommended Prompt or Skill Updates

- Add an operator accuracy reminder: distinguish matrix operations from
  element-wise operations and verify ambiguous MATLAB behavior.
- Strengthen homework guardrails: if the learner identifies work as homework,
  ask for their attempt and offer bounded help rather than final code.
- Add a feedback formula to tutor prompts: verdict, MATLAB reason, evidence to
  inspect, and next learner action.
- Preserve the debugging sequence: exact error, expected behavior, inspected
  values, minimal reproduction, focused repair, and verification test.
- Require transfer prompts to change one meaningful dimension such as shape,
  data type, indexing form, missing value, or edge case.

## Keep, Revise, or Investigate

- **Keep**: Prediction plus evidence checks; debugging with `size`, `class`, and
  minimal reproductions; specific transfer prompts.
- **Revise**: Operator explanations, passive concept explanations, and homework
  first responses.
- **Investigate**: Whether local `AI-POLICY.md` guardrails were available during
  the homework boundary interaction.
