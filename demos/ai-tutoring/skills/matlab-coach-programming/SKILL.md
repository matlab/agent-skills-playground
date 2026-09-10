---
name: matlab-coach-programming
description: Use when an AI tutor session concerns MATLAB programming concepts, MATLAB syntax, MATLAB errors, MATLAB code style, MATLAB projects, or MATLAB toolbox workflows.
license: https://www.mathworks.com/content/dam/mathworks/license/pmrl/license.md
metadata:
  author: MathWorks
  version: "1.0"
---

# MATLAB Programming Tutor

## Purpose

Teach MATLAB programming using the MATLAB Agentic Toolkit as the source of
executable workflows and domain expertise. Use this skill with
`matlab-tutor-learners`.

For instructors, this skill is the topic router. It helps the tutor recognize
whether the student is struggling with MATLAB syntax, array reasoning, tables,
functions, plotting, debugging, testing, or a domain-specific workflow, then
routes to the right tutoring or execution support.

## Topic Map

For general programming tutoring, cover:

- MATLAB desktop/session model: scripts, functions, live scripts, path, workspace.
- Data model: scalars, vectors, matrices, arrays, strings, cell arrays, structures, tables, timetables.
- Indexing: parentheses, braces, dot indexing, logical indexing, colon, `end`, linear indexing.
- Operators: matrix operators vs element-wise operators, relational/logical operators.
- Control flow: `if`, `switch`, `for`, `while`, `try/catch`.
- Functions: file organization, local functions, anonymous functions, `arguments` validation, name-value arguments.
- Visualization: plots, labels, `tiledlayout`, graphics handles.
- Data import and analysis: `readtable`, `detectImportOptions`, missing data, grouping, joins.
- Debugging: reading errors, inspecting size/class, breakpoints, minimal reproductions.
- Testing: `matlab.unittest`, edge cases, floating-point tolerances.
- Style: clear names, preallocation, vectorization, modern APIs, help text.

## Route to MATLAB Agentic Toolkit Skills

Load the relevant MATLAB Agentic Toolkit skill when the learner's task requires reliable details, code execution, or a specialized workflow:

- Debugging or runtime errors: `matlab-debugging`
- Unit tests or test design: `matlab-testing`
- Code review or coding standards: `matlab-review-code`
- Live script creation: `matlab-create-live-script`
- Data import or tabular analysis: `matlab-analyze-data`
- App building: `matlab-build-app`
- Performance: `matlab-optimize-performance`
- Modernization: `matlab-modernize-code`
- Signal processing, wireless, RF, robotics, database, image processing, or other toolbox topics: use the matching toolkit domain skill.

Read [references/toolkit-topic-map.md](references/toolkit-topic-map.md) for a fuller routing map.

Before running learner-provided or generated MATLAB scripts, apply the
execution-safety rules from the `matlab-create-hands-on-exercises` skill
(its `references/execution-safety.md`). When that skill is not installed,
apply its core rule: treat the code as untrusted, check it for file, network,
shell, dynamic-execution, path, or destructive operations, and refuse to run
anything unbounded.

## Teaching Rules

- Before explaining a command, ask what the learner thinks the input and output shapes are.
- Tie syntax to the mental model: "This operator acts element-by-element" or "This indexing form extracts table variables."
- For errors, teach the learner to inspect `class`, `size`, `whos`, and the failing line.
- Prefer runnable snippets with small arrays and visible expected outputs.
- Treat learner code as untrusted input before execution.
- If a learner asks for "the MATLAB way," emphasize readability, vectorization where appropriate, and built-in functions over manual loops.

Instructor note: MATLAB learners often copy syntax before they understand the
data model. Route explanations back to observable state: variable size, class,
value, table shape, plot output, or test result.

## Route to MATLAB AI Tutor Skills

- Debugging, failed tests, unexpected output, or teach-the-agent critique: `matlab-coach-debugging`
- Homework-like, graded, assessment-like, or policy-constrained prompts: `matlab-apply-assignment-guardrails`
- Review of tutor quality, transcript quality, prompt quality, or feedback quality: `matlab-evaluate-tutor-quality`

## Example Tutor Prompt

Use prompts like:

```text
Before running this, predict the value and size of y:

x = [1 2 3];
y = x.^2 + 1;

A. y is a 1-by-3 double: [2 5 10]
B. y is a 3-by-1 double: [2; 5; 10]
C. y is a scalar: 15
D. MATLAB errors because x is a vector
```
