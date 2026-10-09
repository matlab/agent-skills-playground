function configureEventDriven(blockPath, stepPrefix, trigger, behavior, reqId, signalMapping)
%CONFIGUREEVENTDRIVEN Configure Test Sequence steps for the Event-Driven EARS pattern
%   Pattern: "When [trigger], the system shall [behavior]"
%
%   Steps created:
%     <prefix>_Init    - Initialize precondition signals  (signalMapping.init)
%     <prefix>_Trigger - Apply the trigger event          (signalMapping.stimulus)
%     <prefix>_Verify  - Verify expected output           (signalMapping.verify)

    initStep    = [stepPrefix '_Init'];
    triggerStep = [stepPrefix '_Trigger'];
    verifyStep  = [stepPrefix '_Verify'];

    sltest.testsequence.editStep(blockPath, 'Run', ...
        'Name',   initStep, ...
        'Action', sprintf('%% REQ-%s: Event-Driven\n%% Trigger: %s\n%% Expected: %s\n\n%s', ...
                          reqId, trigger, behavior, signalMapping.init));

    lastStep = addPreconditionSteps(blockPath, stepPrefix, initStep, ...
        getFieldOrDefault(signalMapping, 'preconditionSteps', struct([])));

    sltest.testsequence.addStepAfter(blockPath, triggerStep, lastStep, ...
        'Action', sprintf('%% Apply trigger: %s\n\n%s', trigger, signalMapping.stimulus));

    sltest.testsequence.addStepAfter(blockPath, verifyStep, triggerStep, ...
        'Action', sprintf('%% Verify: %s\n\n%s', behavior, signalMapping.verify));

    if strcmp(lastStep, initStep)
        sltest.testsequence.addTransition(blockPath, initStep, 'after(0.1, sec)', triggerStep);
    else
        sltest.testsequence.addTransition(blockPath, lastStep, 'after(0.2, sec)', triggerStep);
    end
    sltest.testsequence.addTransition(blockPath, triggerStep, 'after(0.5, sec)', verifyStep);
end

function value = getFieldOrDefault(s, fieldName, defaultValue)
    if isfield(s, fieldName)
        value = s.(fieldName);
    else
        value = defaultValue;
    end
end
