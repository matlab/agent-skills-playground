# Requirements-Based Verification

An agent skill that generates Simulink Test Sequence harnesses for an existing model from textual EARS requirements. The workflow uses a mapping review before generation.

## Skill included

| Skill | Input and result |
|---|---|
| [simulink-test-sequence-from-ears](skills/simulink-test-sequence-from-ears/SKILL.md) | Reads EARS requirements and inspects a model's signals, buses, and enumerations. Generates Simulink Test Sequence harnesses from reviewed mappings. |

The same skill is available in the repository's [standalone skills directory](../../skills/). This demo bundles a local copy so the folder can be used on its own.

## Prerequisites

Use MATLAB R2026a or newer for the supplied example. The contribution was developed with R2026a; older releases are not validated here.

| Product | Used for |
|---|---|
| MATLAB and Simulink | Run the helpers, load models, and check generated harnesses. |
| Requirements Toolbox | Read requirement sets. |
| Stateflow | Run the ModeLogic state machine and inspect chart context. |
| Simulink Test | Create test harnesses and Test Sequence blocks. |

Install an agent that supports Agent Skills and the [MATLAB MCP Server](https://github.com/matlab/matlab-mcp-server) to let it run MATLAB code. The [Simulink Agentic Toolkit](https://github.com/matlab/simulink-agentic-toolkit) provides additional model tools and official skills.

## Setup

1. Clone this repository and open the demo folder:

   ```bash
   git clone https://github.com/matlab/agent-skills-playground.git
   cd agent-skills-playground/demos/requirements-based-verification
   ```

2. Install the directory under this demo's `skills/` using your agent's skill-installation instructions. For Claude Code, copy it to a project skill directory before starting the agent:

   ```bash
   mkdir -p .claude/skills
   cp -r skills/simulink-test-sequence-from-ears .claude/skills/
   claude
   ```

   Other agents can use the same skill folder. Keep its MATLAB helpers, references, and license with `SKILL.md`. Verify that the skill appears in the agent's available skills.

3. Prepare a working copy in MATLAB. Set `demoRoot` to this demo's absolute path:

   ```matlab
   demoRoot = "<absolute-path-to>/demos/requirements-based-verification";
   workDir = fullfile(demoRoot, "work", "mode-logic");
   assert(~isfolder(workDir), "Choose a new work folder to preserve an earlier run.");
   mkdir(workDir);
   copyfile(fullfile(demoRoot, "examples", "mode-logic", "*"), workDir);
   addpath(fullfile(demoRoot, "skills", "simulink-test-sequence-from-ears", "scripts"));
   cd(workDir);
   ```

   Set the agent's MATLAB working folder to `workDir` for discovery and harness generation. Associated harness creation saves metadata on `ModeLogic.slx`, so use this copy rather than the checked-in example. Generated work is ignored by Git.

## Generate a Test Sequence

Start with one requirement:

> Use simulink-test-sequence-from-ears to create a test for requirement 17 in HLR_ModeLogic_EARS.slreqx against the working copy of ModeLogic.slx. Show me the phrase-to-signal mappings before creating the harness.

The helper can write the review directly for that requirement:

```matlab
review = generateMappingReviewFromRequirements( ...
    'ModeLogic', 'HLR_ModeLogic_EARS.slreqx', ...
    'mapping_review_req17.yaml', 'RequirementIds', "17");
```

Review `phrase_mappings`, assumptions, open questions, and the executable assignments in the YAML. Requirement 17 checks the startup transition to Establish Communications, represented in this model by `modeEnum.WaitForComms`. After review, mark the accepted entry `status: 'approved'` and ask the agent to generate the test.

```matlab
result = buildHarnessesFromApprovedYaml( ...
    'ModeLogic', 'mapping_review_req17.yaml');
```

This creates an external harness in `test_harnesses/` and registers it on the working model. The agent can open the returned `result.test_sequence_blocks` path for inspection. Read the per-requirement diagnostics: the generator can continue after a harness fails, so an output file alone does not prove compilation succeeded.

Ask the agent to run the generated test and inspect its assertions as a separate verification step. The helper's compile check is not a simulation result. Add Requirements Toolbox traceability links separately through Simulink Test Manager.

For standalone harness files without source-model registration, pass `'AssociateWithSourceModel', false`. This stages a copy in a temporary build folder and returns that folder's path. See the [workflow details](skills/simulink-test-sequence-from-ears/references/workflow-details.md) for custom mappings and multi-step preconditions.

## Example files and limits

[examples/mode-logic/](examples/mode-logic/) contains the ModeLogic model, original and EARS requirement sets, three data dictionaries, and two enumeration classes. Keep them together when copying the example.

Several test-generation heuristics are specific to ModeLogic. Other systems require reviewed mappings and may require changes to the generation code. Supported EARS sentence patterns do not imply support for every requirement meaning, timing constraint, or state path.

`cleanupDemoEnvironment.m` is an optional upstream helper that removes all harnesses associated with ModeLogic and deletes `test_harnesses/`. Run it only in a disposable working copy when those outputs are no longer needed.

Generated tests are drafts for engineering review. This demo does not establish exhaustive coverage or certification compliance.

## Validation

Run the MATLAB tests from the demo folder:

```matlab
results = runtests(fullfile(demoRoot, "tests"));
assertSuccess(results);
```

The tests cover EARS pattern parsing, YAML round-tripping, signal assignment generation, and a compile-checked requirement 17 harness. Tests use temporary working folders. See [tests/README.md](tests/README.md) for validation details and limits.

## Contribution and maintenance

Adapted from Pat Canny's `vnv_claude_skills` contribution, revision `f52288994de86e56139beb9af2f00c2ec5fb398e` (October 8, 2026). Integration normalizes the EARS skill name to lowercase, consolidates the duplicate examples, and updates the setup and API documentation for this repository.

When updating a skill, keep its standalone copy under `skills/` at the repository root and this demo's bundled copy identical. Keep example models and tests in the demo.

The license is available in [LICENSE.md](../../LICENSE.md). The bundled skill also includes its license for standalone installation.

Copyright 2026 The MathWorks, Inc.
