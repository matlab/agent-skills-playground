---
name: matlab-generate-course
description: Interview an instructor and generate a complete MATLAB and Simulink enabled course in IMS Common Cartridge format. Use when the user asks to create a MATLAB course, Simulink course, MATLAB and Simulink curriculum, MATLAB Course Designer-ready course shell, Common Cartridge course package, .imscc export, MATLAB Exercises with validated .m files, or Simulink Exercises with starter and solution model files. Coordinates IDStack, MATLAB Agentic Toolkit, Simulink Agentic Toolkit, matlab-create-course-activity, simulink-create-course-activity, and the existing matlab-generate-grader-assessments skill.
license: https://www.mathworks.com/content/dam/mathworks/license/pmrl/license.md
metadata:
  author: MathWorks
  version: "1.0"
---

# MATLAB Course Designer

Create a complete MATLAB and Simulink enabled course package through an
instructor interview. The final deliverable is an IMS Common Cartridge `.imscc`
file plus reviewable source artifacts for the instructor.

The generated course must conform to the MATLAB Course Designer organization
model: one course contains one or more ordered modules, and each module contains
one or more ordered learning activities. Preserve this hierarchy in all
intermediate artifacts so future API work can create MATLAB Course Designer
course instances directly. Use the public MATLAB Course Designer documentation
as the source for this hierarchy:
<https://www.mathworks.com/help/matlab-and-simulink-online-courses/matlab-course-designer.html>.

Do not hand-roll workflows that already exist in prerequisite skills:

- Use IDStack for instructional design pipeline work and Common Cartridge export.
- Use the MATLAB Agentic Toolkit for MATLAB activity, code, data, validation, and
  live-script-ready guidance.
- Use the `matlab-create-course-activity` skill to create Course Designer-ready MATLAB
  Exercise folders by wrapping `matlab-generate-grader-assessments` output and validating generated `.m`
  files with MATLAB MCP Server tool calls.
- Use the Simulink Agentic Toolkit for Simulink model activity design, model
  validation, and testing guidance.
- Use the `simulink-create-course-activity` skill to create Course Designer-ready
  Simulink Exercise folders with starter and solution `.slx` files.
- Use the existing `matlab-generate-grader-assessments` skill as the first authoring step for MATLAB
  Exercise component parts, because MATLAB Course Designer MATLAB Exercises are
  structurally close to MATLAB Grader assessment items.

## Input

The user may have provided course context in their request.
If it is missing or too vague, collect the minimum instructor context in Step 1
before generating anything.

## Reference Files

Read these references from the `references/` directory alongside this skill as
needed:

- `references/interview-guide.md` — instructor interview questions and defaults
- `references/instructional-design-research.md` — MATLAB/Simulink-specific
  research rules for objectives, module sequencing, and learning activities
- `references/course-artifact-rules.md` — Course Designer hierarchy, output
  structure, and required files
- `references/matlab-simulink-activity-rules.md` — activity design rules
- `references/common-cartridge-export.md` — export and review rules

Read `references/interview-guide.md`, `references/instructional-design-research.md`,
and `references/course-artifact-rules.md` before starting the instructor
interview.

## Pipeline Overview

```
Step 1: Interview the instructor and capture course constraints
Step 2: Confirm prerequisites and output directory
Step 3: Run or prepare the IDStack design pipeline
Step 4: Add MATLAB and Simulink activity specifications and model artifacts
Step 5: Generate validated MATLAB Exercise artifacts through matlab-create-course-activity
Step 6: Verify native Course Designer activity types and assessment placement
Step 7: Export Common Cartridge through IDStack course-export
Step 8: Write instructor review checklist and final review summary
```

## Step 1: Instructor Interview

Use `references/interview-guide.md`.

Collect only missing information. If the user already supplied a syllabus,
course title, module list, or learning goals, infer what you can and ask targeted
follow-ups.

Required inputs:

- Course title and one-sentence course purpose
- Learner audience and prerequisite knowledge
- Duration, pacing, and module count
- Delivery mode: in person, online, hybrid, self-paced, or lab-supported
- Target persistence format, defaulting to Common Cartridge for MATLAB Course
  Designer review
- MATLAB scope: programming, data analysis, numerical methods, apps, hardware,
  AI, signal processing, controls, or other domain
- Simulink scope: modeling, simulation, control design, physical modeling,
  code generation, verification, or other domain
- Assessment plan: native MATLAB Exercises, Simulink Exercises, readings, and
  videos; Course Designer does not support generic assignments or discussions
- Required products and toolboxes, if known
- Accessibility, academic integrity, and institutional constraints
- Output directory, defaulting to the current working directory

If the course includes MATLAB Exercises, state that `matlab-create-course-activity`
will wrap the `matlab-generate-grader-assessments` skill, validate generated `.m` files with MATLAB MCP
tool calls, split `description.txt` into copy/paste-ready `background.m` and
`task.m` files, then enrich the activity with MATLAB Course Designer authoring
fields such as module placement.

## Step 2: Prerequisite Check

Before generating the course, verify or ask the user to confirm that these
skills/toolkits are available:

- IDStack skills, especially `needs-analysis`, `learning-objectives`,
  `assessment-design`, `course-builder`, `course-quality-review`,
  `accessibility-review`, `red-team`, and `course-export`.
  IDStack is a third-party open-source project (MIT licensed), available at
  <https://idstack.org/>; it is not bundled with this skill package
- MATLAB MCP Server connected to a licensed MATLAB session; this is the
  verifiable capability that runs all `.m` file and model validation
- MATLAB Agentic Toolkit for MATLAB workflow guidance
- `matlab-create-course-activity` skill for MATLAB Exercise `.m` file validation
- Simulink Agentic Toolkit
- `simulink-create-course-activity` skill for Simulink Exercise model files
- `matlab-generate-grader-assessments` skill from the MATLAB Grader Assessment Item Generator package

If a prerequisite is missing, do not fabricate its output. Explain which part of
the course workflow is blocked, then continue with what remains legitimately
possible: planning artifacts always; MATLAB Exercise generation when
`matlab-create-course-activity`, `matlab-generate-grader-assessments`, and
MATLAB MCP validation are all available. A final `.imscc` export requires
IDStack course export capability.

To verify IDStack availability, look for its skills in the loaded skill folders
and for an `idstack` command on the PATH; when neither is found, treat IDStack
as missing and say so.

## Step 3: IDStack Course Design

Use IDStack as the instructional design backbone.

Before invoking IDStack, read `references/instructional-design-research.md` and
prepare a MATLAB/Simulink-specific design brief from the instructor interview.
The brief must include candidate observable objectives, proposed ordered
modules, learning activity mix, MATLAB Exercise needs, Simulink Exercise needs,
Reading and Video needs, product/toolbox assumptions, and validation
expectations. Pass that brief as context into the IDStack
needs-analysis, learning-objectives, assessment-design, and course-builder
steps.

Preferred sequence:

1. Run or invoke `idstack needs-analysis` using the interview notes.
2. Run or invoke `idstack learning-objectives`.
3. Run or invoke `idstack assessment-design`.
4. Run or invoke `idstack course-builder`.
5. Run or invoke `idstack course-quality-review`.
6. Run or invoke `idstack accessibility-review`.
7. Run or invoke `idstack red-team`.

If the user asks for a quick prototype, the review steps may be deferred, but
the final response must call out that the package is a draft until those reviews
run.

Preserve IDStack files in `.idstack/`. Do not overwrite existing
`.idstack/project.json` without reading it and preserving unrelated sections.

After IDStack course design, normalize the course source into the Course
Designer hierarchy:

1. One course record with title, description, audience, prerequisites, product
   requirements, and ordered modules.
2. Each module has a title, description, measurable module objectives, estimated
   time, and ordered learning activities.
3. Each learning activity has a title, activity type, objective alignment,
   learner task, required products, source artifacts, validation notes, and
   persistence/export notes.
4. The only allowed learning activity types are Reading, Video, MATLAB Exercise,
   and Simulink Exercise. Do not create discussions, generic assignments,
   projects, quizzes, external MATLAB Grader assessments, or QTI 3 assessments.

## Step 4: MATLAB and Simulink Enablement

Use `references/matlab-simulink-activity-rules.md`.

For each module, create or update ordered learning activities. For each
learning activity, specify:

- Learning objective alignment
- Activity type: Reading, Video, MATLAB Exercise, or Simulink Exercise
- MATLAB activity details, if MATLAB supports that objective
- Simulink activity details, if model-based work supports that objective
- Required products and toolboxes
- Learner starter artifact expectations
- Instructor solution or validation notes
- Estimated learner time and cognitive load risk
- Accessibility and alternative-access notes

For every MATLAB Exercise, use the `matlab-create-course-activity` skill to wrap the
existing `matlab-generate-grader-assessments` calls, validate `solution.m`, `template.m`, and `tests.m`
with MATLAB MCP Server tool calls, split `description.txt` into `background.m`
and `task.m`, and write Course Designer import metadata. Use broader MATLAB
Agentic Toolkit skills for specialized MATLAB code, data, toolbox workflows, or
validation inside that workflow.

For every Simulink Exercise, use the `simulink-create-course-activity` skill to create
the actual starter and solution model files and Course Designer import metadata.
That skill must use MATLAB MCP Server tool calls, following Simulink Agentic
Toolkit guidance, for model creation, inspection, editing, simulation, and
validation. Do not represent a Simulink Exercise with prose-only instructions
when the course requires model files.

## Step 5: MATLAB Exercise Authoring With `matlab-create-course-activity`

Use `matlab-create-course-activity` for every MATLAB Exercise. That skill wraps the
existing `matlab-generate-grader-assessments` skill first because MATLAB Course Designer MATLAB Exercises
and MATLAB Grader assessment items share the same core assessment-item
structure. It then validates generated MATLAB files with MATLAB MCP Server tool
calls before adding Course Designer-only fields.

For each MATLAB Exercise:

1. Convert the module objective into one measurable MATLAB learning objective.
2. Choose Script, Function, Class, or Object usage assessment type.
3. Choose formative, summative, or both based on the course assessment plan.
4. Invoke or prompt `matlab-create-course-activity`; it must call `matlab-generate-grader-assessments` to generate:
   `description.txt`, `template.m`, `solution.m`, and `tests.m`.
5. Validate `solution.m`, `template.m`, and `tests.m` with MATLAB MCP calls.
6. Store or reference generated `matlab-generate-grader-assessments` folders under `grader-items/`.
7. Split `description.txt` into `background.m` and `task.m` plain-text
   copy/paste files using the `matlab-create-course-activity` field-alignment rules:
   `background.m` contains task context, the learning objective, and necessary
   high-level information; `task.m` contains concrete learner instructions,
   required names, expected outputs, and constraints.
8. Write the Course Designer MATLAB Exercise folder under `matlab-activities/`.
9. Add Course Designer-specific fields, such as:
   - `background.m`
   - `task.m`
   - module placement and learning activity order
   - estimated time
   - prerequisite context
   - required products and toolboxes
   - learner setup notes
   - Common Cartridge persistence notes
10. Represent the generated item as a MATLAB Exercise learning activity inside
   the appropriate module, with a link back to the course module and objective.

Do not write independent `description.txt`, `solution.m`, `template.m`, or
`tests.m` files directly for MATLAB Exercises unless `matlab-create-course-activity`
or `matlab-generate-grader-assessments` is unavailable and the user explicitly accepts a planning-only
fallback. If the exercise needs Course Designer-only authoring fields, add them
after `matlab-create-course-activity` has validated the shared component parts.

## Step 6: Native Course Designer Activity Check

Before export, verify that all generated course content uses only native MATLAB
Course Designer learning activity types:

1. Reading
2. Video
3. MATLAB Exercise
4. Simulink Exercise

Represent all assessment work as MATLAB Exercise or Simulink Exercise learning
activities. Do not create standalone MATLAB Grader assessments, QTI 3 items,
generic quizzes, discussions, assignments, projects, or other external
assessment-tool artifacts.

## Step 7: Common Cartridge Export

Use `references/common-cartridge-export.md`.

Run or invoke `idstack course-export` and select IMS Common Cartridge `.imscc`.
The output must be an importable package, not just a course outline.

Common Cartridge content should preserve the Course Designer hierarchy: course,
ordered modules, and ordered learning activities. MATLAB and Simulink execution
artifacts should be represented with links, instructions, downloadable starter
files, or native MATLAB/Simulink Exercise descriptions as appropriate for the
persistence package. Assessments must remain native MATLAB Exercises or
Simulink Exercises.

State clearly that Common Cartridge is the persistence format for course content
outside MATLAB Course Designer. Generic cartridge readers do not execute MATLAB
code or Simulink models directly.

## Step 8: Final Review Artifacts

Write or update these review artifacts under the selected output directory:

- `.idstack/` course design and generated source content
- `matlab-activities/` MATLAB Exercise folders with `matlab-generate-grader-assessments` component mappings,
  `background.m`, `task.m`, Course Designer fields, MATLAB MCP validation
  reports, and metadata
- `simulink-activities/` Simulink Exercise folders with starter models, solution
  models, activity notes, Course Designer metadata, and validation reports
- `grader-items/` generated first-pass component folders used internally by
  `matlab-create-course-activity`
- `export/` Common Cartridge `.imscc` package
- `course-designer-structure.md`, the human-readable source of truth for the
  generated hierarchy
- `instructor-review-checklist.md`

Use `references/course-artifact-rules.md` for file naming and checklist content.

## Output Rules

- Default to a practical interview and generation workflow; ask only questions
  that affect the course package.
- Keep all course content aligned to measurable objectives.
- Preserve the Course Designer organizational model in generated source:
  course -> modules -> learning activities.
- For MATLAB Exercise learning activities, use `matlab-create-course-activity` to wrap
  `matlab-generate-grader-assessments`, validate generated `.m` files with MATLAB MCP calls, and add
  Course Designer copy/paste fields `background.m` and `task.m`.
- For Simulink Exercise learning activities, generate and validate starter and
  solution `.slx` files with `simulink-create-course-activity`.
- Use only native Course Designer activity types: Reading, Video, MATLAB
  Exercise, and Simulink Exercise.
- Implement assessment work as MATLAB Exercises or Simulink Exercises, not
  standalone MATLAB Grader, QTI 3, quiz, assignment, discussion, or project
  artifacts.
- Prefer existing prerequisite skills over newly invented templates.
- For generated course text, avoid claiming MATLAB or Simulink runs inside the
  persistence package unless an integration has been explicitly provided.
- Use "Common Cartridge" or "IMS Common Cartridge" in instructor-facing text;
  use `.imscc` for the package file extension.
- End with the exact `.imscc` path, review folder path, known limitations, and
  recommended instructor validation steps.
  When export could not run because a prerequisite was missing, end instead with
  what was actually produced, what is blocked, and what unblocks it; never
  invent an `.imscc` path.
