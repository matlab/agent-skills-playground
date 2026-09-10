# MATLAB Grader setup: Compute calculator expressions

Purpose: summative  
Complexity: moderate  
Submission type: Script

## Student Template Line Locks

Line numbers are 1-based and refer to the final `template.m` exactly as generated. After pasting `template.m` into MATLAB Grader, lock the listed lines in the student template editor.

| Line(s) | Lock? | Exact template text | Reason |
| --- | --- | --- | --- |
| 1 | Yes | `% Create powerValues.` | Keeps the scaffold task label visible. |
| 4 | Yes | `% Create imaginaryRoot.` | Keeps the scaffold task label visible. |
| 7 | Yes | `% Create eValue.` | Keeps the scaffold task label visible. |
| 10 | Yes | `% Create radianCosine.` | Keeps the scaffold task label visible. |
| 13 | Yes | `% Create degreeCosine.` | Keeps the scaffold task label visible. |

| Requirement / LO evidence | Grader Test Type | MATLAB Grader UI fields | Code to paste | Expected evidence | Optional feedback on incorrect submission | Traceability |
| --- | --- | --- | --- | --- | --- | --- |
| The five calculator results are correct. | MATLAB Code | Assessment name: `Evaluate all calculator expressions` | See `tests.m`, section `Assessment: Evaluate all calculator expressions`. | Each requested variable equals its corresponding `referenceVariables` value. | — | LO: MATLAB as a calculator |
| Evaluate the square-root expression. | Function or Keyword is present | Assessment name: `Evaluate the square-root expression`; Function or keyword: `sqrt` | — | `sqrt` is present. | — | LO: mathematical functions |
| Evaluate the exponential expression. | Function or Keyword is present | Assessment name: `Evaluate the exponential expression`; Function or keyword: `exp` | — | `exp` is present. | — | LO: mathematical functions |
| Evaluate the radian-angle expression. | Function or Keyword is present | Assessment name: `Evaluate the radian-angle expression`; Function or keyword: `cos` | — | `cos` is present. | — | LO: mathematical functions |
| Evaluate the degree-angle expression. | Function or Keyword is present | Assessment name: `Evaluate the degree-angle expression`; Function or keyword: `cosd` | — | `cosd` is present. | The degree-angle calculation must use MATLAB's degree cosine function. | LO: mathematical functions |

Add the first assessment as **MATLAB Code** and paste the matching section from `tests.m`. Add one assessment for each remaining row to verify the explicitly required mathematical functions.
