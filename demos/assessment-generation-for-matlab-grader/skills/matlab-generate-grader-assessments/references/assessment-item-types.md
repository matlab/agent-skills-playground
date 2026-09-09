# Supported MATLAB Grader assessment item types

| Type | Learner submission | Primary observable evidence | Extra artifact |
| --- | --- | --- | --- |
| Script | `.m` script | Workspace variables and required/prohibited constructs | None |
| Function | `.m` function | Outputs for specified calls and, when explicit, input-contract behavior; assessed with MATLAB Code | `function_call.m` |
| Class Definition | Plain `.m` concrete `classdef` file | Instantiability, superclass/value-class behavior, constructor defaults, public properties, methods | `function_call.m` |
| Class Inheritance | Plain `.m` concrete `classdef` file plus referenced superclass files | Required inheritance, inherited and added properties, methods, constructor behavior | `function_call.m`, referenced files |
| Object Usage | `.m` script plus referenced class files | Objects created from referenced classes, object property values, copy/value behavior, required commands | Referenced files |
| Class Methods | Plain `.m` concrete `classdef` file plus optional referenced class/data/helper files | Method behavior after construction and setup calls, object state changes | `function_call.m`, referenced files |

Learner-authored `classdef` files must be plain `.m` files, not Live Script `.m` or `.mlx` files. The learner-submitted class must be concrete whenever assessments instantiate it. Do not generate directly auto-graded learner-authored abstract-class items when validation depends on instantiation; abstract classes are valid as referenced superclasses for concrete subclass exercises.

Each item folder contains `description.txt`, `solution.m`, `template.m`, and `assessments.md`. Add `function_call.m` only for Function, Class Definition, Class Inheritance, and Class Methods items. Add `tests.m` only when an `assessments.md` row uses the MATLAB Code test type. List referenced files in `assessments.md` and place generated readable referenced source files in a documented referenced-file location. Do not generate `.p` files; educators may manually pcode reviewed helper `.m` files before upload when they need hidden helper logic.

`assessments.md` is the source of truth for MATLAB Grader configuration. It must include student-template line-lock setup guidance derived from the final `template.m`. Its requirement-to-assessment matrix must show that every stated requirement has one distinct, objective-aligned assessment and may include feedback on a validated incorrect submission. Feedback is optional for each assessment.

For Function items, do not configure **Variable equals reference solution**. Use **MATLAB Code** for each output check. In each assessment, assign test inputs, call the learner function and `reference.<functionName>` with those inputs, then compare the outputs with `assessVariableEqual`.

For Class Definition, Class Inheritance, and Class Methods items, use **MATLAB Code** for class behavior. Instantiate the learner class when concrete, instantiate `reference.<ClassName>` when needed, and compare observable behavior such as `superclasses(obj)`, `properties(obj)`, `methods(obj)`, constructor defaults, and method-updated property values. Use referenced files for abstract superclasses, data files, and readable helper `.m` checks.

For Object Usage Script items, use MATLAB Code assessments for object existence, class, property values, and copy/value behavior. Compare expected object state with `referenceVariables.<name>` when the reference solution creates the same script variables. Use **Function or Keyword is present** only for explicit required commands such as `whos`.
