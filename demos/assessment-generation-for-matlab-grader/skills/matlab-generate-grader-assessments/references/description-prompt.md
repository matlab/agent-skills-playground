# Description generation prompt

Write plain student-facing text for a Script, Function, Class Definition, Class Inheritance, Object Usage, or Class Methods assessment item. Include the learning task, exact required variables, function signature, class name, superclass relationship, method behavior, referenced-file assumptions, observable expected outcome, and only constraints that the learning objective explicitly requires.

Write all student-facing prose in the resolved content language from the course profile. If the profile uses `content_language: auto`, use the dominant language of the approved problem description or task statement. Preserve MATLAB identifiers, function signatures, class names, variable names, file names, and MATLAB keywords exactly.

For formative use, include a brief non-answer-revealing self-check. For summative use, include no hints, self-checks, suggested functions, solution approaches, or answer-revealing implementation guidance. If the learning objective explicitly requires a function, construct, or approach, state it directly as a numbered requirement rather than presenting it as a hint. Explain mixed use only when the profile purpose is `both`; keep its formative guidance distinct from hidden summative details. Put feedback for incorrect submissions in `assessments.md`, never in a summative description.

For learner-authored class submissions, state that the class definition must be written in a plain `.m` file, not a Live Script `.m` or `.mlx` file. For Object Usage items, state which class files are provided as referenced files and must not be redefined by the learner.
