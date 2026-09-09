# Template generation prompt

Return only a learner template for the approved item mode: Script, Function, Class Definition, Class Inheritance, Object Usage, or Class Methods. Preserve the solution’s given data, variable names, function signature, class name, method signatures, and required output names exactly. Replace only assessed implementation statements with clear `% YOUR CODE HERE` scaffolding.

Write scaffold comments in the resolved content language from the course profile. Localize `% YOUR CODE HERE` to a concise equivalent in that language. Preserve executable MATLAB code, identifiers, function signatures, class names, variable names, file names, and MATLAB keywords exactly.

While designing the template, identify which final lines instructors should lock in MATLAB Grader. Lock only instructor-provided scaffolding that students should not change, such as required task comments, fixed function signatures, fixed class names and inheritance declarations, required property or method signatures, provided setup values, structural `end` lines, and referenced-file usage scaffolding. Do not lock learner implementation placeholders, blank lines intended for student work, or code regions where students must edit. Return only `template.m`; the line-lock list is documented later in `assessments.md` using final 1-based line numbers.

For learner-authored class items, keep a syntactically meaningful plain `.m` `classdef` scaffold when possible and leave blanks only where the learner must complete class name, inheritance, properties, constructor, or method bodies. For Object Usage items, scaffold the object variables and referenced-class usage required by the description without redefining the referenced class.
