---
name: matlab-generate-grader-assessments
description: Generate MATLAB Grader assessment item sets. Use when the user asks to create MATLAB Grader assessment items, generate MATLAB assessment materials, build MATLAB homework assessment items, QTI 3 portable assessment items, or mentions "grader assessment items". Produces complete assessment item folders with description, solution, template, tests, Function call blocks, and optional QTI 3 interchange files.
license: https://www.mathworks.com/content/dam/mathworks/license/pmrl/license.md
metadata:
  author: MathWorks
  version: "1.0"
---

# MATLAB Grader Assessment Item Generator

Generate complete MATLAB Grader assessment item sets in the current agent session. Each assessment item produces
a subfolder with native artifact files (description, solution, template, tests) ready to paste into
MATLAB Grader. Function assessment items also include `function_call.m` for MATLAB Grader's
"Code to call your function" area. An optional QTI 3 interchange package can be created for
portability and sharing.

Terminology note: use "assessment item" in user-facing text. "Problem" may still appear
only in legacy compatibility identifiers or when explaining older MATLAB Grader terminology.

## Input

The user may have provided a learning objective in their request.
If they did not, collect it in Step 1.

## Reference Files

Before generating any artifacts, read the appropriate reference files from the `references/`
directory alongside this skill:

- `references/assessment-item-types.md` — assessment item type definitions, class assessments, output structure
- `references/assessment-research.md` — research-informed formative and summative assessment method
- `references/options-prompt.md` — how to generate assessment item options
- `references/description-prompt.md` — how to generate descriptions (by assessment item type)
- `references/solution-prompt.md` — how to generate solutions (by assessment item type)
- `references/template-prompt.md` — how to generate templates (by assessment item type)
- `references/function-call-prompt.md` — how to generate the student call block for Function assessment items
- `references/tests-prompt.md` — how to generate test cases (by assessment item type)
- `references/qti3-prompt.md` — how to generate optional QTI 3 item and manifest files

Read `references/assessment-item-types.md` and `references/assessment-research.md` now to load the
type definitions and assessment method.

## Pipeline Overview

```
Step 1: Collect inputs (objective, assessment item type, class assessment if applicable, assessment purpose, output format)
Step 2: Generate 4 assessment item options (varied difficulty)
Step 3: User selects which assessment items to develop
Step 4: For each selected assessment item, generate artifacts sequentially
Step 5: Write files to output subfolders and optional QTI 3 package
```

---

## Step 1: Collect Inputs

If the user provided a learning objective, confirm it. Otherwise, ask for one.

Collect the following one at a time:

### 1a. Learning Objective
If the user has not already provided one, ask: "What is the learning objective for these MATLAB Grader assessment items?"

### 1b. Assessment Item Type
Ask the user to choose an assessment item type:
- **Script** — student submits a .m script; assessed by workspace variables
- **Function** — student submits a .m function; assessed by input/output values
- **Class** — student submits a classdef .m file; assessed via instantiation
- **Object usage** — student submits a .m script that uses a provided class

### 1c. Class Assessment (only if assessment item type is Class)
If the user chose "Class", ask which aspect to assess:
1. Constructor - property assignment (blank: obj.prop = arg lines)
2. Constructor - computed property (blank: derived property computation)
3. Instance method (blank: method body)
4. Constant property (blank: value in properties (Constant) block)
5. Operator overloading (blank: overloaded operator method body)

### 1d. Number of Options
Ask: "How many assessment item options should I generate? (default: 4)"
Accept 2-6. Default to 4 if the user just presses enter or says "default".

### 1e. Output Directory
Ask: "Where should I write the assessment item folders? (default: current directory)"
Default to the current working directory. The user can specify a path.

### 1f. Assessment Purpose
Ask: "Is this assessment primarily formative, summative, or both? (default: summative)"
Default to:
- Formative if the user says practice, feedback, homework draft, tutoring, self-check,
  revision, lab prep, or low-stakes.
- Summative if the user says exam, grade, final submission, high-stakes,
  or does not specify.
- Both if the user explicitly wants practice and grading reuse.

Use `references/assessment-research.md` to apply the correct design rules:
- Formative: smaller scope, self-checks, diagnostic test names, and feedback-oriented
  evidence.
- Summative: objective-aligned independent tests, randomized hardcoding detection,
  edge cases, and minimal answer-revealing hints.
- Both: formative self-checks plus summative-grade tests.

### 1g. Optional QTI 3 Export
Ask: "Should I also create QTI 3 interchange files for portability? (default: no)"
Default to no unless the user asks for QTI, portability, standards-based assessment items,
interchange files, import/export payloads, or sharing between instructional designers.

If enabled, tell the user:
"I will create the normal MATLAB Grader files plus a QTI 3 package. The QTI files preserve
the prompt, template, function call block when applicable, solution, tests, and metadata for interchange; they do not make a
generic QTI player execute MATLAB grading logic."

---

## Step 2: Generate Assessment Item Options

Read `references/options-prompt.md` to construct the prompt.

Build the system prompt by:
1. Starting with the base system prompt from the reference
2. Replacing {NUM_OPTIONS} with the user's choice
3. Appending the assessment-item-type-specific note (Class, Function, Object usage, or nothing for Script)

Build the user message with the learning objective and assessment item type.
Use the assessment purpose to vary options:
- Formative options should be short, diagnosable, and suitable for revision.
- Summative options should measure a clear objective with reproducible evidence and
  enough complexity to distinguish levels of mastery.
- Both should be usable for practice first and grading later.

**You ARE the AI generating these options.** Do not make an API call. Instead, directly generate
the JSON array of assessment item options yourself, following the system prompt instructions exactly.

Generate exactly {NUM_OPTIONS} assessment item options as a JSON array. Each must have:
- `id` (1-based integer)
- `title` (descriptive assessment item name)
- `difficulty` ("Easy", "Medium", or "Hard" — spread across options)
- `concept_focus` (the MATLAB concept being tested)
- `brief_description` (1-2 sentence summary)
- `suggested_variable` (the primary variable/class name)
- `assessment_item_type` (must match the user's selected type)
- `assessment_purpose` ("Formative", "Summative", or "Both")

Present the options to the user in a readable table format:

```
| # | Title | Difficulty | Concept Focus | Description |
|---|---|---|---|---|
```

---

## Step 3: User Selects Assessment Items

Ask the user: "Which assessment items would you like me to develop? Enter the numbers separated by commas (e.g., 1,3,4), or 'all' for all of them."

Parse the selection into a list of assessment item IDs.

---

## Step 4: Generate Artifacts for Each Selected Assessment Item

For each selected assessment item, generate artifacts **sequentially** (each builds on the previous).
Tell the user which assessment item you're working on: "Generating artifacts for Assessment Item N: {title}..."

### 4a. Description

Read `references/description-prompt.md`. Select the correct branch for the assessment item type.
Construct the system prompt by filling in {TITLE}, {DIFFICULTY}, {OBJECTIVE}, {ASSESSMENT_ITEM_TYPE},
{ASSESSMENT_PURPOSE}, and for Class assessment items: {CLASS_NAME}, {ASSESSMENT_CONTEXT}, and the assessment-specific extra rules.
For Object usage: {OUTPUT_VAR}.
Placeholder definitions used across the reference prompts: {ASSESSMENT_CONTEXT} is a
one-sentence restatement of the class aspect selected in Step 1c; {CLASS_ASSESSMENT}
is that Step 1c option label verbatim.

Generate the description following the prompt instructions exactly.
The output must be plain text — no markdown headers, no bold/italic markers.

### 4b. Solution

Read `references/solution-prompt.md`. Select the correct branch for the assessment item type.
Fill in {TITLE}, {DIFFICULTY}, {OBJECTIVE}, {SUGGESTED_VARIABLE}.
For Function: compute {SNAKE_TITLE} from the assessment item title (lowercase, spaces to underscores, strip non-alphanumeric).
For Class: {CLASS_NAME}.
For Object usage: {OUTPUT_VAR}.

Generate the solution following the prompt instructions exactly.
The output must be pure MATLAB code — no markdown fences, no explanation text.

### 4c. Template

Read `references/template-prompt.md`. Select the correct branch for the assessment item type.
The template prompt REQUIRES the solution from step 4b as context.
For Class: select the correct blank rule based on the class assessment type.
For Object usage: extract only the student script portion.

Generate the template following the prompt instructions exactly.
The output must be pure MATLAB code with `% YOUR CODE HERE` blanks.

### 4d. Function Call (only if assessment item type is Function)

Read `references/function-call-prompt.md`.

Generate `function_call.m`, the student-facing pre-submit run block used in MATLAB Grader's
"Code to call your function" area. Use the required function name and representative sample
inputs from the generated solution. The output must be pure MATLAB code: comments plus a simple
call that assigns the function output to the primary output variable. Do not include grading
assertions, randomized hidden tests, or assessment logic.

### 4e. Tests

Read `references/tests-prompt.md`. Select the correct branch for the assessment item type.
The tests prompt REQUIRES the solution from step 4b as context.
Always include the shared quality rules.
Select the correct test order based on assessment item type and class assessment.
Apply the assessment-purpose rules from `references/assessment-research.md`:
- Formative tests should be diagnostic and interpretable.
- Summative tests should be independent, objective-aligned, randomized, and robust
  against hardcoding.
- Both should include a basic correctness test plus summative-grade edge and transfer
  tests.

Generate the tests following the prompt instructions exactly.
The output must be pure MATLAB code with `%% Test N:` section headers and `assessVariableEqual` calls.

### 4f. QTI 3 Item (only if QTI export is enabled)

Read `references/qti3-prompt.md`.

Generate one QTI 3 item XML document and one QTI 3 manifest for each selected assessment item after
the description, solution, template, optional function call, and tests exist. Use those generated
artifacts as source content.

QTI 3 export intent:
- Support portability, review, and sharing of self-describing assessment items.
- Preserve enough MATLAB Grader-specific content for a future MATLAB Grader importer or
  agent workflow to reconstruct the native assessment item folder.
- Do not claim that a generic QTI runtime can execute MATLAB code or MATLAB Grader tests.

Required source fields:
- `{TITLE}`, `{SNAKE_TITLE}`, `{DIFFICULTY}`, `{OBJECTIVE}`, `{ASSESSMENT_ITEM_TYPE}`
- `{ASSESSMENT_PURPOSE}`
- `{CLASS_ASSESSMENT}` if applicable
- `{DESCRIPTION}`, `{TEMPLATE}`, `{SOLUTION}`, `{TESTS}`
- `{FUNCTION_CALL}` if assessment item type is Function
- `{SUPPORTING_CLASS}` if object usage

Generate the QTI item XML following the reference exactly. The output must be XML only:
no markdown fences and no explanation text.

---

## Step 5: Write Output Files

For each generated assessment item, create one self-contained assessment item folder and write the
native MATLAB Grader files at the folder root. If QTI 3 export is enabled, write the QTI 3
package inside that same assessment item folder.

### Folder Naming

Convert the assessment item title to snake_case:
- Lowercase all characters
- Replace spaces with underscores
- Remove non-alphanumeric characters (except underscores)

### File Structure

Create one `{snake_title}` assessment item folder under the output directory with these
native MATLAB Grader files at the folder root:

| File | Source |
| --- | --- |
| `description.txt` | Generated description artifact |
| `solution.m` | Generated reference solution artifact |
| `template.m` | Generated learner template artifact |
| `function_call.m` | Generated student pre-submit function-call block (Function assessment items only) |
| `tests.m` | Generated tests artifact |

For **Object usage** assessment items, the solution contains two sections separated by `%%%` delimiter lines.
Split them so `supporting_class.m` contains everything between the
"%%% SUPPORTING FILE ... %%%" line and the "%%% STUDENT SCRIPT SOLUTION %%%" line,
and `solution.m` contains everything after the "%%% STUDENT SCRIPT SOLUTION %%%" line.
Exclude the delimiter lines themselves from both files.

If QTI 3 export is enabled, also create a nested `qti3` package in the same
assessment item folder: `imsmanifest.xml` at the package root and the item XML
under `qti3/items/`.

For Object usage QTI 3 exports, keep `supporting_class.m` at the assessment item folder root
alongside the other native MATLAB Grader files.

The QTI `imsmanifest.xml` inside each assessment item folder must reference that folder's item
XML using package-relative paths such as `items/{snake_title}.xml`. Use stable identifiers
derived from `{snake_title}`.

Do not delete or replace the native MATLAB Grader files when QTI export is enabled. QTI 3 is a
companion interchange representation, not the authoritative MATLAB Grader runtime format.

### Writing Files

Create each file. Strip any leading/trailing markdown fences from
generated code before writing (```matlab, ```, etc.).

After writing all files for an assessment item, confirm to the user:
"Wrote {N} files to {output_dir}/{snake_title}/"

After writing QTI files, confirm:
"Wrote QTI 3 package to {output_dir}/{snake_title}/qti3/ with 1 item file."

---

## Step 6: Summary

After all selected assessment items are generated and written, present a summary:

```
MATLAB Grader Assessment Item Generation Complete

Generated {N} assessment item(s):

  1. {title} ({difficulty}) -> {snake_title}/
     - description.txt
     - solution.m
     - template.m
     - function_call.m (Function assessment items only)
     - supporting_class.m (Object usage assessment items only)
     - tests.m
     - qti3/items/{snake_title}.xml (if QTI 3 export was enabled)

List only the lines that apply to the generated assessment item type; drop the
parenthetical qualifiers from the printed summary.

  2. ...

Output directory: {output_dir}
QTI 3 package(s): inside each generated {snake_title}/qti3/ folder (if enabled)
```

Remind the user:
- Review all generated materials before using them in MATLAB Grader
- The description goes into the "Assessment Item Description & Instructions" field
- The solution goes into "Reference Solution"
- The template goes into "Learner Template"
- For Function assessment items, `function_call.m` goes into "Code to call your function"
- Each `%% Test N:` section in tests.m becomes a separate "Assessment" test in MATLAB Grader
- For Object usage assessment items: the supporting_class.m goes into "Supporting Files".
  Upload or save it under the class's own name ({ClassName}.m); MATLAB resolves a class
  only from a file whose name matches the classdef name, so supporting_class.m is a
  packaging name, not a runnable filename
- QTI 3 output is for interchange and review; MATLAB execution semantics are preserved as
  metadata/supporting content for a future importer or agent workflow

---

## Error Handling

- If artifact generation produces markdown fences, strip them before writing
- If the user wants to regenerate a specific artifact, regenerate just that one
- If QTI XML generation produces markdown fences, strip them before writing
- If QTI export is requested after native files already exist, generate only the QTI package
  from the existing artifacts unless the user asks to regenerate native artifacts
- If the user wants to modify an artifact, use Edit on the written file
- If an assessment item title conflicts with an existing folder, ask the user before overwriting.
  Exception: a QTI-only export into an existing item folder is additive, not an overwrite, so the
  QTI-only rule above takes precedence and no confirmation is needed

## Quality Checklist

Before writing each artifact, verify:

**Description**: Plain text, no markdown formatting, includes all required sections for the assessment item type
**Solution**: Pure MATLAB code, no fences, correct structure for assessment item type
**Template**: Matches solution's variable/function/class names exactly, has `% YOUR CODE HERE` blanks only where assessed
**Function Call**: For Function assessment items only, pure MATLAB code, calls the submitted function by its exact name with representative sample inputs, and contains no grading assertions
**Tests**: 3-5 tests, uses `%% Test N:` sections, `assessVariableEqual` only, random inputs (randi/randperm), includes hardcoding detection test (exception: Constant property class items use the literal constant value and need no hardcoding test)
**Assessment method**: Purpose is identified as formative, summative, or both; tests and hints follow `references/assessment-research.md`
**QTI 3**: XML only, well-formed, one item per assessment item, manifest references the item XML inside `{snake_title}/qti3/`, native MATLAB Grader artifacts preserved in metadata/support blocks

## Credits

The concept of generating complete MATLAB Grader assessment items from a
learning objective comes from Andre Knoesen (UC Davis) and his
[MATLAB Grader Problem Generator](https://github.com/VeriQAi/MatlabGraderProblemGenerator),
a web application built on the Anthropic API.
This skill reimplements that idea as a portable agent skill.
