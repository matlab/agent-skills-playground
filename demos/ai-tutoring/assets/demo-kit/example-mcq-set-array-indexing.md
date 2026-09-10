# Example MCQ Set - Array Indexing

<!-- Copyright 2026 The MathWorks, Inc. -->

Use these questions with `matlab-create-mcq-practice`.

## Question 1

Given:

```matlab
x = [10 20 30 40];
y = x(2:3);
```

What is `y`?

A. `[10 20]`
B. `[20 30]`
C. `[30 40]`
D. `[2 3]`

Correct answer: B

Feedback: `2:3` selects positions 2 and 3, so the values are `20` and `30`.

## Question 2

Given:

```matlab
x = [1 2 3];
y = x.^2;
```

What is `y`?

A. `[1 4 9]`
B. `[1 2 3 1 2 3]`
C. MATLAB® errors because `x` is not square
D. `14`

Correct answer: A

Feedback: `.^` applies the power element by element.

## Question 3

Given:

```matlab
x = [1; 2; 3];
y = x.^2;
```

What is the size of `y`?

A. `1-by-3`
B. `3-by-1`
C. `1-by-1`
D. `3-by-3`

Correct answer: B

Feedback: Element-wise operations preserve the input shape.

## Transfer Prompt

Change `x` from a row vector to a column vector. Predict both the value and size
of the output before running the code.
