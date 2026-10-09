function configureStateDriven(blockPath, stepPrefix, trigger, behavior, reqId, signalMapping)
%CONFIGURESTATEDRIVEN Configure Test Sequence steps for the State-Driven EARS pattern
%   Pattern: "While [state], the system shall [behavior]"
%
%   Steps created:
%     <prefix>_Init           - Initialize signals before state entry  (signalMapping.init)
%     <prefix>_EstablishState - Drive signals to establish the state   (signalMapping.stimulus)
%     <prefix>_VerifyDuringState - Verify behavior while in state      (signalMapping.verify)

    initStep     = [stepPrefix '_Init'];
    stateStep    = [stepPrefix '_EstablishState'];
    verifyStep   = [stepPrefix '_VerifyDuringState'];

    sltest.testsequence.editStep(blockPath, 'Run', ...
        'Name',   initStep, ...
        'Action', sprintf('%% REQ-%s: State-Driven\n%% State: %s\n%% Expected: %s\n\n%s', ...
                          reqId, trigger, behavior, signalMapping.init));

    lastStep = addPreconditionSteps(blockPath, stepPrefix, initStep, ...
        getFieldOrDefault(signalMapping, 'preconditionSteps', struct([])));

    sltest.testsequence.addStepAfter(blockPath, stateStep, lastStep, ...
        'Action', sprintf('%% Establish state: %s\n\n%s', trigger, signalMapping.stimulus));

    sltest.testsequence.addStepAfter(blockPath, verifyStep, stateStep, ...
        'Action', sprintf('%% Verify: %s\n\n%s', behavior, signalMapping.verify));

    if strcmp(lastStep, initStep)
        sltest.testsequence.addTransition(blockPath, initStep, 'after(0.1, sec)', stateStep);
    else
        sltest.testsequence.addTransition(blockPath, lastStep, 'after(0.2, sec)', stateStep);
    end
    sltest.testsequence.addTransition(blockPath, stateStep, 'after(0.5, sec)', verifyStep);
end

function value = getFieldOrDefault(s, fieldName, defaultValue)
    if isfield(s, fieldName)
        value = s.(fieldName);
    else
        value = defaultValue;
    end
end
