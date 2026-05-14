# {{ProjectName}} — Decision Log

Append-only log of non-obvious design decisions made while building this project. Each entry captures enough context that a future reader — another engineer, another Claude session — can understand *why* a choice was made without reverse-engineering the code.

## Format

Each entry follows this shape:

    ## YYYY-MM-DD — <milestone or phase> — <short decision title>
    **Context:** Why this decision point came up; what prompted the choice.
    **Options considered:** A / B / C (omit if only one was seriously on the table)
    **Chosen:** <selected option>
    **Rationale:** Tradeoff that settled it, or the stakeholder preference that drove it.
    **Revisit if:** Condition under which this decision should be reopened.

## When to append

- At any checkpoint where the selected approach **was not forced by the requirements** — naming conventions, decomposition granularity, scope trims, etc.
- When work **rolls back or redirects** — record both the original choice and the reason for the change. Don't silently overwrite earlier entries; add a new one.
- When scope expands or contracts mid-project.

Skip entries for:
- Mechanical steps (e.g. "created the .prj file")
- Decisions fully determined by the inputs (no judgment was required)
- Bug fixes or API-level iteration (those go in commit messages, not decisions)
