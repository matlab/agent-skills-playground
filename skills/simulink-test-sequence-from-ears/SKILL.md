---
name: simulink-test-sequence-from-ears
description: Generate Simulink Test Sequence blocks and harnesses from EARS requirements. Use when asked to create a test case from a requirement, generate tests from a .slreqx file, or verify a Simulink model with requirement-based tests.
license: MathWorks license (see LICENSE.md)
compatibility: Requires MATLAB, Simulink, Simulink Test, and Requirements Toolbox. Stateflow is needed for chart discovery and the ModeLogic demo. The supplied example targets R2026a or newer.
metadata:
  author: MathWorks
  version: "1.0"
---

# Simulink Test Sequences from EARS Requirements

Map requirement phrases to model signals, review the mappings, and generate
Test Sequence harnesses with the bundled MATLAB helpers.

## Core rules

- Start with a YAML mapping review. Use an existing explicit approval when
  available; do not infer approval from a filename or from a mapping appearing
  obvious.
- Scope the review and generation to the requested requirement IDs.
- Resolve open questions about signals, units, enum values, precondition paths,
  and timing before generating tests. Include complete initialization,
  stimulus, and `verify()` statements.
- Associated harness creation saves registration metadata on the owner model.
  Use a writable working copy for demos. Explain this effect when preparing
  generation against a user's model.
- Inspect per-requirement warnings and compile results. The generator can
  continue after a harness fails; the final completion message and presence of
  a `.slx` file do not establish success.
- Compilation is not test execution. Run the generated test when requested,
  and distinguish a compile check from simulation and assertion results.

## Setup and inputs

Identify the model under test, the `.slreqx` requirement set, and any
`.sldd` dictionaries or enumeration classes. Resolve the folder containing
this file as `skillRoot`, then add `fullfile(skillRoot, "scripts")` to the
MATLAB path.

Run MATLAB from the model artifacts folder (or set the evaluation tool's
working-folder option). Discovery scans that folder for dictionaries and enum
classes. Verify `which("analyzeRequirements")` resolves to this installation.
The older `analizeRequirements` spelling remains a compatibility alias.

## Phase 1: Review the mappings

Use `analyzeRequirements(modelName, reqSetPath)` for requirement and model
discovery. For a review of selected requirements:

```matlab
review = generateMappingReviewFromRequirements( ...
    'ModeLogic', 'HLR_ModeLogic_EARS.slreqx', ...
    'mapping_review_req17.yaml', 'RequirementIds', "17");
```

Read [workflow-details.md](references/workflow-details.md) when constructing or
editing the YAML. Lead with `phrase_mappings` containing the requirement
phrase, model element, and interpretation. Keep generation fields in the same
file: `init_assignments`, `precondition_path`, `stimulus_assignments`, and
`verify_statements`.

Record assumptions in `test_assumptions`, unresolved meanings in
`open_questions`, and approval in `status`. Show the final review file in
the MATLAB Editor when available, unless the user requests otherwise. For
headless operation or intermediate files, pass `'OpenInEditor', false`.

Present a short mapping summary and request review when approval is missing.
After the user approves, set the accepted entries to `status: 'approved'`.
Edits with unresolved questions do not constitute approval.

## Phase 2: Generate and inspect

```matlab
result = buildHarnessesFromApprovedYaml( ...
    'ModeLogic', 'mapping_review_req17.yaml');
```

The default creates externally saved harnesses in `test_harnesses/` and
registers them on the source model. If the requested output is standalone
harness files, the staged alternative is:

```matlab
result = buildHarnessesFromApprovedYaml( ...
    'ModeLogic', 'mapping_review_req17.yaml', ...
    'AssociateWithSourceModel', false);
```

That alternative generates in a temporary workspace and copies harness files
back; it does not register them on the source model. Inspect the reported
build folder when troubleshooting dictionary or model shadowing.

Open the generated harness and relevant `result.test_sequence_blocks` when
a desktop session is available and the user has not requested headless work.
Use the returned paths to inspect the Test Sequence. Do not recreate the
bundled helpers.

## Supported patterns and limits

| EARS pattern | Form | Generated steps |
|---|---|---|
| Ubiquitous | The system shall ... | Initialize and verify |
| Event-driven | When ..., the system shall ... | Establish preconditions, trigger, verify |
| State-driven | While ..., the system shall ... | Establish the state and check behavior |
| Unwanted behavior | If ..., then the system shall ... | Apply the condition and check the response |
| Optional | Where ..., the system shall ... | Use the event-driven configurator |

The parser recognizes these sentence forms; arbitrary natural-language
requirements may need clarification. Automated phrase and precondition
inference includes ModeLogic-specific heuristics, so review mappings against
the actual system. The bundled timing defaults and one scenario per
requirement do not establish exhaustive verification.

Requirements Toolbox traceability links must be added separately through
Simulink Test Manager. Do not claim certification, standards compliance, or
complete requirement coverage from generated harnesses.

## Supporting functions

[Workflow details](references/workflow-details.md) includes the YAML schema,
a ModeLogic example, the low-level `signalMappings` struct, and the helper
catalog. Use it for custom mappings and multi-step preconditions.

Copyright 2026 The MathWorks, Inc.
