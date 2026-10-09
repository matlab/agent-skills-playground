function lastStep = addPreconditionSteps(blockPath, stepPrefix, anchorStep, preconditionSteps)
%ADDPRECONDITIONSTEPS Insert optional precondition steps into a Test Sequence.
%   LASTSTEP = addPreconditionSteps(BLOCKPATH, STEPPREFIX, ANCHORSTEP,
%   PRECONDITIONSTEPS) adds each precondition step after ANCHORSTEP and
%   returns the final step name for subsequent chaining.

    lastStep = anchorStep;
    if nargin < 4 || isempty(preconditionSteps)
        return;
    end

    for i = 1:numel(preconditionSteps)
        if isfield(preconditionSteps(i), 'name') && strlength(string(preconditionSteps(i).name)) > 0
            stepName = [stepPrefix '_' regexprep(char(preconditionSteps(i).name), '\W', '_')];
        else
            stepName = sprintf('%s_Precondition%d', stepPrefix, i);
        end

        action = "";
        if isfield(preconditionSteps(i), 'action')
            action = string(preconditionSteps(i).action);
        end
        duration = 0.2;
        if isfield(preconditionSteps(i), 'duration') && ~isempty(preconditionSteps(i).duration)
            duration = preconditionSteps(i).duration;
        end

        sltest.testsequence.addStepAfter(blockPath, stepName, lastStep, ...
            'Action', sprintf('%% Precondition step %d\n\n%s', i, action));
        sltest.testsequence.addTransition(blockPath, lastStep, ...
            sprintf('after(%g, sec)', duration), stepName);
        lastStep = stepName;
    end
end
