# Single recommendation prompt

After the suitability gate and profile lookup, propose exactly one item:

```text
Title: {TITLE} (describe the learning behavior; do not include a command or keyword checked by an assessment)
Submission type: Script, Function, Class Definition, Class Inheritance, Object Usage, or Class Methods
Complexity: low, moderate, or high
Rationale: why the evidence is observable and why this submission type fits
Task statement: {TASK}
Referenced files: {NONE_OR_REFERENCED_FILES}
```

Use only complexity levels allowed by the course profile. Do not generate a menu of alternatives or increase complexity with unrelated concepts.

Resolve the content language from the course profile before proposing the item. If `content_language` is `auto`, use the dominant language of the student-facing problem description. Write the title and task statement in the resolved content language. Keep submission type labels, complexity labels, file names, MATLAB identifiers, and MATLAB terms unchanged.

For classdef submissions, include the warning that learners must use plain `.m` files, not Live Script `.m` or `.mlx` files. For abstract-class objectives, recommend a concrete subclass or object-usage task unless the learner-submitted class can be tested without instantiation.
