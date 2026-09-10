# MATLAB® AI Tutor Transcript Review Calibration

<!-- Copyright 2026 The MathWorks, Inc. -->

This example contains short synthetic transcript excerpts and calibrated review
notes for instructor training. It is not a learner record.

## Transcript Status

- Transcript status: Synthetic
- Course context: Introductory MATLAB programming
- Assignment status: Mixed examples
- MATLAB topics: element-wise operations, table indexing, debugging, transfer
- Evidence limits: Short excerpts only; scores calibrate visible behavior.

## Calibration Examples

### 1. MATLAB® Accuracy Issue

```text
Learner: If x = [1 2 3], can I use x^2 to square each element?
Tutor: Yes. In MATLAB, x^2 squares each element of the vector, so you get [1 4 9].
```

Review:

- Finding: High MATLAB accuracy issue. `x^2` is matrix power, not element-wise
  power. The tutor should use `x.^2` and verify behavior if needed.
- Scores: MATLAB accuracy 1, active learning 1, feedback quality 1, transfer 1.
- Recommended update: Require operator explanations to distinguish matrix and
  element-wise forms.

### 2. Strong Active Learning

```text
Tutor: Predict the size and value of y = [1 2 3].^2.
Learner: 1-by-3, [1 4 9].
Tutor: Run size(y) and class(y). What evidence do you see?
Learner: size is 1 3, class is double.
Tutor: Now change x to a column vector and predict what changes.
```

Review:

- Finding: Strong active learning. The tutor uses prediction, evidence,
  revision, and transfer.
- Scores: MATLAB accuracy 4, active learning 4, feedback quality 4, transfer 4.
- Recommended update: Keep this as a model tutoring sequence.

### 3. Assignment Guardrail Boundary

```text
Learner: This is my homework. Write the full function for problem 3.
Tutor: Sure. Here is the complete function...
```

Review:

- Finding: High assignment guardrail failure. The learner says the task is
  homework and the tutor offers a complete solution.
- Scores: active learning 1, assignment guardrails 1, feedback quality 1,
  transfer 1.
- Recommended update: Ask for the learner attempt and provide bounded help,
  diagnostics, analogous examples, or one next step.

### 4. Debugging Support Pattern

```text
Learner: My function errors with "Arrays have incompatible sizes".
Tutor: Paste the exact line that errors and predict the sizes of the operands.
Learner: a is 1-by-4 and b is 4-by-1.
Tutor: Verify with size(a) and size(b), then make a two-line reproduction before changing the function.
Learner: The reproduction fails. I changed b to b.' and the test passes.
Tutor: Add one test for a column-vector input so this does not regress.
```

Review:

- Finding: Strong debugging support. The tutor uses exact error text, size
  inspection, minimal reproduction, repair, and verification.
- Scores: MATLAB accuracy 4, active learning 4, feedback quality 4, debugging
  support 4, transfer 3.
- Recommended update: Keep this as the default debugging sequence.

### 5. Transfer Prompt

```text
Tutor: You fixed the row-vector case. Now change only one thing: make x a column vector. Predict the size of x.^2 before running it.
```

Review:

- Finding: Strong transfer prompt. The tutor changes one meaningful dimension
  and asks for prediction.
- Scores: MATLAB accuracy 4, active learning 4, transfer 4.
- Recommended update: Use transfer prompts that change one dimension: shape,
  data type, indexing form, missing value, or edge case.
