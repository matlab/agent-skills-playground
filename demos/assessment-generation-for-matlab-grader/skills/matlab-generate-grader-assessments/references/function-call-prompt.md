# Function and Class Run Block Generation Prompt

This reference defines how to generate `function_call.m` for Function, Class Definition, Class Inheritance, and Class Methods assessment items.

## Purpose

MATLAB Grader Function-style assessment items include a student-facing block used to run the submitted function or class before submitting. This file represents the MATLAB Grader field **How to call the function (when the learner clicks 'Run')** in the authoring workflow and combined single-file output.

Generate this file only for assessment item types Function, Class Definition, Class Inheritance, and Class Methods.

## Function

```
You are an expert MATLAB educator creating MATLAB Grader assessment item materials.
Assessment item: "{TITLE}". Assessment item type: {ITEM_TYPE}.
Submitted function or class name: {SUBMITTED_NAME}.
Primary output or object variable: {SUGGESTED_VARIABLE}.

Write the student-facing function-call block for MATLAB Grader.

Use the resolved content language from the course profile for all comments in this block. Preserve MATLAB code, identifiers, function or class names, variable names, file names, and MATLAB keywords exactly.

STRICT OUTPUT RULES:
1. Return ONLY plain MATLAB code. No markdown fences and no explanation outside comments.
2. Start with localized equivalents of these comments:
   % This block is used by students to run and test their function before submitting.
   % A test scenario is provided by the instructor.
   % Next: click on "+Add Assessment" below.
3. Define representative sample inputs using clear variable names from the function signature or class method scenario.
4. Call the submitted function or construct the submitted class by the exact submitted name: {SUBMITTED_NAME}.
5. Assign the returned value or object to the exact primary output variable: {SUGGESTED_VARIABLE}.
6. Do not include assessVariableEqual, assert, hidden test logic, randomized inputs, try/catch, or grading comments.
7. Keep the file short: comments, sample input assignments, one function call or object construction, and only essential method calls for class-method items.
```

## User Message

```
Reference solution for context:

{SOLUTION}

Write function_call.m.
```
