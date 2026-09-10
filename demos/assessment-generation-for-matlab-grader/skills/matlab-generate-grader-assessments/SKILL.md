---
name: matlab-generate-grader-assessments
description: Generate MATLAB Grader assessment items that are suitability-gated, profile-driven, feedback-aware, and validated through MATLAB MCP. Produces Script, Function, Class Definition, Class Inheritance, Object Usage, and Class Methods items with MATLAB Grader assessment setup instructions.
license: MathWorks BSD-3-Clause (see LICENSE)
metadata:
  author: MathWorks
  version: "2.0"
---

# MATLAB Grader Assessment Item Generator

Generate complete, reviewable MATLAB Grader assessment items from an observable MATLAB-code learning objective. This skill supports **Script**, **Function**, **Class Definition**, **Class Inheritance**, **Object Usage**, and **Class Methods** items.

An item folder contains `description.txt`, `solution.m`, `template.m`, and `assessments.md`; for Function, Class Definition, Class Inheritance, and Class Methods items, it also contains `function_call.m`. `tests.m` is created only when the item needs one or more **MATLAB Code** assessments. Referenced class, helper, and data files must be human-readable source or data files and must be documented in `assessments.md`; do not generate `.p` files.

## Staged loading

Read `matlab-grader-course-profile.md` in the course-material root before
proposing an item. If it is absent, complete the one-time setup below first.

Load reference files only for the current stage:

| Stage | Load |
| --- | --- |
| Suitability and proposal | `references/assessment-item-types.md`, `references/options-prompt.md` |
| Student artifacts | `references/description-prompt.md`, `solution-prompt.md`, `template-prompt.md` |
| Function and class run artifacts | `references/function-call-prompt.md` |
| Assessment configuration | `references/tests-prompt.md` |
| Assessment rationale or feedback design | `references/assessment-research.md` |
| QTI export | `references/qti3-prompt.md` |
| Combined output | `references/all-grader-items-template.md` |

Do not preload references for later stages.

MATLAB MCP is mandatory. Confirm that a working MATLAB MCP session can run a small MATLAB command before proposing or generating an item. If it cannot, stop and say that generation is blocked; do not claim that code or assessments have been validated.

Use `matlab-read-doc` when current MATLAB Grader behavior or MATLAB syntax needs verification. Use `matlab-debugging` only to diagnose a failed MATLAB MCP validation.

## One-time course profile setup

Create `matlab-grader-course-profile.md` with YAML front matter and readable Markdown body. Ask explicit questions for only missing values; never present “press Enter for defaults.”

The front matter must include:

```yaml
---
profile_version: 1
output_location: assessments
assessment_purpose: summative
qti3_export: false
require_matlab_mcp: true
content_language: auto
language_policy:
  comments: match_content_language
  feedback: match_content_language
  assessment_names: match_content_language
  instructor_setup: english
  preserve_code_identifiers: true
coding_practice_progression:
  enabled: true
  low: [descriptive names, string literals for new text]
  moderate: [descriptive names, string literals for new text, avoid unsafe dynamic-workspace functions]
  high: [descriptive names, string literals for new text, avoid unsafe dynamic-workspace functions, concise functions]
learning_objectives:
  - objective: "..."
    allowed_complexity: [low, moderate]
    preferred_submission: Script
---
```

Document that `low`, `moderate`, and `high` are the only complexity labels. The coding-practice progression is an authoring gate and learner guidance; it is not a student scoring criterion unless a future objective explicitly makes it assessable.

`content_language` controls student-facing language. Use `auto` to infer the resolved content language from the approved problem description or task statement for each item. Use a BCP 47 or ISO-style language code such as `en`, `es`, or `ko` to force all generated items to that language. If an older profile omits `content_language`, default to `auto`. When auto-detection is ambiguous or the prompt mixes languages, use the dominant language of the student-facing problem description.

Apply `language_policy` after resolving the content language. Generate student-facing prose, code comments, learner-visible assessment names, and optional feedback in the resolved content language. Preserve MATLAB code, identifiers, function signatures, class names, variable names, file names, MATLAB keywords, MATLAB Grader test type labels, and instructor-facing setup headings unless the user explicitly asks to localize them.

## Suitability and proposal gate

Before generation, determine whether the objective has observable MATLAB-code evidence: a workspace variable, function output, required construct, prohibited shortcut, or input-contract behavior.

- If it does not, stop. Explain why MATLAB Grader cannot directly observe the objective, propose an assessable rewording, or recommend another modality such as a written explanation, design review, or manual rubric.
- If it does, recommend Script, Function, Class Definition, Class Inheritance, Object Usage, or Class Methods and give a brief rationale.
- For learner-authored `classdef` work, warn that class definitions must be submitted as plain `.m` files, not Live Script `.m` or `.mlx` files. The submitted class must be concrete whenever assessments instantiate it.
- Do not generate a directly auto-graded learner-authored abstract-class item when validation depends on instantiation. Abstract classes are allowed as referenced superclasses; recommend a concrete subclass, object-usage task, manual review, or design rubric when the learner's submitted class itself is abstract.
- Read the objective’s allowed complexity from the profile. If the requested level is not supported, report that it is unsupported and do not add unrelated requirements to inflate complexity.

For each objective, present exactly one recommended title and task statement. Titles must describe the learning behavior and must not include a command or keyword checked by an assessment for that item. Ask only for approval or revision, and for a complexity decision only when the profile leaves it undecided. Explain “both” only when it is selected: the same item is designed for formative revision and later summative use.

## Combined single-file output

After the requested item proposals are approved and before generating artifacts, ask once per batch whether the user wants a combined `AllGraderItems.md` output. Do not ask again when the user has already explicitly requested or declined it.

- If the user selects combined output, read `references/all-grader-items-template.md` and create `AllGraderItems.md` in the profile output location.
- The file is an instructor-facing companion, not a replacement for the native item folders. Include each generated item’s title, student description, submission type, referenced files, reference solution, learner template, template line-lock setup, assessment setup, and only optional feedback entries supported by validated incorrect variants. When the item is Function, Class Definition, Class Inheritance, or Class Methods, also include the standard field **How to call the function (when the learner clicks 'Run')** containing the `function_call.m` content.
- In combined output, every fenced `Copy` block for an assessment must contain only the exact value to paste into the corresponding MATLAB Grader field. Do not include UI labels inside the fenced block. For **MATLAB Code**, the block contains only MATLAB assessment code. For **Variable equals reference solution**, surrounding prose may identify the field as the variable-name field, but the fenced block must contain only the single variable identifier, such as `result`, never `Variable name: result`. For **Function or Keyword is present** and **Function or Keyword is absent**, the fenced block must contain only the checked command or keyword, not a label.
- If the user declines combined output, generate only the native item folders and their enabled QTI companions.

## Generate the native artifacts

Create one folder named with a snake_case title under the profile output location.

### Description, solution, template, and call block

- Before writing artifacts, resolve the item language from `content_language`. Student-facing descriptions, MATLAB comments in generated code, learner-visible assessment names, and optional feedback must use that resolved content language.
- Generate only code matching the approved item mode. Use descriptive names, modern string syntax for new text outside class-property defaults, and no shadowed built-ins, `eval`, `evalin`, or `assignin`.
- For Class Definition, Class Inheritance, and Class Methods items, generate a plain `.m` `classdef` reference solution and learner template. The class name must match the submitted file name and any run-block constructor call exactly.
- For Object Usage items, generate a Script submission that instantiates or modifies objects from referenced class files; do not ask learners to redefine the referenced class in the script.
- Keep description and template requirements consistent with the solution.
- After finalizing `template.m`, derive the student-template line-lock guidance from that exact file. Use 1-based line numbers and include the guidance in `assessments.md`; do not place hidden lock markers in `template.m`.
- For **summative** items, descriptions must contain no hints, self-checks, suggested functions, solution approaches, or answer-revealing implementation guidance. State a function, construct, or approach directly in the numbered instructions only when the learning objective explicitly requires it.
- For **formative** items, a brief non-answer-revealing self-check is allowed. For **both**, include only the formative guidance explicitly approved for revision use and do not reveal summative assessment details.
- For Function and class-submission items, create `function_call.m` as a short student-facing run block with representative inputs, object construction, or method calls and no assertions. In combined single-file output, present this block under **How to call the function (when the learner clicks 'Run')**.
- For items that require referenced files such as `SignalClass.m`, `TimeSignalClass.m`, `MeasurementXYZ.mat`, or a readable helper such as `constructor_pretest.m`, list them in `assessments.md` and instruct instructors to upload them as MATLAB Grader Referenced Files. Do not create `.p` files; when hidden helper logic is desired, say that educators may manually pcode reviewed `.m` helpers before uploading.
- Create QTI 3 as an optional companion only when enabled by the profile. It preserves native artifacts but does not execute MATLAB Grader logic in a generic QTI player.

### MATLAB Grader assessment model

`assessments.md` is the authoritative MATLAB Grader setup guide. It must contain a **Student Template Line Locks** section, a requirement-to-assessment matrix, and one row per configured assessment.

The **Student Template Line Locks** section must appear before the requirement-to-assessment matrix and use this structure:

```markdown
## Student Template Line Locks

Line numbers are 1-based and refer to the final `template.m` exactly as generated. After pasting `template.m` into MATLAB Grader, lock the listed lines in the student template editor.

| Line(s) | Lock? | Exact template text | Reason |
| --- | --- | --- | --- |
```

List every template line instructors should lock. Use inclusive ranges for contiguous locked lines, such as `1-3`, and comma-separated groups only when needed, such as `1-3, 7, 11-12`. For a single locked line, include that exact line text. For a range, include the first and last line text. Lock instructor-provided scaffolding that students should not change: required task comments, fixed function signatures, fixed class names and inheritance declarations, required property or method signatures, provided setup values, `end` lines that preserve required structure, and referenced-file usage scaffolding that must remain intact. Do not lock learner implementation placeholders, blank lines intended for student work, or code regions where students must edit. If no lines should be locked, write: `No template lines need to be locked for this item.`

The requirement-to-assessment matrix must use this table:

| Requirement / LO evidence | Grader Test Type | MATLAB Grader UI fields | Code to paste | Expected evidence | Optional feedback on incorrect submission | Traceability |
| --- | --- | --- | --- | --- | --- | --- |

Use these test types precisely:

- **Variable equals reference solution** only for direct equality of exactly one student variable in a Script submission. Put that single variable in the relevant UI field; do not recreate expected logic in code. Do not use this test type for Function or class-submission items. For Object Usage Script items, prefer targeted MATLAB Code checks for object properties when they provide clearer feedback than whole-object equality.
- **MATLAB Code** for custom checks that direct equality cannot express, including one assessment that compares multiple student variables, every Function-submission output check, and class-submission checks for inheritance, properties, constructor behavior, and method behavior. A Function assessment must be self-contained: assign its test inputs, call the learner function, call the matching reference function through `reference.<functionName>`, then compare the learner output with `assessVariableEqual`. For example, `greeting = greetUser(name); greetingReference = reference.greetUser(name); assessVariableEqual('greeting', greetingReference);`. A class assessment must instantiate the learner class when concrete, instantiate `reference.<ClassName>` when a reference object is needed, run the same method calls and referenced-file setup, and compare observable properties, methods, classes, or superclass lists. Never recreate reference-solution logic or assume that `function_call.m` variables or `referenceVariables` exist in the assessment workspace. For class-sensitive Function results, compare the learner class with `class(reference.<functionName>(...))`, never a hard-coded class literal.
- **Function or Keyword is present** only when the objective explicitly requires that named construct.
- **Function or Keyword is absent** only when the objective explicitly requires implementation rather than a named prohibited shortcut.

For Script submissions, **Variable equals reference solution** passes a learner value within ±0.1% relative tolerance or ±0.0001 absolute tolerance of the reference value. Use this default for ordinary numeric comparisons, including floating-point roundoff. To override either tolerance, configure the assessment as **MATLAB Code** and call `assessVariableEqual` with the full parameter names `RelativeTolerance` or `AbsoluteTolerance`, for example `assessVariableEqual('result', expected, 'RelativeTolerance', 1e-6)` or `assessVariableEqual('result', expected, 'AbsoluteTolerance', 1e-9)`. Never use shortened names such as `RelTol` or `AbsTol`; they are not accepted for this MATLAB Grader usage.

For every configured assessment, provide a concise learner-visible assessment name in its MATLAB Grader UI fields. An assessment name for a **Function or Keyword is present** or **Function or Keyword is absent** row must describe the behavior being assessed and must not include the command or keyword checked by that row. Put the checked command or keyword only in the relevant configuration field.

Create `tests.m` only for MATLAB Code rows. Split it into clearly labeled sections, one per custom assessment. Do not use a fixed number of tests. Every check must be distinct, objective-aligned, and traceable. Reject duplicated test logic.

Fail generation when the description, template, solution, stated requirements, and `assessments.md` disagree.

### Optional feedback on incorrect submissions

During item development, create and validate targeted incorrect variants for plausible conceptual or syntactic mistakes. For each distinct assessment row, generate feedback only when a validated variant reveals a useful misconception. Do not add generic or duplicate feedback merely to fill every row.

- For **formative** items, feedback identifies the failed requirement and a productive next check. A guided correction is allowed when it is educationally useful.
- For **summative** items, feedback is diagnosis only: identify the unmet requirement or misconception without code, expected values, solution steps, or hidden-test details.
- For **both** items, label any guided feedback as formative-only so instructors can omit it in a summative deployment.
- Put the optional text in the matrix column and tell the instructor to paste it into the feedback field for that MATLAB Grader assessment. Use `—` when feedback is not appropriate.

## Quality gates and validation

Before marking output ready:

1. Use `matlab-review-code` for every generated reference solution, template, function-call block, referenced helper `.m` file, and temporary validation code. Run MATLAB Code Analyzer and consult the MATLAB coding guidelines. Errors fail generation. Resolve warnings or report why they remain. Enforce descriptive names, modern string usage outside required character-array defaults, no shadowed built-ins, and no unsafe dynamic-workspace functions.
2. Invoke `matlab-validate-function-arguments` only for Function items whose objective or profile explicitly includes an input contract or argument-validation outcome. Do not add an `arguments` block merely because an item is a Function item.
3. Inspect generated `assessments.md` and `tests.m` files for invalid tolerance parameter names. `AbsTol` and `RelTol` fail generation; replace them with `AbsoluteTolerance` and `RelativeTolerance` before validation.
4. Inspect generated student-facing prose, MATLAB comments, learner-visible assessment names, and optional feedback for the resolved content language. If the resolved content language is not English and these surfaces are obviously still English, generation is not ready; localize them before validation. Do not translate MATLAB code, identifiers, Grader test type labels, or instructor-facing setup headings.
5. Validate the **Student Template Line Locks** section against the final `template.m`. Every listed line number must exist, ranges must be valid, and the quoted template text must match the generated file. Stale line numbers or mismatched text fail generation.
6. If combined `AllGraderItems.md` output is generated, inspect every assessment `Copy` block. UI labels such as `Variable name:`, `Command or keyword:`, and `Code to paste:` must appear outside the fenced block only. For **Variable equals reference solution**, any fenced assessment field block containing anything other than the single variable identifier fails generation.
7. In an operating-system temporary directory outside the repository and instructor-facing item folder, create a class-based `matlab.unittest` harness. Use `matlab-testing` and run it through MATLAB MCP against the reference solution, a completed learner template, and targeted incorrect variants. Confirm the reference and completed template pass, concept-specific mutants fail, every requirement in the matrix is represented, and every nonempty feedback entry is backed by its linked mutant.
8. Do not leave the transient harness in the instructor-facing item folder. Report the MCP run result and its limits: it validates MATLAB behavior and the documented configuration model, while the instructor still pastes/configures the rows in MATLAB Grader.

## Output summary

For each item, report its title, resolved content language, approved complexity, item mode, folder, files, referenced files, number of template lines to lock, number and type of configured assessments, number of optional feedback entries, and the completed MATLAB MCP validation result. When created, also report the path to `AllGraderItems.md`. Never claim validation when MATLAB MCP did not complete.

## Credits

This skill is inspired by Andre Knoesen’s [MATLAB Grader Problem Generator](https://github.com/VeriQAi/MatlabGraderProblemGenerator), a web application built on the Anthropic API.
