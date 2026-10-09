function configureTestSequence(blockPath, reqId, pattern, trigger, behavior, signalMapping)
%CONFIGURETESTSEQUENCE Populate a Test Sequence block based on the EARS pattern
%
%   Dispatches to the appropriate pattern-specific configurator.
%
%   Inputs:
%     blockPath     - Simulink path to the Test Sequence block
%     reqId         - Requirement ID string
%     pattern       - EARS pattern string (see parseEARSPattern)
%     trigger       - Trigger/condition text (used in step comments)
%     behavior      - Expected behavior text (used in step comments)
%     signalMapping - Struct with fields .init, .stimulus, .verify

    stepPrefix = ['REQ' regexprep(reqId, '\W', '_')];

    sltest.testsequence.addSymbol(blockPath, 'testComplete', 'Data', 'Local');

    switch pattern
        case 'Event-Driven'
            configureEventDriven(blockPath, stepPrefix, trigger, behavior, reqId, signalMapping);

        case 'State-Driven'
            configureStateDriven(blockPath, stepPrefix, trigger, behavior, reqId, signalMapping);

        case 'Unwanted Behavior'
            configureUnwantedBehavior(blockPath, stepPrefix, trigger, behavior, reqId, signalMapping);

        case 'Ubiquitous'
            configureUbiquitous(blockPath, stepPrefix, behavior, reqId, signalMapping);

        case 'Optional'
            % Optional behaves like Event-Driven: enable the feature, then verify
            configureEventDriven(blockPath, stepPrefix, trigger, behavior, reqId, signalMapping);

        otherwise
            warning('configureTestSequence: unknown EARS pattern "%s" for REQ-%s', pattern, reqId);
    end
end
