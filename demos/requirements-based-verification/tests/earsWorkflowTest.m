classdef earsWorkflowTest < matlab.unittest.TestCase
    %EARSWORKFLOWTEST Validate parsing, review transport, and a demo harness.

    properties
        DemoRoot (1,1) string
        TempDir (1,1) string
    end

    methods (TestClassSetup)
        function addHelpers(testCase)
            testCase.DemoRoot = fileparts(fileparts(mfilename("fullpath")));
            scriptsDir = fullfile(testCase.DemoRoot, "skills", ...
                "simulink-test-sequence-from-ears", "scripts");
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture(scriptsDir));
        end
    end

    methods (TestMethodSetup)
        function createSandbox(testCase)
            testCase.TempDir = string(tempname);
            mkdir(testCase.TempDir);
            testCase.addTeardown(@() rmdir(testCase.TempDir, "s"));
            testCase.applyFixture(matlab.unittest.fixtures.CurrentFolderFixture(testCase.TempDir));
        end
    end

    methods (Test)
        function parseSupportedPatterns(testCase)
            texts = [ ...
                "The system shall hold speed."; ...
                "When braking starts, the system shall release cruise control."; ...
                "While cruise is active, the system shall hold speed."; ...
                "If a fault occurs, then the system shall stop."; ...
                "Where cruise is enabled, the system shall hold speed."];
            patterns = ["Ubiquitous"; "Event-Driven"; "State-Driven"; "Unwanted Behavior"; "Optional"];
            for idx = 1:numel(texts)
                [pattern, trigger, behavior] = parseEARSPattern(char(texts(idx)));
                testCase.verifyEqual(string(pattern), patterns(idx));
                testCase.verifyNotEmpty(behavior);
                if idx > 1
                    testCase.verifyNotEmpty(trigger);
                end
            end
            [pattern, ~, ~] = parseEARSPattern('No testable requirement here.');
            testCase.verifyEmpty(pattern);
        end

        function roundTripReviewedAssignments(testCase)
            review = struct( ...
                "requirement_id", "42", ...
                "summary", "Release cruise control", ...
                "requirement_text", "When braking starts, the system shall release cruise control.", ...
                "ears_pattern", "Event-Driven", ...
                "trigger", "braking starts", ...
                "behavior", "release cruise control", ...
                "phrase_mappings", struct("phrase", "braking starts", ...
                    "model_element", "BrakePedal", "interpretation", "Driver's brake input is active."), ...
                "init_assignments", ["BrakePedal = 0;"; "CruiseEnabled = true;"], ...
                "precondition_path", struct([]), ...
                "stimulus_assignments", "BrakePedal = 1;", ...
                "verify_statements", "verify(CruiseActive == false, 'Cruise should disengage');", ...
                "test_assumptions", strings(0,1), ...
                "open_questions", strings(0,1), ...
                "status", "approved");
            yamlPath = fullfile(testCase.TempDir, "mapping_review.yaml");
            writeMappingReviewYaml(yamlPath, review, 'OpenInEditor', false);
            document = readMappingReviewYaml(yamlPath);
            testCase.verifyEqual(string(document.requirements.requirement_id), "42");
            testCase.verifyEqual(string(document.requirements.phrase_mappings.interpretation), ...
                "Driver's brake input is active.");
            mappings = generateSignalMappingsFromYaml(yamlPath);
            testCase.verifyEqual(string(mappings.init), strjoin(review.init_assignments, newline));
            testCase.verifyEqual(string(mappings.stimulus), review.stimulus_assignments);
            testCase.verifyEqual(string(mappings.verify), review.verify_statements);
            testCase.verifyEmpty(mappings.preconditionSteps);
        end

        function generateModeLogicHarness(testCase)
            testCase.assumeFalse(bdIsLoaded('ModeLogic'), ...
                'Close the ModeLogic demo before running its isolated harness test.');
            testCase.assumeFalse(bdIsLoaded('ModeLogic_REQ17_Harness'));
            exampleDir = fullfile(testCase.DemoRoot, "examples", "mode-logic");
            copyfile(fullfile(exampleDir, "*"), testCase.TempDir);
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture(testCase.TempDir));
            testCase.addTeardown(@() closeTestModels(testCase.TempDir));
            yamlPath = fullfile(testCase.TempDir, "mapping_review_req17.yaml");
            review = generateMappingReviewFromRequirements('ModeLogic', ...
                fullfile(exampleDir, "HLR_ModeLogic_EARS.slreqx"), yamlPath, ...
                'RequirementIds', "17", 'OpenInEditor', false);
            testCase.assertEqual(numel(review), 1);
            testCase.verifyEqual(string(review.requirement_id), "17");
            testCase.verifyEqual(string(review.status), "needs_review");
            testCase.assertEmpty(review.open_questions);
            testCase.assertNotEmpty(review.verify_statements);
            testCase.verifySubstring(strjoin(string(review.verify_statements)), "modeEnum.WaitForComms");

            % Synthetic approval is confined to this known demo test fixture.
            review.status = "approved";
            writeMappingReviewYaml(yamlPath, review, 'OpenInEditor', false);
            result = buildHarnessesFromApprovedYaml('ModeLogic', yamlPath);
            expectedHarness = fullfile(testCase.TempDir, "test_harnesses", "ModeLogic_REQ17_Harness.slx");
            testCase.assertTrue(isfile(expectedHarness));
            testCase.verifyEqual(result.association_mode, "associated_external_harness");
            harnesses = sltest.harness.find('ModeLogic');
            testCase.verifyTrue(any(string({harnesses.name}) == "ModeLogic_REQ17_Harness"));
            sltest.harness.open('ModeLogic', 'ModeLogic_REQ17_Harness');
            compileHarnessModel('ModeLogic_REQ17_Harness');
        end
    end
end

function closeTestModels(workDir)
modelNames = ["ModeLogic_REQ17_Harness", "ModeLogic"];
for modelName = modelNames
    if bdIsLoaded(modelName)
        close_system(modelName, 0);
    end
end
dictionaryFiles = dir(fullfile(workDir, "*.sldd"));
for idx = 1:numel(dictionaryFiles)
    dictionary = Simulink.data.dictionary.open(fullfile(workDir, dictionaryFiles(idx).name));
    close(dictionary);
end
end
