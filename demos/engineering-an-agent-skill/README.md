# Engineering an Agent Skill

A demo showing how to author an Agent Skill the empirical way: probe the agent for real failures, design only for the gaps that need filling, and iterate against runnable examples.

This demo accompanies the blog post [How to engineer an AI skill for MATLAB](https://blogs.mathworks.com/matlab/2026/05/11/how-to-engineer-an-ai-skill-for-matlab/) (MathWorks, May 2026).

## What you'll do

You'll pick a piece of MATLAB or Simulink work an agent struggles with, probe the failures with a small set of prompts, and build a SKILL.md that fixes the failures you actually saw, not the ones you guessed at. The `agent-skill-author` skill in this folder runs the process with you.

## The process

The blog argues for a test-first loop. Build a skill only when failures are consistent, subtle, and not fixable with a better prompt.

```
1. Probe          Run real prompts with NO skill loaded. Collect failures.
2. Identify gaps  Group failures by root cause. Drop the prompt-fixable ones.
3. Design         Write rules in priority order. Lead with the load-bearing fix.
4. Iterate        Run the same prompts WITH the skill. Tighten until they pass.
5. Maintain       Revisit when the model or product changes.
```

Each stage has decision criteria built into the `agent-skill-author` skill.

## Skills included

| Skill | Role |
|---|---|
| [`agent-skill-author`](skills/agent-skill-author/SKILL.md) | Walks you through the five-stage process, applies structural conventions, and points at a SKILL.md template. |

## Prerequisites

- A coding agent that supports Agent Skills.
- Whatever you need to actually run the agent's output: MATLAB, a database, an API, a Simulink model. The process depends on running generated code against reality.
- A short list of real user prompts to test with. 5 to 10 is enough to start.

No specific MATLAB toolboxes are required by the process itself. The toolboxes you need depend on the skill you're building.

## Setup

1. **Clone this repo** if you haven't already:
   ```bash
   git clone https://github.com/matlab/agent-skills-playground.git
   ```
2. **Open the demo folder** in your agent:
   - **Claude Code**: from a terminal, `cd` into `demos/engineering-an-agent-skill/` and run `claude`. The agent will pick up the `agent-skill-author` skill in this folder's `skills/` directory.
   - **Other agents**: point the agent at `demos/engineering-an-agent-skill/skills/` per the agent's instructions for user-defined skills.

## Walkthrough

Start the conversation with the kind of skill you want to build:

> *I want to build a skill for writing System Composer architecture scripts. Help me design it.*

The `agent-skill-author` skill takes over and walks the five stages.

### Stage 1: Probe

The agent asks you for 5 to 10 prompts a real user would send (e.g., "build a System Composer model with three components and connect their ports"). You run each prompt with no skill loaded and capture the output. The agent helps you classify each result:

- **Prompt-fixable**: a clearer prompt fixed it. No skill needed.
- **Model-fixable**: a different model handles it. Document the model preference, don't write a skill.
- **Knowledge gap**: the failure repeats across attempts and models. Skill territory.

### Stage 2: Identify gaps

You bring the knowledge-gap failures back. The agent groups them by root cause and helps you write one rule per failure. Typical buckets:

- Pattern-matched from another language (agent invents a function that exists in Python but not MATLAB).
- Wrong namespace (`database.orm.Mappable` instead of `database.orm.mixin.Mappable`).
- Missing precondition (no `nargin == 0` guard).
- Wrong defaults or argument order.

### Stage 3: Design

The agent applies the structural rules: frontmatter as a trigger spec, critical rules first, progressive disclosure, one topic per section, code examples that show the wrong pattern next to the right one. You start from the template at [`skills/agent-skill-author/templates/SKILL-template.md`](skills/agent-skill-author/templates/SKILL-template.md) and fill it in.

### Stage 4: Iterate

You re-run the same Stage 1 prompts, this time with the new skill loaded. For each remaining failure, the agent helps you decide: tighten a rule, accept the failure as a documented pitfall, or escalate (it's not a skill problem). Test across at least two models if cross-model use matters.

Keep a short test log of prompt + model + pre-skill result + post-skill result. The log is the evidence the skill works.

### Stage 5: Maintain

When the product version changes, a new model ships, or fresh failures show up, revisit the log. Remove rules the agent no longer needs help with. Bloat costs attention budget.

## Anti-patterns the skill enforces against

- **API encyclopedia**: writing down everything the API does. Skills are not docs.
- **Theoretical gaps**: writing rules for failures you assumed without running the agent.
- **Burying the lede**: twenty paragraphs of background before the rule that prevents the bug.
- **One mega-skill**: a single skill covering five unrelated domains. Split it.
- **Hallucinated function names**: trusting your own memory of the API when writing examples. Run them.

## Extending

Once you've built one skill this way, the second is faster. Reuse:

- Your prompt test set (with additions for the new domain).
- Your test-log format.
- The conventions from `agent-skill-author`: section order, frontmatter shape, code-example pattern.
