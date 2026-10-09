function configureUbiquitous(blockPath, stepPrefix, behavior, reqId, signalMapping)
%CONFIGUREUBIQUITOUS Configure Test Sequence steps for the Ubiquitous EARS pattern
%   Pattern: "The system shall [behavior]"
%
%   No trigger condition — the requirement holds unconditionally.
%
%   Steps created:
%     <prefix>_Init   - Initialize signals to a nominal state  (signalMapping.init)
%     <prefix>_Verify - Verify the unconditional behavior      (signalMapping.verify)

    initStep   = [stepPrefix '_Init'];
    verifyStep = [stepPrefix '_Verify'];

    sltest.testsequence.editStep(blockPath, 'Run', ...
        'Name',   initStep, ...
        'Action', sprintf('%% REQ-%s: Ubiquitous\n%% Expected: %s\n\n%s', ...
                          reqId, behavior, signalMapping.init));

    lastStep = addPreconditionSteps(blockPath, stepPrefix, initStep, ...
        getFieldOrDefault(signalMapping, 'preconditionSteps', struct([])));

    sltest.testsequence.addStepAfter(blockPath, verifyStep, lastStep, ...
        'Action', sprintf('%% Verify: %s\n\n%s', behavior, signalMapping.verify));

    if strcmp(lastStep, initStep)
        sltest.testsequence.addTransition(blockPath, initStep, 'after(0.1, sec)', verifyStep);
    else
        sltest.testsequence.addTransition(blockPath, lastStep, 'after(0.2, sec)', verifyStep);
    end
end

function value = getFieldOrDefault(s, fieldName, defaultValue)
    if isfield(s, fieldName)
        value = s.(fieldName);
    else
        value = defaultValue;
    end
end
