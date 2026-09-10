# MATLAB Grader setup: Greet a user

Purpose: summative  
Complexity: moderate  
Submission type: Function

## Student Template Line Locks

Line numbers are 1-based and refer to the final `template.m` exactly as generated. After pasting `template.m` into MATLAB Grader, lock the listed lines in the student template editor.

| Line(s) | Lock? | Exact template text | Reason |
| --- | --- | --- | --- |
| 1 | Yes | `function greeting = greetUser(name) %#ok<INUSD>` | Keeps the required function signature unchanged. |
| 2 | Yes | `%greetUser Create and display a greeting for one person.` | Keeps the function help summary visible. |
| 4 | Yes | `    greeting = "";` | Preserves the provided starter output assignment. |
| 6 | Yes | `end` | Preserves the required function structure. |

| Requirement / LO evidence | Grader Test Type | MATLAB Grader UI fields | Code to paste | Expected evidence | Optional feedback on incorrect submission | Traceability |
| --- | --- | --- | --- | --- | --- | --- |
| The function accepts a name and returns the requested greeting. | MATLAB Code | Assessment name: `Return the requested greeting` | See `tests.m`, section `Assessment: Return the requested greeting`. | `greeting` equals the result of `reference.greetUser(name)`. | — | LO: function input and output |
| The function has a visible Command Window side effect. | MATLAB Code | Assessment name: `Displays returned greeting` | See `tests.m`, section `Assessment: The function displays the greeting`. | Captured student display contains the result of `reference.greetUser(name)`. | The function must display the same greeting that it returns. | LO: function side effect |

Set **How to call the function (when the learner clicks 'Run')** to the contents of `function_call.m`. Add both assessments as **MATLAB Code** and paste their matching sections from `tests.m`.
