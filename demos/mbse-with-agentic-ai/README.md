# MBSE with Agentic AI

A demo showing how a coding agent can drive a Model-Based Systems Engineering (MBSE) workflow in MATLAB and Simulink, from stakeholder needs through verified test cases with full bidirectional traceability.

This demo accompanies the blog post [Model-Based Systems Engineering and Agentic AI](https://blogs.mathworks.com/simulink/2026/04/26/model-based-systems-engineering-and-agentic-ai/).

## What you'll do

You'll point a coding agent at this folder and tell it what system you want to build. The agent interviews you, then walks the RFLP methodology one phase at a time: it proposes content, waits for your approval, generates the build script, runs it through MATLAB, and only moves on once you confirm.

This demo uses an intergalactic vegan soup factory as the running example. The same workflow applies to any system that fits the RFLP shape.

## The RFLP workflow

```
R  Requirements   Stakeholder Needs -> System Requirements (.slreqx)
F  Functional     What the system does: functions and abstract flows
L  Logical        What kind of element solves each function (design-agnostic)
P  Physical       How it is built: concrete components, interfaces, stereotypes
                  ----------------------------------------------------------
V  Verification   TC requirements (.slreqx): testable shall-statements
                  linked to System Requirements via Verify links
```

Each layer implements or is allocated to the layer above. Traceability links run back up. The Logical layer sits between *what the system does* and *how it is built*, capturing design-agnostic solution principles like `SensingUnit` or `ControlUnit`.

## Skills included

| Skill | Role |
|---|---|
| [`matlab-project`](skills/matlab-project/SKILL.md) | MATLAB Project foundation: `.prj` setup, file tracking, path and health rules, build-script conventions. |
| [`mbse-workflow`](skills/mbse-workflow/SKILL.md) | Orchestrator: interviews you, proposes, generates, runs, confirms. Drives the conversation. |
| [`mbse-architecture`](skills/mbse-architecture/SKILL.md) | Functional, logical, and physical models; interface dictionaries; stereotypes; allocation sets; roll-up analysis; review views. |
| [`simulink-requirements`](skills/simulink-requirements/SKILL.md) | slreq API reference: creation, links, traceability, coverage, test-case requirements. |
| [`system-composer`](skills/system-composer/SKILL.md) | System Composer API reference: ports, connections, profiles, variant components, sequence diagrams, common gotchas. |

`mbse-workflow` drives the conversation. The other four provide the API patterns it draws on. `matlab-project` is reusable for any MATLAB Project work, MBSE or otherwise.

## Prerequisites

**MATLAB and toolboxes:**

| Toolbox | Used for |
|---|---|
| MATLAB R2023a or later | Core RFLP workflow (R2024b+ for variant components and programmatic sequence diagrams) |
| System Composer | Architecture modeling, profiles, stereotypes, analysis instances |
| Requirements Toolbox | Requirement sets; Derive, Implement, and Verify links |
| Simulink | Required by System Composer and Requirements Toolbox |

**Agent and MCP bridge:**

- [Claude Code](https://claude.ai/code) (recommended) or another agent that supports Agent Skills.
- One of:
  - [Simulink Agentic Toolkit](https://github.com/matlab/simulink-agentic-toolkit) (recommended): bundles the Simulink MCP server plus official Simulink skills.
  - [MATLAB MCP Core Server](https://github.com/matlab/matlab-mcp-core-server): minimal bridge that lets agents talk to a live MATLAB session.

## Setup

1. **Install MATLAB** with the toolboxes listed above.
2. **Install the Simulink Agentic Toolkit** (or the MATLAB MCP Core Server) following the instructions in its repository.
3. **Clone this repo** if you haven't already:
   ```bash
   git clone https://github.com/matlab/agent-skills-playground.git
   ```
4. **Open the demo folder** in your agent. Two options:
   - **Claude Code**: from a terminal, `cd` into `demos/mbse-with-agentic-ai/` and run `claude`. The agent will pick up the skills in this folder's `skills/` directory.
   - **Other agents**: point the agent at `demos/mbse-with-agentic-ai/skills/` per the agent's instructions for user-defined skills.

## Walkthrough

Start with a single sentence:

> *I want to set up a new MBSE project for an intergalactic vegan soup factory.*

The `mbse-workflow` skill takes over. It interviews you on:

- The system you want to model.
- The stakeholder needs (drop in an Excel file or describe them in conversation; the agent will draft and iterate with you).
- The engineering concerns the architecture has to surface, and the review views you want on it. Both answers shape the component stereotypes, since you can only filter views on properties you put on the stereotype.

From there, the agent walks each RFLP phase as a five-step loop:

| Step | What happens |
|---|---|
| **Propose** | Agent drafts the content in plain language. |
| **Approve** | You review and request changes. |
| **Generate** | Agent writes an idempotent MATLAB build script. |
| **Run** | Agent runs the script through the MATLAB MCP bridge. |
| **Confirm** | Results are shown; you approve before the next phase. |

You can jump into any phase. The workflow is not strictly sequential. Once the agent finishes a phase, the results are persisted as a runnable MATLAB project with a single `buildAll()` entry point that rebuilds everything from scratch.

### What you'll get out of the soup factory example

- A requirement set imported from stakeholder needs, with derive links to system requirements.
- Functional, logical, and physical architecture models with interface dictionaries (ingredient type, mass, temperature, and so on).
- Requirement-to-architecture traceability via Implement links.
- Allocation sets between functional, logical, and physical layers.
- Stereotype profiles capturing design parameters like cost and mass.
- Architectural views showing cost drivers and mass contributors.
- A roll-up analysis instance model that calculates total cost and mass from component properties.
- Test-case requirements linked back to system requirements via Verify links.

## Beyond the core workflow

Two capabilities extend the base workflow when a project needs them:

- **Variant components and trade studies.** Turn a physical composite into a System Composer Variant Component. Add candidate architectures as choices (parallel vessels, larger single unit, pipelined stages) and compare them on mass, power, cost, throughput, and MTBF using a generic `tradeStudy` driver. Emits a markdown comparison table, a pass/fail matrix, and a Pareto-efficient set. See [`skills/system-composer/SKILL.md`](skills/system-composer/SKILL.md) (variant components section) and [`skills/system-composer/code/tradeStudy.m`](skills/system-composer/code/tradeStudy.m). Topology-dependent rollup (MIN vs. SUM for throughput, series vs. parallel for reliability) is covered in [`skills/mbse-architecture/references/analysis.md`](skills/mbse-architecture/references/analysis.md).
- **Sequence diagrams.** Attach a programmatic System Composer `Interaction` to the logical model for a specific operational scenario. Each message is bound to a real port pair, so structural changes surface as build errors instead of silent drift. See [`skills/system-composer/SKILL.md`](skills/system-composer/SKILL.md) (sequence diagrams section). slreq has a known limitation around persisting Verify links from an Interaction; that's documented under Common Pitfalls in [`skills/simulink-requirements/SKILL.md`](skills/simulink-requirements/SKILL.md).

Both features are optional. The core RFLP workflow runs end-to-end without either.

## Traceability map

```
Requirements links:
  Stakeholder Need  (StakeholderNeeds.slreqx)
      |--[Derive]-->  System Requirement  (SystemRequirements.slreqx)
                          <--[Implement]--  Function           (Functional.slx)
                          <--[Implement]--  Logical Component  (Logical.slx)
                          <--[Implement]--  Physical Component (Physical.slx)
                          |--[Verify]-->    TC Requirement     (TestCases.slreqx)

Architecture chain (allocation):
  Function  (Functional.slx)
      |--[F->L Allocate]-->  Logical Element  (Logical.slx)
                                  |--[L->P Allocate]-->  Physical Component  (Physical.slx)
```

All links are bidirectional.

## Extending to your own system

Once you've run the soup factory example, swap in your own domain. The workflow stays the same:

- Replace stakeholder needs with yours.
- Adjust the stereotype properties to match the engineering concerns you care about (power budget, latency, redundancy, fault rate).
- Pick the review views that matter for your design reviews.
- Let the agent regenerate the architecture and allocations.

Mid-project edits work the same way. Ask the agent to add a requirement, link it to a component, and regenerate the allocation set. The build scripts are idempotent, so re-running them is safe.

## Related products from MathWorks

- [MATLAB](https://www.mathworks.com/products/matlab.html): programming and numeric computing platform.
- [Simulink](https://www.mathworks.com/products/simulink.html): block-diagram environment for modeling, simulating, and analyzing dynamic systems.
- [System Composer](https://www.mathworks.com/products/system-composer.html): architecture modeling, profiles and stereotypes, allocations, and analysis instances.
- [Requirements Toolbox](https://www.mathworks.com/products/requirements-toolbox.html): authoring, linking, and tracing requirements across models, code, and tests.