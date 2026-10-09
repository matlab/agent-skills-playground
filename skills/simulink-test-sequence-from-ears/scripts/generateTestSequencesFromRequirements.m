function generateTestSequencesFromRequirements(modelName, signalMappings, varargin)
%GENERATETESTSEQUENCESFROMREQUIREMENTS Create test harnesses from approved signal mappings
%
%   generateTestSequencesFromRequirements(MODELNAME, SIGNALMAPPINGS)
%   generateTestSequencesFromRequirements(..., 'OutputFolder', PATH)
%
%   Called in Phase 2 of the simulink-test-sequence-from-ears skill after
%   the user approves the signal mapping summary from Phase 1.
%
%   Inputs:
%     modelName      - Simulink model name (without .slx extension)
%     signalMappings - Array of structs, one per requirement, with fields:
%       .reqId     - Requirement ID string (e.g., '17')
%       .pattern   - EARS pattern: 'Event-Driven', 'State-Driven',
%                    'Unwanted Behavior', 'Ubiquitous', or 'Optional'
%       .trigger   - Trigger/condition text from requirement (used in comments)
%       .behavior  - Expected behavior text from requirement (used in comments)
%       .init      - MATLAB code string: signal initializations (preconditions)
%       .preconditionSteps - Optional struct array with fields:
%                    .name, .action, .duration for multi-step state entry
%       .stimulus  - MATLAB code string: signal changes activating the requirement
%                    (empty string is accepted for Ubiquitous pattern)
%       .verify    - MATLAB code string: verify() statements checking outputs
%
%   Outputs:
%     Creates externally-saved test harness .slx files in a 'test_harnesses/'
%     subfolder of the current directory, one per entry in signalMappings.
%     When the owner model is writable, the harness association metadata is
%     saved on the model under test.
%
%   Example:
%     signalMappings(1).reqId    = '17';
%     signalMappings(1).pattern  = 'Event-Driven';
%     signalMappings(1).trigger  = 'the flight control system powers up';
%     signalMappings(1).behavior = 'enter the Establish Communications mode';
%     signalMappings(1).init     = 'GCSCmds.WIFIconnected = false;';
%     signalMappings(1).stimulus = '% power-up state — no comms yet';
%     signalMappings(1).verify   = 'verify(Logic.Mode == modeEnum.WaitForComms);';
%     generateTestSequencesFromRequirements('ModeLogic', signalMappings);

    parser = inputParser;
    addParameter(parser, 'OutputFolder', fullfile(pwd, 'test_harnesses'), @(x) ischar(x) || isstring(x));
    parse(parser, varargin{:});
    outputFolder = char(parser.Results.OutputFolder);

    modelFile = fullfile(pwd, [modelName '.slx']);
    if ~exist(modelFile, 'file')
        error('Model %s.slx not found. Add the model directory to the MATLAB path.', modelName);
    end

    if ~exist(outputFolder, 'dir')
        mkdir(outputFolder);
    end

    if bdIsLoaded(modelName)
        loadedFile = string(get_param(modelName, 'FileName'));
        if loadedFile ~= string(modelFile)
            close_system(modelName, 0);
        end
    end

    load_system(modelFile);

    for i = 1:numel(signalMappings)
        sm      = signalMappings(i);
        reqId   = sm.reqId;
        pattern = sm.pattern;

        fprintf('Processing REQ-%s (%s pattern)...\n', reqId, pattern);

        harnessName = sprintf('%s_REQ%s_Harness', modelName, reqId);
        harnessFile = fullfile(outputFolder, [harnessName '.slx']);

        try
            if bdIsLoaded(harnessName)
                close_system(harnessName, 0);
            end
            sltest.harness.create(modelName, ...
                'Name',           harnessName, ...
                'Source',         'Test Sequence', ...
                'SaveExternally', true, ...
                'HarnessPath',    outputFolder);

            % Harness must be open before sltest.testsequence APIs work
            sltest.harness.open(modelName, harnessName);

            tsBlockPath = [harnessName '/Test Sequence'];
            configureTestSequence(tsBlockPath, reqId, pattern, sm.trigger, sm.behavior, sm);

            save_system(harnessName);

            fprintf('  Compiling harness model...\n');
            compileHarnessModel(harnessName);
            fprintf('  Harness compile check passed.\n');

            sltest.harness.close(modelName, harnessName);
            if strcmp(get_param(modelName, 'Dirty'), 'on')
                save_system(modelName);
            end
            fprintf('  Created: %s\n', harnessFile);

        catch ME
            warning('Failed to create harness for REQ-%s: %s', reqId, ME.message);
            try
                sltest.harness.close(modelName, harnessName);
            catch %#ok<CTCH>
            end
        end
    end

    if strcmp(get_param(modelName, 'Dirty'), 'on')
        save_system(modelName);
    end

    fprintf('\nTest harness generation complete.\n');
    fprintf('Output folder: %s\n', outputFolder);
end
