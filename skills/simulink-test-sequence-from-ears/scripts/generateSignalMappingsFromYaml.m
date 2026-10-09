function signalMappings = generateSignalMappingsFromYaml(yamlPath)
%GENERATESIGNALMAPPINGSFROMYAML Convert approved review YAML to signalMappings.
%   SIGNALMAPPINGS = generateSignalMappingsFromYaml(YAMLPATH) reads the
%   mapping review YAML artifact and converts each requirement entry into
%   the struct array expected by generateTestSequencesFromRequirements.

    doc = readMappingReviewYaml(yamlPath);
    entries = doc.requirements;

    if isempty(entries)
        signalMappings = struct([]);
        return;
    end

    signalMappings = repmat(struct( ...
        'reqId', "", ...
        'pattern', "", ...
        'trigger', "", ...
        'behavior', "", ...
        'init', "", ...
        'preconditionSteps', struct([]), ...
        'stimulus', "", ...
        'verify', ""), numel(entries), 1);

    for i = 1:numel(entries)
        entry = entries(i);
        signalMappings(i).reqId = char(string(entry.requirement_id));
        signalMappings(i).pattern = char(string(entry.ears_pattern));
        signalMappings(i).trigger = char(string(entry.trigger));
        signalMappings(i).behavior = char(string(entry.behavior));
        signalMappings(i).init = char(joinStatements(getFieldOrDefault(entry, 'init_assignments', strings(0,1))));
        signalMappings(i).preconditionSteps = toPreconditionSteps(getFieldOrDefault(entry, 'precondition_path', struct([])));
        signalMappings(i).stimulus = char(joinStatements(getFieldOrDefault(entry, 'stimulus_assignments', strings(0,1))));
        signalMappings(i).verify = char(joinStatements(getFieldOrDefault(entry, 'verify_statements', strings(0,1))));
    end
end

function steps = toPreconditionSteps(pathEntries)
    if isEmptyYamlValue(pathEntries)
        steps = struct([]);
        return;
    end

    if iscell(pathEntries)
        pathEntries = vertcat(pathEntries{:});
    end

    if isEmptyYamlValue(pathEntries)
        steps = struct([]);
        return;
    end

    steps = repmat(struct('name', "", 'action', "", 'duration', 0.2), numel(pathEntries), 1);
    for i = 1:numel(pathEntries)
        if isfield(pathEntries(i), 'step_name')
            steps(i).name = char(string(pathEntries(i).step_name));
        else
            steps(i).name = sprintf('Precondition%d', i);
        end
        steps(i).action = char(buildPreconditionAction(pathEntries(i), i));
        steps(i).duration = 0.2;
        if isfield(pathEntries(i), 'duration') && ~isempty(pathEntries(i).duration)
            steps(i).duration = double(pathEntries(i).duration);
        end
    end
end

function tf = isEmptyYamlValue(value)
    tf = isempty(value);
    if tf
        return;
    end

    if isstring(value) || ischar(value)
        text = strtrim(string(value));
        tf = all(text == "" | text == "{}" | text == "[]" | strcmpi(text, "null") | text == "~");
        return;
    end

    if isstruct(value)
        tf = numel(fieldnames(value)) == 0;
        return;
    end
end

function action = buildPreconditionAction(pathEntry, index)
    lines = strings(0,1);

    fromState = "";
    toState = "";
    condition = "";
    assignments = strings(0,1);

    if isfield(pathEntry, 'from_state')
        fromState = string(pathEntry.from_state);
    end
    if isfield(pathEntry, 'to_state')
        toState = string(pathEntry.to_state);
    end
    if isfield(pathEntry, 'transition_condition')
        condition = string(pathEntry.transition_condition);
    end
    if isfield(pathEntry, 'assignments')
        assignments = string(pathEntry.assignments);
        assignments = assignments(assignments ~= "" & assignments ~= "{}");
    end

    if strlength(fromState) > 0 || strlength(toState) > 0
        lines(end+1,1) = sprintf('%% Precondition %d: %s -> %s', index, fromState, toState);
    else
        lines(end+1,1) = sprintf('%% Precondition %d', index);
    end
    if strlength(condition) > 0
        lines(end+1,1) = "% Transition condition: " + condition;
    end

    lines = [lines; assignments(:)];
    action = joinStatements(lines);
end

function text = joinStatements(value)
    value = string(value);
    value = value(value ~= "");
    if isempty(value)
        text = "";
    else
        text = strjoin(cellstr(value), newline);
    end
end

function value = getFieldOrDefault(s, fieldName, defaultValue)
    if isfield(s, fieldName)
        value = s.(fieldName);
    else
        value = defaultValue;
    end
end
