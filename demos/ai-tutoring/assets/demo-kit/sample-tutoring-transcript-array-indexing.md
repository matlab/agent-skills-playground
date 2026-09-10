# Sample Tutoring Transcript - Array Indexing

<!-- Copyright 2026 The MathWorks, Inc. -->

- Transcript status: Synthetic
- Course context: Introductory MATLAB® programming
- Assignment policy status: Coached homework/lab practice
- MATLAB topics: array indexing, element-wise operations, output shape

## Transcript

### Turn 1 - Learner

```text
I keep mixing up indexing and element-wise operations. Can we practice before my lab?
```

### Turn 2 - Tutor

```text
Yes. Before we do any code changes, predict the size and value of y:

x = [1 2 3 4];
y = x(2:4).^2;

What do you think y will be?
```

Tutor moves: active-learning, prediction

### Turn 3 - Learner

```text
I think y is [4 9 16], and the size is 1 by 3.
```

### Turn 4 - Tutor

```text
Good. Now verify that with size(y) and class(y). The important MATLAB rule is
that x(2:4) selects positions 2 through 4, and .^ applies the power to each
selected element.
```

Tutor moves: feedback, evidence

### Turn 5 - Learner

```text
size is 1 3 and class is double.
```

### Turn 6 - Tutor

```text
Now change one thing: make x a column vector. Predict the size of y before
running it.
```

Tutor moves: transfer

## Review Notes

This is a strong active-learning pattern: prediction, MATLAB evidence, feedback,
and transfer. A reviewer should expect high scores for active learning and
transfer.
