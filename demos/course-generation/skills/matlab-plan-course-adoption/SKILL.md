---
name: matlab-plan-course-adoption
description: Use when an instructor asks for a setup guide, adoption guide, planning guide, implementation checklist, prerequisite check, MATLAB Course Designer course structure plan, Common Cartridge workflow, Simulink starter and solution model planning, LMS import plan, or starter prompt for creating a MATLAB and Simulink enabled course with the matlab-generate-course skill.
license: https://www.mathworks.com/content/dam/mathworks/license/pmrl/license.md
metadata:
  author: MathWorks
  version: "1.0"
---

# MATLAB Course Instructor Setup Guide

Generate a short instructor-facing setup guide for adopting the MATLAB Course
Designer Generator skill package. The guide prepares an instructor to run
`matlab-generate-course`, review MATLAB and Simulink activities, use the
`matlab-create-course-activity` skill to wrap `matlab-generate-grader-assessments` and validate MATLAB Exercise
`.m` files, use `simulink-create-course-activity` for Simulink Exercise starter and
solution model files, and review the final Common Cartridge package as the
persisted course representation.

The guide must frame generated content around the MATLAB Course Designer
organization model: a course contains ordered modules, and modules contain
ordered learning activities. Common Cartridge is the persistence format used
outside the web application until future API work creates course instances
directly.

## Input Handling

Treat the user's course title, syllabus idea, module description, audience,
lab sequence, existing course, or rollout goal as the guide input. If the input
is missing, ask for one sentence describing the course or rollout context.

Infer:

- Course context and learner level
- MATLAB and Simulink scope
- Likely assessment approach
- Common Cartridge persistence target and any downstream LMS import target
- Course Designer module and learning activity structure
- Prerequisite skill/toolkit readiness
- Whether MATLAB Exercises are likely needed and should be generated through
  `matlab-create-course-activity`
- Whether Simulink Exercises need starter and solution `.slx` files generated
  by `simulink-create-course-activity`

Do not ask follow-up questions unless the input is too vague to identify a
course goal.

## Guide Workflow

1. Restate the inferred course goal.
2. Identify the best-fit course generation context.
3. List prerequisite skill packages and MathWorks access assumptions, always
   including IDStack, the MATLAB MCP Server, and the activity skills by name.
4. Recommend a `matlab-generate-course` starter prompt.
5. Recommend when and how to use `matlab-create-course-activity` for MATLAB Exercise
   component generation, MATLAB MCP validation, and Course Designer-only fields.
6. Recommend when and how to use `simulink-create-course-activity` for Simulink
   Exercise model artifacts.
7. Define Course Designer module and learning activity review gates.
8. Define Common Cartridge export and persisted course review checks.
9. Propose a first pilot with one module or one short course shell.
10. Include a concise instructor checklist.

Read [references/setup-guide-template.md](references/setup-guide-template.md)
for output format, context mapping, prompt patterns, and checklist content.

## Output Rules

- Default to Markdown unless the user asks for another format.
- Keep the guide practical enough for an instructor to act on immediately.
- Include a concrete `matlab-generate-course` starter prompt.
- Include concrete `matlab-create-course-activity` prompts when MATLAB Exercises are
  likely.
- State that Common Cartridge persists the course shell and instructions outside
  MATLAB Course Designer; MATLAB and Simulink execution happens in the
  appropriate MathWorks environment.
- Keep institutional policy language adjustable unless the user provides local
  requirements.
