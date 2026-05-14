---
name: your-skill-name
description: Use this skill when [describe the user intent in one or two sentences]. Trigger phrases include "[phrase 1]", "[phrase 2]", "[phrase 3]". Do NOT trigger for [out-of-scope cases that look similar].
license: [SPDX identifier or license name, e.g. Apache-2.0]
metadata:
  author: [your name or organization]
  version: "1.0"
---

# [Skill Title]

[One paragraph: what failure modes this skill fixes, and what kind of agent work
it applies to. Lead with the failure, not the API surface.]

## When this skill applies

- [Trigger 1: concrete situation]
- [Trigger 2: concrete situation]
- [Trigger 3: concrete situation]

Do not apply this skill when [out-of-scope situation that an agent might confuse
with the in-scope cases].

## Core rules

Rules below are ordered by how often they prevent failures. Read top to bottom.

### Rule 1: [The most load-bearing rule, in imperative form]

[2-to-4 sentences explaining the rule and why it matters.]

```matlab
% WRONG (what the agent tends to generate)
result = someApi.thingThatDoesNotExist();

% RIGHT
result = someApi.thingThatActuallyExists();
```

### Rule 2: [Next rule]

[Body and code example.]

### Rule 3: [Next rule]

[Body and code example.]

## API patterns

[Group code patterns by task. Each pattern shows the canonical call shape, the
argument types, and one realistic example. Keep examples short. Do not document
APIs the agent already handles correctly.]

### [Task name, e.g., "Creating a requirement set"]

```matlab
% Canonical pattern
[code example here]
```

[1-to-2 sentences on what to watch out for.]

## Common pitfalls

- **[Pitfall name]**: [one-sentence description of the failure and the fix].
- **[Pitfall name]**: [one-sentence description of the failure and the fix].

## See also

- `references/[file].md`: [what it covers]
- Related skill: `[other-skill-name]` for [its scope]
