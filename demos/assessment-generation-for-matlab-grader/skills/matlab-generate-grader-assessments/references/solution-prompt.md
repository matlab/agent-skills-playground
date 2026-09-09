# Solution generation prompt

Return only complete MATLAB code for the approved item mode: Script, Function, Class Definition, Class Inheritance, Object Usage, or Class Methods. Use descriptive names, modern string literals for new text outside required class-character defaults, and brief useful comments. Do not use `eval`, `evalin`, `assignin`, or shadowed built-ins.

Write MATLAB comments in the resolved content language from the course profile. Preserve executable MATLAB code, identifiers, function signatures, class names, variable names, file names, and MATLAB keywords exactly.

For a Function item, match the stated function name and signature exactly. Add an `arguments` block only when the objective explicitly includes an input contract or validation outcome.

For Class Definition, Class Inheritance, and Class Methods items, return a plain `.m` `classdef` file. The class name must match the requested class and file name exactly. Include inheritance syntax only when required, such as `classdef FrequencySignalClass < SignalClass`. The submitted class must be concrete when assessments instantiate it; abstract superclasses may be referenced files.

For Object Usage items, return a Script that uses referenced class files. Instantiate and modify objects as required, but do not redefine referenced classes in the script.
