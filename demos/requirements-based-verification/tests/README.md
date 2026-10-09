# Validation

Run from MATLAB with the required products installed:

```matlab
demoRoot = "<absolute-path-to>/demos/requirements-based-verification";
results = runtests(fullfile(demoRoot, "tests"));
assertSuccess(results);
```

`earsWorkflowTest` checks all five EARS sentence patterns, YAML round-tripping, and conversion of reviewed mappings into executable signal assignments. Its integration test creates and compile-checks a requirement 17 harness in a temporary copy of the ModeLogic example. Test fixture approval is synthetic and applies only to these test inputs.

These checks do not establish exhaustive model behavior or complete requirement coverage. Harness compilation does not run the generated assertions in simulation.

During integration, all three tests passed in MATLAB R2026b. Code Analyzer found no syntax errors in the 19 helper and test files. The imported helpers retain style and performance diagnostics, and the generated harness reports an unused `testComplete` symbol.

When changing the skill, update both the standalone and bundled copies and verify that their files match. Examples and tests belong in this demo, not in the installed skill folder.

Copyright 2026 The MathWorks, Inc.
