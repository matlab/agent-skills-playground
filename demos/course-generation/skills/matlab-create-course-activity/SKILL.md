---
name: matlab-create-course-activity
description: Create MATLAB Course Designer MATLAB Exercise learning activities by wrapping the existing matlab-generate-grader-assessments skill, then validating generated solution.m, template.m, and tests.m files with MATLAB MCP Server tool calls. Use when the user asks to create a MATLAB Exercise, MATLAB course activity, Course Designer MATLAB activity, validated MATLAB solution file, or MATLAB Exercise component folder.
license: https://www.mathworks.com/content/dam/mathworks/license/pmrl/license.md
metadata:
  author: MathWorks
  version: "1.0"
---

# MATLAB Course Activity Generator

Create MATLAB Course Designer-ready MATLAB Exercise learning activities. This skill is
a wrapper around the existing `matlab-generate-grader-assessments` skill: use `matlab-generate-grader-assessments` first to create the
shared MATLAB Grader-style component parts, then use MATLAB MCP Server tool
calls to validate the generated MATLAB files and add Course Designer authoring
metadata.

## Input

The user may have provided a module objective or activity idea in their request.
If it is missing or too vague, collect missing activity inputs in Step 1.

## Reference Files

Read these references from the `references/` directory as needed:

- `references/grader-wrapper-workflow.md` — how to call and use `matlab-generate-grader-assessments`
- `references/matlab-validation-rules.md` — MATLAB MCP validation workflow
- `references/course-designer-artifacts.md` — output folder and metadata rules

Read `references/grader-wrapper-workflow.md` and
`references/course-designer-artifacts.md` before creating artifacts.

## Required Tooling

Use the existing `matlab-generate-grader-assessments` skill for the initial component generation. Use
MATLAB MCP Server calls for validation:

- `detect_matlab_toolboxes` for product/toolbox availability
- `check_matlab_code` for static analysis of `.m` files
- `run_matlab_file` for runnable scripts, validation drivers, or test harnesses
- `evaluate_matlab_code` for targeted checks, path setup, function calls, and
  MATLAB Exercise test smoke checks

Do not claim a MATLAB Exercise is ready unless the generated MATLAB files have
been checked through MATLAB MCP calls or the final output clearly marks
validation as partial.

## Pipeline Overview

```
Step 1: Collect activity inputs and Course Designer placement
Step 2: Invoke grader for shared MATLAB Exercise component parts
Step 3: Split description.txt into background.m and task.m
Step 4: Add Course Designer-only authoring fields
Step 5: Validate solution.m, template.m, and tests.m with MATLAB MCP calls
Step 6: Write Course Designer-ready activity metadata and review notes
```

## Step 1: Activity Inputs

Collect only missing information:

- Course title or course identifier
- Module title and module order
- Learning activity title and activity order
- Module objective and observable learner outcome
- MATLAB concept: script, function, class, object usage, data analysis,
  visualization, numerical methods, app workflow, or another domain
- Assessment purpose: formative, summative, or both
- Required MATLAB and toolbox products
- Starter/template expectations
- Solution behavior
- Validation requirements
- Output directory

Default to a Course Designer learning activity type of `MATLAB Exercise`.

## Step 2: Invoke `matlab-generate-grader-assessments`

Use `references/grader-wrapper-workflow.md`.

Call or prompt the existing `matlab-generate-grader-assessments` skill before creating Course Designer
metadata. The expected `matlab-generate-grader-assessments` output is:

- `description.txt`
- `template.m`
- `solution.m`
- `tests.m`
- `function_call.m` (Function assessment items)
- `supporting_class.m` (Object usage assessment items)

Store the `matlab-generate-grader-assessments` output under:

```text
grader-items/module-NN-activity-MM-[slug]/
```

`[slug]` is the assessment item's snake_case title with underscores replaced by
hyphens. This wrapper placement overrides the generator's standalone
`{snake_title}/` folder rule.

Do not hand-write these files first. If `matlab-generate-grader-assessments` is unavailable, stop and report
that MATLAB Exercise generation is blocked unless the user explicitly accepts a
planning-only fallback.

## Step 3: Split Description for Course Designer

Create two plaintext `.m` files from `description.txt` for copy/paste into the
MATLAB Course Designer web application:

Per the MATLAB Course Designer documentation for creating MATLAB Exercises:
https://www.mathworks.com/help/matlab-and-simulink-online-courses/ug/create-matlab-exercise-using-matlab-course-designer.html

- The Background field sets the context for the task, explains the learning
  objective, and provides high-level information learners need to complete the
  task.
- The Task field provides the instructions learners follow to complete the
  task, including specific instructions such as which functions or variable
  names to use.

Treat `background.m` and `task.m` as plain-text field transport files, not
executable MATLAB scripts. Preserve the text exactly as it should be pasted into
Course Designer. Do not prefix prose with `%` solely to make the files valid
MATLAB code.

Split workflow:

1. Read `description.txt` once and mark each paragraph as context, objective,
   prerequisite, instruction, deliverable, constraint, self-check, or grading
   detail.
2. Put only context, purpose, learning objective, and necessary high-level
   prerequisite information in `background.m`.
3. Put concrete learner instructions, ordered task steps, deliverables, required
   variable/function/file names, constraints, expected outputs, and self-check
   prompts in `task.m`.
4. Move implementation details out of `background.m` and into `task.m`.
5. Move broad conceptual exposition out of `task.m` unless it is needed to
   understand a specific instruction.
6. If `description.txt` has no clear boundary, create a concise background from
   the opening context and put the full actionable prompt in `task.m`.
7. Keep hidden-test details, reference solution details, and grading mechanics
   out of both files unless they are intentionally learner-facing.
8. Do not modify the original `description.txt`; keep it in the `matlab-generate-grader-assessments` source
   folder.

Quality check:

- `background.m` should still make sense if read before seeing the task steps.
- `task.m` should be actionable without duplicating the full background.
- Both files should be ready to paste into Course Designer text fields without
  cleanup.

## Step 4: Add Course Designer Fields

Create the Course Designer MATLAB Exercise activity from the `matlab-generate-grader-assessments` output.
Add fields that are needed by MATLAB Course Designer but not generated by the
first-pass component workflow:

- `background.m` and `task.m` copy/paste fields
- Module placement and learning activity order
- Estimated time
- Prerequisite context
- Required products and toolboxes
- Learner setup notes
- Course Designer persistence notes
- Optional Common Cartridge placement notes

## Step 5: Validate MATLAB Files

Use `references/matlab-validation-rules.md`.

At minimum:

- Confirm `solution.m`, `template.m`, and `tests.m` exist.
- Run `check_matlab_code` on `solution.m`, `template.m`, and `tests.m` only.
  `background.m` and `task.m` are plain-text copy/paste fields, not valid
  MATLAB code, and must not be linted.
- Execute or smoke-test `solution.m` when runnable.
- Validate `tests.m` syntax and MATLAB Exercise assess calls where possible.
- Confirm the learner template preserves the expected names and scaffold.
- Write all results to `validation-report.md`.

When execution is not possible because the generated item requires MATLAB
Grader runtime functions, run static checks and targeted syntax checks, then
mark runtime validation as partial.

## Step 6: Course Designer Activity Artifacts

Use `references/course-designer-artifacts.md`.

Write these files in the activity folder:

- `activity.md`
- `background.m`
- `task.m`
- `instructor-notes.md`
- `validation-report.md`
- `course-designer-activity.json`
- `grader-source.md`, the reference file that maps the activity to its
  `grader-items/` source folder and component files (see
  `references/course-designer-artifacts.md`)

The `course-designer-activity.json` file is the import-oriented sidecar for
future Course Designer API work. It must include course, module, learning
activity, `background.m`, `task.m`, MATLAB file, product, validation, and
`matlab-generate-grader-assessments` source metadata.

## Output Rules

- The final answer must list the activity folder, `matlab-generate-grader-assessments` source folder,
  metadata path, and validation report path.
- Do not claim validation passed unless the MATLAB MCP checks passed.
- If validation is partial, state exactly which checks were deferred.
- Preserve the Course Designer hierarchy: course -> module -> learning activity.
- Keep the `matlab-generate-grader-assessments` output intact and record any Course Designer-only additions
  separately.
