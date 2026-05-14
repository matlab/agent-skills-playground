---
name: agent-skill-author
description: Use this skill when the user wants to author, design, scope, or refine an Agent Skill (a SKILL.md file). Trigger phrases include "build a new skill", "design an agent skill", "scope a SKILL.md", "how should I structure this skill", "write a skill for X", "my skill isn't working well", or any request to improve an existing SKILL.md. Walks the user through an empirical, test-first process: probe the agent for real failures, design only for genuine knowledge gaps, iterate against runnable examples, and verify across models.
license: MathWorks BSD-3-Clause (see LICENSE)
metadata:
  author: MathWorks
  version: "1.0"
---

# Authoring an Agent Skill

You are helping a user author or improve an Agent Skill. Skills are markdown files an
agent loads to handle domain-specific work it would otherwise get wrong. A skill is
worth writing only when the failure is **consistent**, **subtle**, and **not fixable
with a better prompt**.

Follow the five-stage process below. Do not skip stages.

## Stage 1: Probe for real failures

Before designing anything, find out what the agent actually gets wrong.

- Ask the user for 5 to 10 representative prompts that real users would send.
- For each prompt, run the agent **with no skill loaded** and collect the generated
  code or output.
- Run the output against real data, real APIs, or a real session. Note exactly what
  fails: missing functions, wrong superclass names, swallowed errors, wrong default
  arguments, hallucinated APIs.
- Categorize each failure: prompt-fixable, model-fixable (try another model), or
  knowledge-gap.

Only knowledge-gap failures justify a skill. If a better prompt fixes it, use a better
prompt.

## Stage 2: Identify the real knowledge gaps

Group the failures from Stage 1 by root cause. Common categories:

- **Pattern-matched from another language.** Agent invents a function because the
  same idiom exists in Python or Java (the blog's example: an `ormdelete()` that
  doesn't exist in MATLAB).
- **Wrong namespace or class path.** Agent gets the verb right but the path wrong
  (`database.orm.Mappable` vs. `database.orm.mixin.Mappable`).
- **Missing guard or precondition.** Agent omits a check the runtime requires (a
  `nargin == 0` guard for objects an ORM creates empty).
- **Wrong defaults or argument order.** Agent picks plausible-but-wrong defaults the
  documentation doesn't make obvious.
- **Drift between major API versions.** Agent uses an older or newer signature than
  the one the user actually has.

For each category, write down the **specific rule** the skill needs to teach. One
rule per failure.

## Stage 3: Design the skill

Apply these structural rules. The agent may not read your whole skill, so structure
matters.

1. **Frontmatter description is a trigger spec, not a summary.** It should describe
   when to invoke the skill, with concrete trigger phrases the agent will match on.
   The agent reads this to decide whether to load you.
2. **Most critical rules first.** Put the rules that fix the most failures at the
   top of the body. Don't bury the load-bearing rule.
3. **Progressive disclosure.** Common cases up front. Edge cases, exceptions, and
   variant APIs in later sections or in `references/`.
4. **One topic per section.** Use H2 (`##`) per topic. Consistent section order
   across your skill family makes it predictable for the agent.
5. **Show, don't tell.** Where a rule is about syntax, include a 2-to-5 line code
   example with the failing pattern and the corrected pattern side by side.
6. **Leave out what the agent gets right.** If your probing showed the agent
   handles `addComponent` correctly, don't document `addComponent`. Skills are
   compensators for failure, not API reference.
7. **Name common pitfalls explicitly.** A "Common pitfalls" section near the bottom
   for known gotchas the user might hit even with the skill loaded.

Suggested section order:

```
## When this skill applies            (1-2 paragraphs)
## Core rules                          (the load-bearing rules, in priority order)
## API patterns                        (code examples per category)
## Common pitfalls                     (gotchas, including known limitations)
## See also                            (links to references/ and related skills)
```

Use the template at [`templates/SKILL-template.md`](templates/SKILL-template.md) as
a starting point.

## Stage 4: Iterate against runnable examples

Run the same Stage 1 prompts **with the skill loaded** and the failures should drop.

- For each remaining failure, decide: tighten the skill, accept the failure (with a
  documented pitfall), or escalate (the failure isn't a skill problem).
- Test across at least two models if the user expects cross-model use. Phrasing
  that works for one model can be ignored by another.
- Read every generated output. Don't trust the model to self-report success.

Keep a short test log: prompt, model, pre-skill result, post-skill result. The log
is the evidence that the skill works; without it, you're guessing.

## Stage 5: Maintain

Skills aren't done. Models change, APIs change, and yesterday's failure becomes
today's strength (and vice versa).

- Revisit the test log when the user's product version changes, when a new model
  ships, or when users report fresh failures.
- Remove rules the agent now handles correctly without help. A bloated skill loses
  attention budget.
- When a rule needs more depth than fits, move it to `references/` and link from
  the main body.

## Anti-patterns

- **API encyclopedia.** Writing down everything the API does. Skills are not docs.
- **Theoretical gaps.** Writing rules for failures you assumed without ever
  running the agent.
- **Tone or style guidance only.** Telling the agent to "be helpful and accurate"
  with no domain-specific content.
- **Burying the lede.** Twenty paragraphs of background before the rule that
  prevents the bug.
- **One mega-skill.** A single skill covering five unrelated domains. Split it.
- **Hallucinated function names.** Trusting your own memory of the API when
  writing examples; run them.

## Decision flow

When the user asks for help, follow this order:

1. Have they probed the agent for real failures yet? If not, walk them through
   Stage 1 before discussing design.
2. Do they have a list of specific failures with root causes? If not, do Stage 2
   with them now.
3. Are they writing a new skill or improving an existing one? If improving, read
   the current SKILL.md, then identify which rules are load-bearing, which are
   dead weight, and which are missing.
4. Walk through Stages 3 and 4 explicitly. Don't draft a full SKILL.md until the
   user has a concrete rule list.

