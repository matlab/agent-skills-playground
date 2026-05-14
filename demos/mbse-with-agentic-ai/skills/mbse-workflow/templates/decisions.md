# {{SystemName}} — Decision Log

Append-only log of non-obvious design decisions made while building this project. Each entry captures enough context that a future reader — another engineer, another Claude session — can understand *why* a choice was made without reverse-engineering the code.

## Format

Each entry follows this shape:

    ## YYYY-MM-DD — Phase N — <short decision title>
    **Context:** Why this decision point came up; what prompted the choice.
    **Options considered:** A / B / C (omit if only one was seriously on the table)
    **Chosen:** <selected option>
    **Rationale:** Tradeoff that settled it, or the stakeholder preference that drove it.
    **Revisit if:** Condition under which this decision should be reopened.

## When to append

- At any phase checkpoint where the selected approach **was not forced by the requirements** — naming conventions, decomposition granularity, scope trims, stereotype property choices, how to handle budget-SR verification, etc.
- When the user **rolls back or redirects** a phase — record both the original choice and the reason for the change. Don't silently overwrite earlier entries; add a new one.
- When scope expands or contracts mid-project.

Skip entries for:
- Mechanical steps (e.g. "created the .prj file")
- Decisions fully determined by the SRs (no judgment was required)
- Bug fixes or API-level iteration (those go in commit messages, not decisions)

---

## {{Date}} — Phase 0 — Initial project scoping

**Context:** Phase 0 interview established system identity, folder layout, requirements source, engineering concerns, and analysis scope.

**Chosen:**
- System name: {{SystemName}}
- Project folder: {{ProjectFolder}}
- Requirements source: {{RequirementsSource}}
- Engineering concerns (stereotype scope): {{EngineeringConcerns}}
- Analysis scope: {{AnalysisScope}}

**Rationale / decision context (Q7):** {{DecisionContextFromQ7}}

**Revisit if:** Requirements source changes or engineering-concern scope expands.
