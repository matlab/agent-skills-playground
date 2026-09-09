# Setup Guide Template

Use this reference when generating an instructor setup guide from a learning
objective, course title, course description, module description, lab
description, or assessment goal.

## Context Mapping

Choose the best-fit context from the input.

**Introductory MATLAB programming**

- Triggers: "intro", "beginner", "first programming", "arrays", "indexing",
  "scripts", "functions", "plotting", "loops".
- Assessment item type emphasis: Script or Function.
- Review emphasis: variable names, output shape, vectorization, simple
  randomized tests, clear learner templates.

**Engineering computation or modeling**

- Triggers: "engineering", "numerical methods", "ODE", "linear systems",
  "simulation", "modeling", "optimization", "signals", "dynamics",
  "controls".
- Assessment item type emphasis: Function for reusable computations, Script for plots
  or workflows.
- Review emphasis: units, assumptions, numeric tolerances, plots, edge cases,
  and hardcoding detection.

**Data analysis or visualization lab**

- Triggers: "data", "tables", "timetables", "import", "cleaning",
  "statistics", "visualization", "lab".
- Assessment item type emphasis: Script for workflow variables, Function for reusable
  transformations.
- Review emphasis: table variable access, missing data, plot data, labels,
  reproducibility, and workspace outputs.

**Graded homework, quiz, lab, project, or exam preparation**

- Triggers: "graded", "homework", "quiz", "exam", "summative", "final",
  "high stakes".
- Assessment-purpose emphasis: Summative.
- Review emphasis: independent randomized tests, different-range hardcoding
  detection, edge cases, and minimal answer-revealing hints.

**Practice, lab prep, tutoring, or revision**

- Triggers: "practice", "formative", "self-check", "homework draft",
  "recitation", "lab prep", "revision".
- Assessment-purpose emphasis: Formative or Both.
- Review emphasis: diagnostic test names, visible evidence, self-check prompts,
  and revision-friendly feedback.

**QTI 3 interchange or instructional-design sharing**

- Triggers: "QTI", "QTI 3", "LMS", "portable", "interchange", "import",
  "export", "instructional designer", "review package".
- Export emphasis: QTI 3 enabled.
- Review emphasis: nested `qti3/` package, XML well-formedness, metadata
  fidelity, and the limitation that generic QTI runtimes do not execute MATLAB.

## Output Format

```markdown
# MATLAB Grader Setup Guide: [Course, Module, or Objective]

## Best Fit
- Context:
- Why this fit:
- Secondary considerations:

## Recommended Assessment Configuration
- Assessment item type:
- Assessment purpose:
- Content language: [Use `auto` to match the problem description, or a language
  code such as `en`, `es`, or `ko` to force generated comments and feedback.]
- QTI 3 export: [Recommend only when the instructor asked for portability,
  LMS review, interchange, or instructional-design handoff. Otherwise state
  "No" with a one-line note on when to revisit.]
- Output folder shape:

## Starter Prompt for `matlab-generate-grader-assessments`
[Instructor-ready prompt text.]

## Artifact Review Gates
- `description.txt`:
- `solution.m`:
- `template.m`:
- Template line locks:
- `function_call.m` (Function assessment items only):
- `tests.m`:
- `qti3/` package (only when QTI 3 export is enabled):

## First Pilot
1. Generate one item:
2. Review native MATLAB Grader files:
3. Validate tests (and QTI 3 XML when export is enabled):
4. Revise and regenerate:

## Instructor Checklist
- [ ] State one measurable learning objective.
- [ ] Choose an assessment item type: Script or Function.
- [ ] Choose formative, summative, or both.
- [ ] Review all native MATLAB Grader artifacts before use.
- [ ] Parse QTI 3 XML before sharing (only when QTI 3 export is enabled).
- [ ] Record revisions for the next generation pass.

## Research Basis
[Include only when requested or useful for instructor adoption. Use
`research-summary.md` for the concise evidence map.]
```

## Prompt Patterns

Use these patterns in the starter prompt section.
Append "Include QTI 3 export." to a pattern only when the instructor asked for
portability or sharing; otherwise state "no QTI 3" in the prompt.

- Script:
  `"Create a MATLAB Grader script assessment item for [objective]."`
- Function:
  `"Create a MATLAB Grader function assessment item where students [observable behavior]. Include randomized tests."`
- Mixed practice and grading:
  `"Create this as both formative practice and summative-ready grading material, with self-checks and robust tests."`

## Review Gate Details

- `description.txt`: clear task, required names, constraints, and non-revealing
  hints; use the configured content language for student-facing prose.
- `solution.m`: runnable, concise, aligned to the stated objective.
- `template.m`: same names as the solution; blanks only where students should
  work; comments use the configured content language.
- Template line locks: `assessments.md` lists 1-based `template.m` line numbers
  to lock in MATLAB Grader; verify the quoted text still matches after any
  manual template edit.
- `function_call.m` (Function assessment items only): the three instructor
  comments at the top localized to the configured content language,
  representative sample inputs, one plain call to the required function, and no
  grading assertions; must run cleanly against the reference solution.
- `tests.m`: only distinct, objective-aligned MATLAB Code sections, with
  randomized inputs, an edge or transfer case, and hardcoding detection when
  those checks measure separate evidence; learner-visible assessment names and
  optional feedback use the configured content language.
- `qti3/`: one manifest and one item XML inside the same assessment item
  folder; metadata preserves description, template, solution, and tests.
