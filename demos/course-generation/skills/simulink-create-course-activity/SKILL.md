---
name: simulink-create-course-activity
description: Create MATLAB Course Designer Simulink Exercise learning activities with starter and solution Simulink model files. Use when the user asks to create a Simulink activity, Simulink Exercise, starter model, solution model, model-based learning activity, or Course Designer-ready Simulink artifact. Uses MATLAB MCP Server tool calls and Simulink Agentic Toolkit guidance to create, inspect, edit, simulate, and validate model files.
license: https://www.mathworks.com/content/dam/mathworks/license/pmrl/license.md
metadata:
  author: MathWorks
  version: "1.0"
---

# Simulink Course Activity Generator

Create MATLAB Course Designer-ready Simulink Exercise learning activities. The skill
must produce actual starter and solution model files, not only instructions.
Use MATLAB MCP Server tool calls, following Simulink Agentic Toolkit guidance,
to create, edit, inspect, and validate the models. The resulting activity folder
should be ready for Course Designer web application import workflows, with
`course-designer-activity.json` as the import-oriented metadata sidecar.

## Input

The user may have provided a module objective or activity idea in their request.
If it is missing or too vague, collect the missing activity inputs in Step 1.

## Reference Files

Read these references from the `references/` directory as needed:

- `references/model-generation-workflow.md` — starter/solution model workflow
- `references/course-designer-artifacts.md` — output folder and metadata rules
- `references/validation-rules.md` — validation and review gates

Read `references/model-generation-workflow.md` and
`references/course-designer-artifacts.md` before creating model files.

## Required Tooling

Use Simulink Agentic Toolkit guidance for model construction and inspection.
When editing models, follow the `building-simulink-models` workflow:

1. Use `model_read` or `model_overview` before edits when a model exists.
2. Use `model_edit` for structural edits and parameter configuration.
   Treat a `status: partial` result as a failure until every reported
   parameter rejection is resolved and the intended values are confirmed with
   `model_query_params`; a partial edit can leave a block at a silently wrong
   default that `model_read` and `model_check` do not surface.
3. Use `model_read`, `model_overview`, and `model_query_params` to verify.
4. Use MATLAB MCP calls such as `evaluate_matlab_code`, `run_matlab_file`,
   `check_matlab_code`, and `detect_matlab_toolboxes` for model setup scripts,
   toolbox checks, simulation smoke tests, and file existence checks.
5. Use `model_test` for behavioral tests when a Gherkin validation spec is
   created, the testing workflow is available, and the model exposes at least
   one Inport; otherwise use the `matlab.unittest` fallback in
   `references/validation-rules.md`.

The `building-simulink-models` workflow starts with custom-library gates.
For course activities built from base MATLAB and Simulink blocks, answer the
custom-library question with "none" and keep the resulting `.satk/`
configuration in the course output folder, not in this skill package.

Do not rely on prose-only model descriptions for final artifacts.

## Pipeline Overview

```
Step 1: Collect activity inputs and Course Designer placement
Step 2: Confirm products, toolboxes, and output folder
Step 3: Create the solution model with MCP tool calls
Step 4: Create the starter model from the solution model
Step 5: Validate solution and starter models
Step 6: Write Course Designer-ready activity metadata and review notes
```

## Step 1: Activity Inputs

Collect only missing information:

- Course title or course identifier
- Module title and module order
- Learning activity title and activity order
- Module objective and observable learner outcome
- Simulink concept: modeling, simulation, controls, physical modeling,
  verification, code generation, or another domain
- Learner task and expected model behavior
- Required MATLAB, Simulink, and toolbox products
- Starter model scope: what should be missing, incomplete, or configurable
- Solution model scope: complete expected behavior
- Validation requirements: simulation output, signal behavior, parameter values,
  model structure, or manual rubric
- Output directory

Default to a Course Designer learning activity type of `Simulink Exercise`.

## Step 2: Product and Output Checks

Use `detect_matlab_toolboxes` when available to confirm MATLAB, Simulink, and
required toolbox access. If a needed toolbox is missing, stop before creating a
misleading model and report the blocked requirement.

Create or use this output folder:

```text
simulink-activities/module-NN-activity-MM-[slug]/
```

All generated file names must be stable, lowercase, and Course Designer import
friendly.

## Step 3: Create Solution Model

Use `references/model-generation-workflow.md`.

Create the complete solution model first. The solution model is the instructor
reference and the source used to derive the starter model.

Required actions:

1. Create or open the model using MATLAB MCP calls.
2. Use `model_edit` for blocks, connections, parameters, model configuration,
   and subsystem structure.
3. Use `model_read` or `model_overview` to verify topology.
4. Save the model as:

```text
[activity-slug]_solution.slx
```

## Step 4: Create Starter Model

Create the starter model from the validated solution model. Remove, mask,
disable, parameterize, or replace only the parts learners are expected to
complete.

Required actions:

1. Copy or save the solution model as:

```text
[activity-slug]_starter.slx
```

2. Use `model_edit` to create the intended learner gaps.
3. Use `model_read` or `model_overview` to confirm the starter model still
   opens and contains the expected scaffold.
4. Do not leave broken model references, missing files, or unresolved variables
   unless they are explicitly part of the learner task.

## Step 5: Validate Models

Use `references/validation-rules.md`.

At minimum:

- Confirm both `.slx` files exist.
- Open or inspect both models through MCP calls.
- Run a simulation smoke test on the solution model when simulation is part of
  the activity.
- Confirm the starter model contains the intended learner gaps.
- Confirm required variables are supplied through a model workspace, data
  dictionary, or init script included with the activity.
- Write validation results to `validation-report.md`.

When behavioral validation is needed, create a Gherkin validation spec and run
`model_test` when the testing workflow is available and the model has at least
one Inport; for self-contained stimulus models, use the `matlab.unittest`
fallback in `references/validation-rules.md` instead.

## Step 6: Course Designer Activity Artifacts

Use `references/course-designer-artifacts.md`.

Write these files in the activity folder:

- `[activity-slug]_starter.slx`
- `[activity-slug]_solution.slx`
- `activity.md`
- `instructor-notes.md`
- `validation-report.md`
- `course-designer-activity.json`
- Optional init scripts, data files, requirements files, or validation specs

The `course-designer-activity.json` file is the import-oriented sidecar for
future Course Designer API work. It must include course, module, learning
activity, model file, product, and validation metadata.

## Output Rules

- The final answer must list the starter model path, solution model path,
  metadata path, and validation report path.
- Do not claim the models are ready unless the validation gates passed.
- If validation is partial, state exactly which checks were deferred.
- Keep starter and solution models separate; do not overwrite one with the other.
- Preserve the Course Designer hierarchy: course -> module -> learning activity.
