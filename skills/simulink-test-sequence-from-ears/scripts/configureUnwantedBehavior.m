function configureUnwantedBehavior(blockPath, stepPrefix, trigger, behavior, reqId, signalMapping)
%CONFIGUREUNWANTEDBEHAVIOR Configure Test Sequence steps for the Unwanted Behavior EARS pattern
%   Pattern: "If [condition], then the system shall [behavior]"
%
%   Steps created:
%     <prefix>_Init           - Initialize normal-operation signals  (signalMapping.init)
%     <prefix>_InjectFault    - Inject the fault/unwanted condition  (signalMapping.stimulus)
%     <prefix>_VerifyResponse - Verify the protective response       (signalMapping.verify)

    initStep   = [stepPrefix '_Init'];
    faultStep  = [stepPrefix '_InjectFault'];
    verifyStep = [stepPrefix '_VerifyResponse'];

    sltest.testsequence.editStep(blockPath, 'Run', ...
        'Name',   initStep, ...
        'Action', sprintf('%% REQ-%s: Unwanted Behavior\n%% Fault condition: %s\n%% Expected response: %s\n\n%s', ...
                          reqId, trigger, behavior, signalMapping.init));

    lastStep = addPreconditionSteps(blockPath, stepPrefix, initStep, ...
        getFieldOrDefault(signalMapping, 'preconditionSteps', struct([])));

    sltest.testsequence.addStepAfter(blockPath, faultStep, lastStep, ...
        'Action', sprintf('%% Inject fault: %s\n\n%s', trigger, signalMapping.stimulus));

    sltest.testsequence.addStepAfter(blockPath, verifyStep, faultStep, ...
        'Action', sprintf('%% Verify response: %s\n\n%s', behavior, signalMapping.verify));

    if strcmp(lastStep, initStep)
        sltest.testsequence.addTransition(blockPath, initStep, 'after(0.1, sec)', faultStep);
    else
        sltest.testsequence.addTransition(blockPath, lastStep, 'after(0.2, sec)', faultStep);
    end
    sltest.testsequence.addTransition(blockPath, faultStep, 'after(0.5, sec)', verifyStep);
end

function value = getFieldOrDefault(s, fieldName, defaultValue)
    if isfield(s, fieldName)
        value = s.(fieldName);
    else
        value = defaultValue;
    end
end
