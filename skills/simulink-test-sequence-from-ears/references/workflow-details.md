# Test Sequence Mapping and Generation

Detailed examples for the two phases in `SKILL.md`. Set `skillRoot` to the installed skill directory. The examples illustrate ModeLogic; derive mappings from the user's actual model for other systems. Respect an explicit request for headless operation or to leave the editor closed.

## Phase 1: Requirements Analysis, Signal Discovery, and Mapping

Run via the available MATLAB code-evaluation tool. In Codex, prefer `evaluate_matlab_code` with `project_path` set to the model artifacts directory:

```matlab
addpath(fullfile(skillRoot, 'scripts'));
analyzeRequirements('ModelName', 'requirements.slreqx')
```

This prints: requirements with EARS pattern classification, model I/O ports with data types, bus element definitions, and enumeration types with values.

Before harness or Test Sequence generation, prepare the YAML mapping review and obtain approval if it is not already available. A mapping that appears obvious still needs review; an existing explicit approval does not need to be repeated.

If the user asked for a test case for one requirement, generate a requirement-specific review file directly. Do not write and open an aggregate review file first unless the user asked for all requirements.

The YAML review artifact should be written for humans first. Lead with a concise `phrase_mappings` section that maps each important phrase in the requirement text to the relevant model signal, state, or chart element. Keep generation-oriented details such as `mapping`, `init_assignments`, `stimulus_assignments`, and `verify_statements` in the same file, but treat them as secondary content that supports Phase 2.

Use the bundled helper to write a review file such as `mapping_review.yaml` in the model artifacts directory. Show the final review in the MATLAB Editor when available, unless the user requests otherwise:

```matlab
review(1).requirement_id   = "19";
review(1).summary          = "Enter Establish Communications from Land";
review(1).requirement_text = "When the system is in Land mode and the quadcopter's roll angle is less than 5 degrees, pitch angle is less than 5 degrees, and vertical velocity is less than 0.1 m/s, the system shall enter the Establish Communications mode.";
review(1).ears_pattern     = "Event-Driven";
review(1).trigger          = "the system is in Land mode and the quadcopter's roll angle is less than 5 degrees, pitch angle is less than 5 degrees, and vertical velocity is less than 0.1 m/s";
review(1).behavior         = "enter the Establish Communications mode";

review(1).phrase_mappings = [ ...
    struct( ...
        "phrase", "the system is in Land mode", ...
        "model_element", "Logic.Mode", ...
        "interpretation", "The source mode is represented by Logic.Mode == modeEnum.Land"), ...
    struct( ...
        "phrase", "roll angle is less than 5 degrees", ...
        "model_element", "State.Angles(1)", ...
        "interpretation", "Roll is State.Angles(1), checked as abs(...) < deg2rad(5)"), ...
    struct( ...
        "phrase", "pitch angle is less than 5 degrees", ...
        "model_element", "State.Angles(2)", ...
        "interpretation", "Pitch is State.Angles(2), checked as abs(...) < deg2rad(5)"), ...
    struct( ...
        "phrase", "vertical velocity is less than 0.1 m/s", ...
        "model_element", "State.V_BODY(3)", ...
        "interpretation", "Vertical velocity is State.V_BODY(3), checked as abs(...) < 0.1"), ...
    struct( ...
        "phrase", "enter the Establish Communications mode", ...
        "model_element", "Logic.Mode", ...
        "interpretation", "Verify Logic.Mode == modeEnum.WaitForComms")];

review(1).mapping.trigger = struct( ...
    "phrase", "the system is in Land mode", ...
    "model_signal", "Logic.Mode", ...
    "condition", "== modeEnum.Land", ...
    "rationale", "Stateflow Land state drives Logic.Mode to uint8(8)");

review(1).mapping.inputs = [ ...
    struct( ...
        "phrase", "roll angle is less than 5 degrees", ...
        "model_signal", "State.Angles(1)", ...
        "condition", "abs(...) < deg2rad(5)", ...
        "rationale", "Mapped from Stateflow transition term using State.Angles[0]"), ...
    struct( ...
        "phrase", "pitch angle is less than 5 degrees", ...
        "model_signal", "State.Angles(2)", ...
        "condition", "abs(...) < deg2rad(5)", ...
        "rationale", "Mapped from Stateflow transition term using State.Angles[1]"), ...
    struct( ...
        "phrase", "vertical velocity is less than 0.1 m/s", ...
        "model_signal", "State.V_BODY(3)", ...
        "condition", "abs(...) < 0.1", ...
        "rationale", "Mapped from Stateflow transition term using State.V_BODY[2]")];

review(1).mapping.behavior = struct( ...
    "phrase", "enter the Establish Communications mode", ...
    "model_signal", "Logic.Mode", ...
    "expected_value", "modeEnum.WaitForComms", ...
    "rationale", "WaitForComms state drives Logic.Mode to uint8(1)");

review(1).test_assumptions = [ ...
    "Need a precondition path that reaches Land before evaluating the REQ-19 trigger"; ...
    "State.Angles ordering is roll, pitch, yaw"; ...
    "State.V_BODY(3) is the vertical velocity component"];

review(1).open_questions = strings(0,1);
review(1).status = "needs_review";

writeMappingReviewYaml("mapping_review.yaml", review);
```

To suppress automatic opening for headless work, intermediate files, or an explicit user preference:

```matlab
writeMappingReviewYaml("mapping_review.yaml", review, 'OpenInEditor', false);
```

When generating a review for one or a few requirements, prefer the bundled helper with `RequirementIds` so the MATLAB Editor opens the intended final review file:

```matlab
generateMappingReviewFromRequirements( ...
    'ModeLogic', ...
    'HLR_ModeLogic_EARS.slreqx', ...
    'mapping_review_req17.yaml', ...
    'RequirementIds', "17");
```

For an intermediate aggregate file, pass `'OpenInEditor', false` and open only the final review. Respect a request to keep the editor closed. If the session is headless or the Editor cannot be opened, provide the file path.

The YAML file should contain, at minimum:

- `requirement_id`
- `summary`
- `requirement_text`
- `ears_pattern`
- `trigger`
- `behavior`
- `phrase_mappings`
- `mapping`
- `test_assumptions`
- `open_questions`
- `status`

Where possible, `phrase_mappings` should be the easiest section for a user to review quickly. Each entry should contain:

- `phrase`
- `model_element`
- `interpretation`

After generating the YAML, present a short summary to the user and ask them to review that file. For convenience, the summary can follow this format:

```
=== SYMBOL MAPPING SUMMARY ===

Requirement: [REQ-ID] - [Summary]
  EARS Pattern: [pattern]

  Phrase mappings:
    "[requirement phrase]" → [model element]
    Interpretation: [plain-language meaning]

    "[requirement phrase]" → [model element]
    Interpretation: [plain-language meaning]

[Repeat for each requirement]

=== ACTION REQUIRED ===
Please review the phrase mappings above and confirm:
1. Are the correct model signals or chart elements identified for each phrase?
2. Is each interpretation accurate?
3. Should any mappings be adjusted?

Reply "Approved" to proceed with test harness generation.
```

Proceed to Phase 2 once the user has approved the reviewed YAML. Edits that leave unresolved questions require another review.

## Phase 2: Generate Complete Test Sequences

After user approval, construct a `signalMappings` struct and call `generateTestSequencesFromRequirements`, or use `generateSignalMappingsFromYaml` together with `buildHarnessesFromApprovedYaml`. Do **not** regenerate the bundled functions - they are already on the path.

### Signal mapping struct fields

Each entry in `signalMappings` must have:

| Field       | Type   | Content |
|-------------|--------|---------|
| `.reqId`    | string | Requirement ID, e.g. `'17'` |
| `.pattern`  | string | EARS pattern name (see table above) |
| `.trigger`  | string | Trigger text from requirement (used in step comments) |
| `.behavior` | string | Behavior text from requirement (used in step comments) |
| `.init`     | string | MATLAB code: signal initializations (preconditions) |
| `.stimulus` | string | MATLAB code: signal changes that activate the requirement (empty string for Ubiquitous) |
| `.verify`   | string | MATLAB code: `verify()` statements checking expected outputs |

Use `sprintf` with `\n` to embed newlines in multi-line code strings.

### Example Phase 2 MATLAB call

```matlab
% Build signal mappings from approved Phase 1 analysis

signalMappings(1).reqId    = '17';
signalMappings(1).pattern  = 'Event-Driven';
signalMappings(1).trigger  = 'the flight control system powers up';
signalMappings(1).behavior = 'enter the Establish Communications mode';
signalMappings(1).init     = sprintf('GCSCmds.WIFIconnected = false;\nGCSCmds.BTconnected = false;');
signalMappings(1).stimulus = sprintf('%% At power-up, comms not yet established');
signalMappings(1).verify   = sprintf('verify(Logic.Mode == modeEnum.WaitForComms, ''Mode should be WaitForComms at power up'');');

% Add one entry per approved requirement...

generateTestSequencesFromRequirements('ModeLogic', signalMappings);
```

### Preferred approved-YAML flow

To create an associated external harness for the model under test, use the bundled wrapper:

```matlab
buildHarnessesFromApprovedYaml('ModeLogic', 'mapping_review.yaml')
```

This converts the approved YAML into `signalMappings` and, by default, creates associated external harnesses directly against the source model in `test_harnesses/`. The source model `.slx` must be writable because Simulink saves harness registration metadata on the owner model.

If the source model cannot be updated directly and you only want copied harness `.slx` files, use the staged fallback explicitly:

```matlab
buildHarnessesFromApprovedYaml('ModeLogic', 'mapping_review.yaml', ...
    'AssociateWithSourceModel', false)
```

That fallback stages the project into a writable temp folder, generates harnesses there, compile-checks them, and copies the resulting `.slx` files back into `test_harnesses/`, but those copied files are not registered as harnesses on the source model.

After generation, show the relevant Test Sequence block when a desktop session is available and the user has not requested headless operation. Open the harness and then the block in `result.test_sequence_blocks`:

```matlab
result = buildHarnessesFromApprovedYaml('ModeLogic', 'mapping_review.yaml');
if ~isempty(result.copied_harnesses)
    open_system(char(result.copied_harnesses(1)));
end
if ~isempty(result.test_sequence_blocks)
    open_system(char(result.test_sequence_blocks(1)));
end
```

If multiple harnesses were generated, open the Test Sequence block or blocks relevant to the approved requirement set. If the MATLAB session is headless or the model cannot be opened interactively, state that explicitly to the user.

Generate **complete signal assignments** - no TODOs, placeholders, or partial values. Every `.init`, `.stimulus`, and `.verify` field must contain valid, executable MATLAB.

## Signal Mapping Guidelines

When mapping requirement text to model signals:

1. Extract nouns/noun phrases from trigger and behavior clauses
2. Match against model I/O port names and bus element names (case-insensitive)
3. Consider common synonyms and abbreviations
4. Use enumeration values from Phase 1 output for typed signals
5. Write the Phase 1 review around phrase-level mappings first so the user can approve signal interpretation without reading generation details
6. Flag unmappable signals in the Symbol Mapping Summary for user input before proceeding
7. Record every inferred signal index, unit conversion, precondition path, and enum interpretation in the YAML review file under `test_assumptions`
8. If a mapping is ambiguous, leave it explicit in `open_questions` and wait for user feedback instead of silently choosing one interpretation
9. For startup or initialization requirements whose trigger is simulation start or a chart default transition, allow `stimulus_assignments` to be comment-only documentation of that trigger; do not invent a redundant input toggle just to populate the trigger step

## Bundled MATLAB Functions (`scripts/`)

These files are stable - do not regenerate them. Call them by name after `addpath`.

| Function                              | Purpose |
|---------------------------------------|---------|
| `analizeRequirements.m`               | Phase 1: extract requirements, I/O, bus defs, enums |
| `analyzeRequirements.m`               | Phase 1 alias for `analizeRequirements.m` |
| `generateMappingReviewFromRequirements.m` | Phase 1: infer first-pass mappings and write review YAML |
| `generateSignalMappingsFromYaml.m`    | Phase 2: convert approved YAML into `signalMappings` |
| `buildHarnessesFromApprovedYaml.m`    | Phase 2: create associated external harnesses from approved YAML, with staged copy-only fallback |
| `writeMappingReviewYaml.m`            | Phase 1: write YAML review artifact for user approval and open it in the MATLAB Editor when available |
| `parseEARSPattern.m`                  | Detect EARS pattern from requirement text |
| `generateTestSequencesFromRequirements.m` | Phase 2: create harnesses and compile-check them from signalMappings |
| `configureTestSequence.m`             | Dispatch to pattern-specific configurator |
| `configureEventDriven.m`              | Event-Driven steps |
| `configureStateDriven.m`              | State-Driven steps |
| `configureUnwantedBehavior.m`         | Unwanted Behavior steps |
| `configureUbiquitous.m`               | Ubiquitous steps |

## Notes

- One test harness is created per requirement entry in `signalMappings`
- The preferred wrapper creates associated external harnesses directly in the source workspace and saves the owner model so the harness remains registered to the model under test
- Use `'AssociateWithSourceModel', false` only when you need staged copy-only `.slx` outputs and do not require source-model harness association
- After Phase 2 generation, open the harness from the source workspace when a MATLAB desktop session is available so the user can inspect the result immediately
- Requirements traceability links should be added manually via Simulink Test Manager
- The generated YAML review should lead with human-readable `phrase_mappings` and may also include inferred multi-step precondition paths when the model context supports them
- `analizeRequirements.m` is kept for backward compatibility; `analyzeRequirements.m` is the preferred spelling for new agent instructions
- `analizeRequirements.m` scans the current MATLAB folder for `.sldd` files and enumeration `.m` files, so Phase 1 should run with `project_path` set to the model artifacts directory or with those folders added to the MATLAB path first
- The YAML review artifact is the approval record for Phase 1; do not skip it even when the mapping seems direct from the model
- Show the final YAML review in the MATLAB Editor when available; respect an explicit request to suppress opening
- After staged harness generation, temp models or data dictionaries may remain open in the MATLAB session and can shadow source `.sldd` files; before reopening source artifacts, close staged dictionaries or call `Simulink.data.dictionary.closeAll` if dictionary-shadowing warnings appear
