# Evals: MATLAB Grader assessment generation

Run each scenario with the local skills loaded. A ready item requires a completed MATLAB MCP validation run; inspect generated materials as well as the reported result.

## EV-G1: Suitability gate

**Prompt:** “Create a MATLAB Grader item for the objective: appreciate the elegance of vectorization.”

**Pass criteria:**

- [ ] The generator stops before proposal and explains that appreciation has no observable code evidence.
- [ ] It suggests an assessable rewording, such as producing a vectorized result without a loop, or recommends a written/reflection assessment.

## EV-G2: Profile reuse and complexity

**Prompt:** “Use the course profile to make an item for: create MATLAB string scalars by combining text, numeric values, and newline characters. High complexity.”

**Pass criteria:**

- [ ] The profile is read; no multi-question interview or Enter-for-default prompt appears.
- [ ] The generator reports high complexity unsupported rather than adding unrelated requirements.
- [ ] It recommends one Script task at an allowed level and asks only for approval/revision and any profile-unset complexity choice.

## EV-G3: Script direct-output item (MATLAB)

**Prompt:** “Create an approved low-complexity Script item for: create a string scalar from a name and numeric ID.”

**Pass criteria:**

- [ ] The folder has `description.txt`, `solution.m`, `template.m`, and `assessments.md`, but no `function_call.m`.
- [ ] `assessments.md` contains a requirement-to-assessment matrix and direct-output rows use Variable equals reference solution.
- [ ] `assessments.md` contains **Student Template Line Locks** with valid 1-based `template.m` line numbers and matching exact template text.
- [ ] `tests.m` is absent unless a genuinely custom MATLAB Code check is needed.
- [ ] MATLAB MCP verifies the reference and completed template pass, a relevant mutant fails, and Code Analyzer errors are absent.

## EV-G4: Function input-contract item (MATLAB)

**Prompt:** “Create a Function item for: validate that a scalar measurement is positive and return its square root.”

**Pass criteria:**

- [ ] The generator recommends Function and creates `function_call.m`.
- [ ] It uses function-argument validation guidance because the objective explicitly includes an input contract.
- [ ] `assessments.md` tells the instructor to lock the function signature line in `template.m` and leaves the learner implementation placeholder editable.
- [ ] Each Function-output MATLAB Code assessment assigns test inputs, calls the learner function and `reference.<functionName>`, then uses `assessVariableEqual` to compare their outputs.
- [ ] Validation tests behavior, template completion, and an invalid-input mutant through MATLAB MCP.

## EV-G5: All four MATLAB Grader test types

**Prompt:** “Generate a Script item whose objective explicitly requires `sort`, prohibits `sortrows`, and returns a sorted output with its input class preserved.”

**Pass criteria:**

- [ ] `assessments.md` uses Variable equals reference solution for the output, Function or Keyword is present for `sort`, and Function or Keyword is absent for `sortrows`.
- [ ] Any custom class check is MATLAB Code and compares against `class(referenceVariables.<name>)`, not a hard-coded class.
- [ ] `tests.m`, when present, contains only the custom MATLAB Code row.

## EV-G5b: Class Definition item

**Prompt:** “Generate a MATLAB Grader Class Definition item for `TimeSignalClass` with properties `time`, `timeUnit`, `data`, `dataUnit`, `description`, and `signalName`, and constructor defaults of `[]` for numeric vectors and `''` for text properties.”

**Pass criteria:**

- [ ] The generator warns that learner-authored `classdef` files must be plain `.m` files, not Live Script `.m` or `.mlx` files.
- [ ] The item is documented as Class Definition while using MATLAB Grader's Function-style run workflow.
- [ ] `function_call.m` constructs `obj = TimeSignalClass`.
- [ ] MATLAB Code assessments check value-class behavior, constructor presence, required public properties, and constructor defaults.

## EV-G5c: Object Usage with referenced class

**Prompt:** “Generate a Script item where learners instantiate referenced `TimeSignalClass.m`, create `sigObj1`, set signal metadata/time/data properties, copy it to `sigObj2`, change only `sigObj2.signalName`, and use `whos`.”

**Pass criteria:**

- [ ] The generator treats `TimeSignalClass.m` as a MATLAB Grader Referenced File.
- [ ] The item remains a Script submission and does not create `function_call.m`.
- [ ] MATLAB Code assessments check `sigObj1` and `sigObj2` existence/classes and all required property values using `referenceVariables`.
- [ ] A Function or Keyword is Present row checks `whos` only because the prompt explicitly requires it.

## EV-G5d: Class Inheritance from abstract referenced superclass

**Prompt:** “Generate a Function-style class item where learners create concrete `FrequencySignalClass < SignalClass`; `SignalClass.m` is an abstract referenced superclass and `FrequencySignalClass` adds `frequency` and `frequencyUnit`.”

**Pass criteria:**

- [ ] The generator accepts the abstract superclass as a referenced file.
- [ ] The learner-submitted `FrequencySignalClass` remains concrete and is instantiated in the run block.
- [ ] MATLAB Code assessments check inheritance from `SignalClass` and `handle`, and check inherited plus added properties.

## EV-G5e: Class Methods with readable referenced helper

**Prompt:** “Generate a class-method item where learners implement `TimeSignalClass < SignalClass`, keep `importFileData`, and implement `resample`; referenced files include `SignalClass.m`, `MeasurementXYZ.mat`, and `constructor_pretest.m`.”

**Pass criteria:**

- [ ] The generator documents all referenced files and does not create `.p` files.
- [ ] If hidden helper logic is desired, the setup notes say educators may manually pcode a reviewed `.m` helper before upload.
- [ ] MATLAB Code assessments check inheritance, properties, constructor helper behavior, and `resample` behavior at multiple time grids by comparing learner and reference object state.

## EV-G5f: Unsupported abstract submitted class

**Prompt:** “Generate a MATLAB Grader item where learners submit an abstract class and the tests instantiate that class.”

**Pass criteria:**

- [ ] The generator stops before artifact generation.
- [ ] It explains that direct abstract-class creation cannot be tested by instantiation in MATLAB Grader.
- [ ] It recommends assessing a concrete subclass, object-usage task, manual review, or design rubric instead.

## EV-G6: Duplicate-check rejection

**Prompt:** “Add four tests for the same output variable.”

**Pass criteria:**

- [ ] The generator retains only distinct, requirement-aligned checks and explains why duplicate padding is rejected.

## EV-G7: MATLAB MCP unavailable

**Prompt:** “Generate a MATLAB Grader assessment item while MATLAB MCP is disconnected.”

**Pass criteria:**

- [ ] The generator stops before claiming readiness and reports that MATLAB MCP is mandatory.

## EV-G8: QTI companion export

**Prompt:** “Enable QTI in the profile and generate an approved Function item.”

**Pass criteria:**

- [ ] Native MATLAB Grader files remain authoritative.
- [ ] QTI is a companion package and does not claim generic QTI execution of MATLAB Grader logic.

## EV-G9: Optional feedback from incorrect variants

**Prompt:** “Generate a formative tolerance-comparison item and provide feedback for a reversed comparison.”

**Pass criteria:**

- [ ] The generator validates that the reversed-comparison variant fails the linked assessment.
- [ ] `assessments.md` records optional feedback on that row and the feedback identifies the comparison issue plus a productive next check.
- [ ] A row with no distinct, validated misconception uses `—` rather than generic feedback.
- [ ] Custom tolerance checks use `RelativeTolerance` or `AbsoluteTolerance` with `assessVariableEqual`; generated files do not contain `RelTol` or `AbsTol`.

## EV-G10: Summative feedback safety

**Prompt:** “Generate a summative item with feedback for an incorrect `Inf` or `NaN` classification.”

**Pass criteria:**

- [ ] Feedback identifies the unmet classification requirement without revealing the expected result, code, or an implementation route.
- [ ] The learner-facing description remains free of feedback, hints, and self-checks.

## EV-G11: Localized comments and feedback

**Prompt:** “Use `content_language: auto` and generate a formative MATLAB Grader Script item from a Korean problem description.”

**Pass criteria:**

- [ ] The generator resolves Korean as the content language and reports that language in the output summary.
- [ ] `description.txt`, MATLAB comments in `solution.m`, `template.m`, and any `tests.m`, learner-visible assessment names, and optional feedback are written in Korean.
- [ ] MATLAB identifiers, file names, MATLAB keywords, and MATLAB Grader test type labels remain unchanged and valid.
- [ ] With `content_language: es`, an English prompt still produces Spanish student-facing comments, assessment names, and optional feedback.
- [ ] A legacy profile without `content_language` still defaults to auto-detection rather than failing setup.

## EV-G12: Student template line locks

**Prompt:** “Generate a Function item where learners complete the body of `scaleSignal(x, gain)` but must not change the function signature.”

**Pass criteria:**

- [ ] `template.m` has a fixed `function` signature line and an editable learner implementation placeholder.
- [ ] `assessments.md` includes **Student Template Line Locks** before the assessment matrix.
- [ ] The lock table uses 1-based line numbers from the final `template.m`, and the quoted template text matches exactly.
- [ ] The function signature line is locked and the learner implementation placeholder is not locked.
- [ ] The output summary reports the number of template lines to lock.
