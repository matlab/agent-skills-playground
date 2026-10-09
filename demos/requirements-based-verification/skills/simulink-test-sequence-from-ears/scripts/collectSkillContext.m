function context = collectSkillContext(modelName, reqFilePath)
%COLLECTSKILLCONTEXT Collect requirement, interface, bus, enum, and Stateflow data.
%   CONTEXT = collectSkillContext(MODELNAME, REQFILEPATH) gathers the data
%   needed by the simulink-test-sequence-from-ears skill for review-file
%   generation and signal-mapping automation.

    modelName = stripExtension(char(modelName), '.slx');
    reqFilePath = char(reqFilePath);

    load_system(modelName);

    context = struct();
    context.model_name = string(modelName);
    context.requirements_file = string(reqFilePath);
    context.project_path = string(pwd);
    context.requirements = collectRequirements(reqFilePath);
    context.buses = collectBusDefinitions();
    context.enums = collectEnumerations();
    context.interfaces = collectInterfaces(modelName, context.buses);
    context.signal_catalog = buildSignalCatalog(context.interfaces, context.buses);
    context.stateflow = collectStateflowContext(modelName, context.signal_catalog, context.enums);
end

function requirements = collectRequirements(reqFilePath)
    reqSet = slreq.load(reqFilePath);
    reqObjs = find(reqSet, 'Type', 'Requirement');

    requirements = repmat(struct( ...
        'id', "", ...
        'summary', "", ...
        'description', "", ...
        'pattern', "", ...
        'trigger', "", ...
        'behavior', ""), 0, 1);

    for i = 1:numel(reqObjs)
        reqText = extractRequirementText(reqObjs(i).Description);
        if strlength(reqText) == 0
            continue;
        end

        [pattern, trigger, behavior] = parseEARSPattern(char(reqText));
        if isempty(pattern)
            pattern = 'Unknown';
        end

        requirements(end+1,1) = struct( ... %#ok<AGROW>
            'id', string(reqObjs(i).Id), ...
            'summary', string(reqObjs(i).Summary), ...
            'description', string(reqText), ...
            'pattern', string(pattern), ...
            'trigger', string(trigger), ...
            'behavior', string(behavior));
    end
end

function text = extractRequirementText(description)
    text = regexprep(string(description), '<[^>]*>', '');
    text = regexprep(text, 'p, li \{ white-space: pre-wrap; \}', '');
    text = strtrim(text);
end

function buses = collectBusDefinitions()
    ddFiles = dir('*.sldd');
    buses = repmat(struct('name', "", 'source_file', "", 'elements', []), 0, 1);

    for i = 1:numel(ddFiles)
        try
            dd = Simulink.data.dictionary.open(ddFiles(i).name);
            cleaner = onCleanup(@() close(dd));
            section = getSection(dd, 'Design Data');
            entries = find(section);
            for j = 1:numel(entries)
                value = getValue(entries(j));
                if ~isa(value, 'Simulink.Bus')
                    continue;
                end
                elements = repmat(struct('name', "", 'data_type', "", 'dimensions', []), 0, 1);
                for k = 1:numel(value.Elements)
                    elements(end+1,1) = struct( ... %#ok<AGROW>
                        'name', string(value.Elements(k).Name), ...
                        'data_type', string(value.Elements(k).DataType), ...
                        'dimensions', value.Elements(k).Dimensions);
                end
                buses(end+1,1) = struct( ... %#ok<AGROW>
                    'name', string(entries(j).Name), ...
                    'source_file', string(ddFiles(i).name), ...
                    'elements', elements);
            end
        catch
        end
    end
end

function enums = collectEnumerations()
    mFiles = dir('*.m');
    enums = repmat(struct('name', "", 'members', []), 0, 1);

    for i = 1:numel(mFiles)
        try
            [~, className] = fileparts(mFiles(i).name);
            if ~exist(className, 'class')
                continue;
            end
            enumValues = enumeration(className);
            if isempty(enumValues)
                continue;
            end

            members = repmat(struct('name', "", 'value', 0), 0, 1);
            for j = 1:numel(enumValues)
                members(end+1,1) = struct( ... %#ok<AGROW>
                    'name', string(char(enumValues(j))), ...
                    'value', int32(enumValues(j)));
            end
            enums(end+1,1) = struct('name', string(className), 'members', members); %#ok<AGROW>
        catch
        end
    end
end

function interfaces = collectInterfaces(modelName, buses)
    inports = find_system(modelName, 'SearchDepth', 1, 'BlockType', 'Inport');
    outports = find_system(modelName, 'SearchDepth', 1, 'BlockType', 'Outport');

    inputs = repmat(struct( ...
        'name', "", ...
        'data_type', "", ...
        'dimensions', [], ...
        'is_bus', false, ...
        'bus_name', "", ...
        'bus_elements', []), 0, 1);

    outputs = inputs;

    for i = 1:numel(inports)
        inputs(end+1,1) = collectPortInfo(inports{i}, buses); %#ok<AGROW>
    end
    for i = 1:numel(outports)
        outputs(end+1,1) = collectPortInfo(outports{i}, buses); %#ok<AGROW>
    end

    interfaces = struct('inputs', inputs, 'outputs', outputs);
end

function info = collectPortInfo(portPath, buses)
    dataType = string(get_param(portPath, 'OutDataTypeStr'));
    dimensions = str2num(get_param(portPath, 'PortDimensions')); %#ok<ST2NM>
    if isempty(dimensions)
        dimensions = 1;
    end

    busName = "";
    busElements = [];
    isBus = startsWith(dataType, "Bus: ");
    if isBus
        busName = extractAfter(dataType, "Bus: ");
        busMatch = find(strcmp(string({buses.name}), busName), 1);
        if ~isempty(busMatch)
            busElements = buses(busMatch).elements;
        end
    end

    info = struct( ...
        'name', string(get_param(portPath, 'Name')), ...
        'data_type', dataType, ...
        'dimensions', dimensions, ...
        'is_bus', isBus, ...
        'bus_name', string(busName), ...
        'bus_elements', busElements);
end

function signalCatalog = buildSignalCatalog(interfaces, buses)
    signalCatalog = repmat(struct( ...
        'path', "", ...
        'base_path', "", ...
        'scope', "", ...
        'data_type', "", ...
        'dimensions', [], ...
        'settable', false), 0, 1);

    for i = 1:numel(interfaces.inputs)
        inputInfo = interfaces.inputs(i);
        if inputInfo.is_bus
            for j = 1:numel(inputInfo.bus_elements)
                basePath = inputInfo.name + "." + inputInfo.bus_elements(j).name;
                signalCatalog(end+1,1) = struct( ... %#ok<AGROW>
                    'path', basePath, ...
                    'base_path', basePath, ...
                    'scope', "input", ...
                    'data_type', inputInfo.bus_elements(j).data_type, ...
                    'dimensions', inputInfo.bus_elements(j).dimensions, ...
                    'settable', true);
            end
        else
            signalCatalog(end+1,1) = struct( ... %#ok<AGROW>
                'path', inputInfo.name, ...
                'base_path', inputInfo.name, ...
                'scope', "input", ...
                'data_type', inputInfo.data_type, ...
                'dimensions', inputInfo.dimensions, ...
                'settable', true);
        end
    end

    for i = 1:numel(interfaces.outputs)
        outputInfo = interfaces.outputs(i);
        if outputInfo.is_bus
            for j = 1:numel(outputInfo.bus_elements)
                basePath = outputInfo.name + "." + outputInfo.bus_elements(j).name;
                signalCatalog(end+1,1) = struct( ... %#ok<AGROW>
                    'path', basePath, ...
                    'base_path', basePath, ...
                    'scope', "output", ...
                    'data_type', outputInfo.bus_elements(j).data_type, ...
                    'dimensions', outputInfo.bus_elements(j).dimensions, ...
                    'settable', false);
            end
        else
            signalCatalog(end+1,1) = struct( ... %#ok<AGROW>
                'path', outputInfo.name, ...
                'base_path', outputInfo.name, ...
                'scope', "output", ...
                'data_type', outputInfo.data_type, ...
                'dimensions', outputInfo.dimensions, ...
                'settable', false);
        end
    end

    for i = 1:numel(buses)
        for j = 1:numel(buses(i).elements)
            basePath = buses(i).name + "." + buses(i).elements(j).name;
            signalCatalog(end+1,1) = struct( ... %#ok<AGROW>
                'path', basePath, ...
                'base_path', basePath, ...
                'scope', "bus_element", ...
                'data_type', buses(i).elements(j).data_type, ...
                'dimensions', buses(i).elements(j).dimensions, ...
                'settable', false);
        end
    end
end

function stateflowContext = collectStateflowContext(modelName, signalCatalog, enums)
    rootObj = sfroot;
    allCharts = rootObj.find('-isa', 'Stateflow.Chart');
    chartMask = arrayfun(@(c) startsWith(string(c.Path), string(modelName) + "/"), allCharts);
    charts = allCharts(chartMask);

    stateflowContext = struct('charts', repmat(struct( ...
        'path', "", ...
        'default_state', "", ...
        'states', [], ...
        'transitions', []), 0, 1));

    for i = 1:numel(charts)
        stateObjs = charts(i).find('-isa', 'Stateflow.State');
        transitionObjs = charts(i).find('-isa', 'Stateflow.Transition');

        states = repmat(struct( ...
            'name', "", ...
            'label', "", ...
            'mode_output_signal', "", ...
            'mode_output_value', "", ...
            'mode_numeric_value', []), 0, 1);

        for j = 1:numel(stateObjs)
            [modeSignal, modeValue, modeNumeric] = parseStateModeOutput(string(stateObjs(j).LabelString), string(stateObjs(j).Name), enums);
            states(end+1,1) = struct( ... %#ok<AGROW>
                'name', string(stateObjs(j).Name), ...
                'label', string(stateObjs(j).LabelString), ...
                'mode_output_signal', modeSignal, ...
                'mode_output_value', modeValue, ...
                'mode_numeric_value', modeNumeric);
        end

        rawTransitions = repmat(struct( ...
            'source_state', "", ...
            'source_type', "", ...
            'source_id', 0, ...
            'destination_state', "", ...
            'destination_type', "", ...
            'destination_id', 0, ...
            'label', "", ...
            'condition', "", ...
            'assignments', strings(0,1), ...
            'mapping_terms', [], ...
            'notes', strings(0,1), ...
            'supported', false), 0, 1);

        for j = 1:numel(transitionObjs)
            [sourceState, sourceType, sourceId] = sfObjectDescriptor(transitionObjs(j).Source);
            [destinationState, destinationType, destinationId] = sfObjectDescriptor(transitionObjs(j).Destination);
            label = string(transitionObjs(j).LabelString);
            condition = extractConditionExpression(label);
            conditionInfo = deriveAssignmentsFromCondition(condition, signalCatalog);

            rawTransitions(end+1,1) = struct( ... %#ok<AGROW>
                'source_state', sourceState, ...
                'source_type', sourceType, ...
                'source_id', sourceId, ...
                'destination_state', destinationState, ...
                'destination_type', destinationType, ...
                'destination_id', destinationId, ...
                'label', label, ...
                'condition', condition, ...
                'assignments', conditionInfo.assignments, ...
                'mapping_terms', conditionInfo.terms, ...
                'notes', conditionInfo.notes, ...
                'supported', conditionInfo.supported);
        end

        transitions = buildEffectiveTransitions(rawTransitions);
        sourceStates = string({transitions.source_state});
        destinationStates = string({transitions.destination_state});
        defaultCandidates = transitions(sourceStates == "" & strlength(destinationStates) > 0);
        defaultState = "";
        if ~isempty(defaultCandidates)
            defaultState = string(defaultCandidates(1).destination_state);
        end

        stateflowContext.charts(end+1,1) = struct( ... %#ok<AGROW>
            'path', string(charts(i).Path), ...
            'default_state', defaultState, ...
            'states', states, ...
            'transitions', transitions);
    end
end

function transitions = buildEffectiveTransitions(rawTransitions)
    transitions = repmat(struct( ...
            'source_state', "", ...
            'destination_state', "", ...
            'label', "", ...
            'condition', "", ...
            'assignments', strings(0,1), ...
            'mapping_terms', [], ...
            'notes', strings(0,1), ...
            'supported', false), 0, 1);

    for i = 1:numel(rawTransitions)
        if rawTransitions(i).source_type ~= "State" && rawTransitions(i).source_type ~= "Default"
            continue;
        end
        resolved = resolveTransitionDestination(rawTransitions(i), rawTransitions, rawTransitions(i).source_state, []);
        if isempty(resolved)
            continue;
        end
        transitions = [transitions; resolved(:)]; %#ok<AGROW>
    end

    transitions = uniqueTransitions(transitions);
end

function resolved = resolveTransitionDestination(rawTransition, rawTransitions, originState, visitedIds)
    resolved = struct([]);
    if any(visitedIds == rawTransition.destination_id)
        return;
    end

    if rawTransition.destination_type == "State"
        resolved = struct( ...
            'source_state', originState, ...
            'destination_state', rawTransition.destination_state, ...
            'label', rawTransition.label, ...
            'condition', rawTransition.condition, ...
            'assignments', rawTransition.assignments, ...
            'mapping_terms', rawTransition.mapping_terms, ...
            'notes', rawTransition.notes, ...
            'supported', rawTransition.supported);
        return;
    end

    if rawTransition.destination_type ~= "Junction"
        return;
    end

    outgoing = rawTransitions([rawTransitions.source_id] == rawTransition.destination_id);
    for i = 1:numel(outgoing)
        downstream = resolveTransitionDestination(outgoing(i), rawTransitions, originState, [visitedIds rawTransition.destination_id]);
        for j = 1:numel(downstream)
            combined = combineTransitions(rawTransition, downstream(j), originState);
            if isempty(resolved)
                resolved = combined;
            else
                resolved(end+1,1) = orderfields(combined, resolved); %#ok<AGROW>
            end
        end
    end
end

function combined = combineTransitions(upstream, downstream, originState)
    combinedCondition = joinNonEmpty([upstream.condition; downstream.condition], " && ");
    combinedLabel = joinNonEmpty([upstream.label; downstream.label], " | ");
    combined = struct( ...
        'source_state', originState, ...
        'destination_state', downstream.destination_state, ...
        'label', combinedLabel, ...
        'condition', combinedCondition, ...
        'assignments', unique([string(upstream.assignments(:)); string(downstream.assignments(:))], 'stable'), ...
        'mapping_terms', [upstream.mapping_terms(:); downstream.mapping_terms(:)], ...
        'notes', unique([string(upstream.notes(:)); string(downstream.notes(:))], 'stable'), ...
        'supported', upstream.supported && downstream.supported);
end

function value = joinNonEmpty(parts, separator)
    parts = string(parts);
    parts = parts(parts ~= "");
    if isempty(parts)
        value = "";
    else
        value = strjoin(cellstr(parts), separator);
    end
end

function transitions = uniqueTransitions(transitions)
    if isempty(transitions)
        return;
    end

    keys = strings(numel(transitions),1);
    for i = 1:numel(transitions)
        keys(i) = transitions(i).source_state + "->" + transitions(i).destination_state + "|" + transitions(i).condition;
    end
    [~, uniqueIdx] = unique(keys, 'stable');
    transitions = transitions(uniqueIdx);
end

function [name, typeName, objectId] = sfObjectDescriptor(obj)
    objectId = 0;
    if isempty(obj)
        name = "";
        typeName = "Default";
        return;
    end

    objectId = obj.Id;
    if isa(obj, 'Stateflow.State')
        name = string(obj.Name);
        typeName = "State";
    elseif isa(obj, 'Stateflow.Junction')
        name = "Junction" + string(obj.Id);
        typeName = "Junction";
    else
        name = "";
        typeName = string(class(obj));
    end
end

function [signalName, signalValue, numericValue] = parseStateModeOutput(label, stateName, enums)
    signalName = "";
    signalValue = "";
    numericValue = [];

    tokens = regexp(char(label), '([A-Za-z]\w*(?:\.\w+)?)\s*=\s*([^;\n]+)', 'tokens', 'once');
    if isempty(tokens)
        return;
    end

    lhs = string(strtrim(tokens{1}));
    rhs = string(strtrim(tokens{2}));
    if ~endsWith(lhs, ".Mode")
        return;
    end

    signalName = lhs;
    numericValue = extractNumericLiteral(rhs);
    signalValue = resolveModeValue(rhs, stateName, enums);
end

function signalValue = resolveModeValue(rhs, stateName, enums)
    signalValue = rhs;

    for i = 1:numel(enums)
        for j = 1:numel(enums(i).members)
            if strcmpi(normalizeToken(char(enums(i).members(j).name)), normalizeToken(char(stateName)))
                signalValue = enums(i).name + "." + enums(i).members(j).name;
                return;
            end
        end
    end

    numericValue = extractNumericLiteral(rhs);
    if isempty(numericValue)
        return;
    end

    for i = 1:numel(enums)
        for j = 1:numel(enums(i).members)
            if enums(i).members(j).value == numericValue
                signalValue = enums(i).name + "." + enums(i).members(j).name;
                return;
            end
        end
    end
end

function value = extractNumericLiteral(text)
    tok = regexp(char(text), '[-+]?\d*\.?\d+(?:[eE][-+]?\d+)?', 'match', 'once');
    if isempty(tok)
        value = [];
    else
        value = str2double(tok);
    end
end

function condition = extractConditionExpression(label)
    label = char(string(label));
    label = strrep(label, "...", " ");
    tok = regexp(label, '\[(.*)\]', 'tokens', 'once');
    if isempty(tok)
        condition = "";
    else
        condition = string(strtrim(tok{1}));
    end
end

function info = deriveAssignmentsFromCondition(condition, signalCatalog)
    info = struct( ...
        'assignments', strings(0,1), ...
        'terms', repmat(struct( ...
            'phrase', "", ...
            'model_signal', "", ...
            'condition', "", ...
            'assignment', "", ...
            'supported', false), 0, 1), ...
        'notes', strings(0,1), ...
        'supported', false);

    condition = cleanCondition(condition);
    if strlength(condition) == 0
        info.supported = true;
        return;
    end

    branches = split(string(condition), "||");
    bestAssignments = strings(0,1);
    bestTerms = info.terms;
    bestNotes = strings(0,1);
    bestScore = -1;
    bestSupported = false;

    for i = 1:numel(branches)
        clauses = split(branches(i), "&&");
        branchAssignments = strings(0,1);
        branchTerms = repmat(struct( ...
            'phrase', "", ...
            'model_signal', "", ...
            'condition', "", ...
            'assignment', "", ...
            'supported', false), 0, 1);
        branchSupported = true;
        branchScore = 0;

        for j = 1:numel(clauses)
            term = parseAtomicClause(strtrim(clauses(j)), signalCatalog);
            branchTerms(end+1,1) = term; %#ok<AGROW>
            if term.supported
                branchAssignments(end+1,1) = term.assignment; %#ok<AGROW>
                branchScore = branchScore + 1;
            else
                branchSupported = false;
            end
        end

        if branchScore > bestScore || (branchScore == bestScore && branchSupported && ~bestSupported)
            bestScore = branchScore;
            bestAssignments = unique(branchAssignments, 'stable');
            bestTerms = branchTerms;
            bestSupported = branchSupported || branchScore > 0;
            if numel(branches) > 1
                bestNotes = "Selected a satisfiable branch from an OR condition.";
            else
                bestNotes = strings(0,1);
            end
        end
    end

    info.assignments = bestAssignments;
    info.terms = bestTerms;
    info.notes = bestNotes;
    info.supported = bestSupported;
end

function term = parseAtomicClause(clause, signalCatalog)
    term = struct( ...
        'phrase', "", ...
        'model_signal', "", ...
        'condition', string(clause), ...
        'assignment', "", ...
        'supported', false);

    clause = stripOuterParens(cleanCondition(clause));
    if strlength(clause) == 0
        return;
    end

    absTokens = regexp(char(clause), '^abs\(([A-Za-z]\w*(?:\.\w+)?(?:\[\d+\])?)\)(?:\*[^<>=]+)?\s*(<=|<|>=|>)\s*(.+)$', 'tokens', 'once');
    if ~isempty(absTokens)
        matlabSignal = sfSignalToMatlabPath(string(absTokens{1}));
        op = string(absTokens{2});
        rhs = string(strtrim(absTokens{3}));
        if isSettableSignal(matlabSignal, signalCatalog)
            term.model_signal = matlabSignal;
            term.assignment = matlabSignal + " = " + assignmentForRelational(matlabSignal, op, rhs, signalCatalog, true) + ";";
            term.phrase = phraseGuessForSignal(matlabSignal);
            term.supported = true;
        end
        return;
    end

    compareTokens = regexp(char(clause), '^([A-Za-z]\w*(?:\.\w+)?(?:\[\d+\])?)\s*(==|~=|>=|<=|>|<)\s*(.+)$', 'tokens', 'once');
    if ~isempty(compareTokens)
        matlabSignal = sfSignalToMatlabPath(string(compareTokens{1}));
        op = string(compareTokens{2});
        rhs = string(strtrim(compareTokens{3}));
        if isSettableSignal(matlabSignal, signalCatalog)
            term.model_signal = matlabSignal;
            term.assignment = matlabSignal + " = " + assignmentForRelational(matlabSignal, op, rhs, signalCatalog, false) + ";";
            term.phrase = phraseGuessForSignal(matlabSignal);
            term.supported = true;
        end
        return;
    end

    unaryTokens = regexp(char(clause), '^(~)?\s*([A-Za-z]\w*(?:\.\w+)?(?:\[\d+\])?)$', 'tokens', 'once');
    if ~isempty(unaryTokens)
        matlabSignal = sfSignalToMatlabPath(string(unaryTokens{2}));
        if isSettableSignal(matlabSignal, signalCatalog)
            term.model_signal = matlabSignal;
            if isempty(unaryTokens{1})
                term.assignment = matlabSignal + " = true;";
            else
                term.assignment = matlabSignal + " = false;";
            end
            term.phrase = phraseGuessForSignal(matlabSignal);
            term.supported = true;
        end
    end
end

function assignment = assignmentForRelational(signalPath, op, rhs, signalCatalog, isAbs)
    switch op
        case "=="
            assignment = rhs;
        case "~="
            assignment = literalDifferentFrom(rhs, signalPath, signalCatalog);
        case {">", ">="}
            assignment = literalAbove(rhs);
        case {"<", "<="}
            if isAbs
                assignment = typedZeroLiteral(signalPath, signalCatalog);
            else
                assignment = literalBelow(rhs, signalPath, signalCatalog);
            end
        otherwise
            assignment = typedZeroLiteral(signalPath, signalCatalog);
    end
end

function tf = isSettableSignal(signalPath, signalCatalog)
    basePath = stripIndex(signalPath);
    tf = any(strcmp(string({signalCatalog.base_path}), basePath) & strcmp(string({signalCatalog.scope}), "input"));
end

function path = sfSignalToMatlabPath(signalPath)
    path = string(signalPath);
    idxTokens = regexp(char(path), '\[(\d+)\]', 'tokens');
    for i = 1:numel(idxTokens)
        replacement = "(" + string(str2double(idxTokens{i}{1}) + 1) + ")";
        path = regexprep(path, '\[\d+\]', replacement, 'once');
    end
end

function path = stripIndex(signalPath)
    path = regexprep(string(signalPath), '\(\d+\)$', '');
end

function phrase = phraseGuessForSignal(signalPath)
    signalPath = string(signalPath);
    switch char(signalPath)
        case 'State.Angles(1)'
            phrase = "roll angle";
        case 'State.Angles(2)'
            phrase = "pitch angle";
        case 'State.Angles(3)'
            phrase = "yaw angle";
        case 'State.V_BODY(3)'
            phrase = "vertical velocity";
        otherwise
            phrase = strtrim(strjoin(splitCamelCase(extractAfterLastToken(signalPath)), " "));
    end
end

function out = extractAfterLastToken(signalPath)
    parts = split(signalPath, '.');
    out = regexprep(parts(end), '\(\d+\)$', '');
end

function literal = typedZeroLiteral(signalPath, signalCatalog)
    entry = findSignalEntry(signalPath, signalCatalog);
    if isempty(entry)
        literal = "0";
        return;
    end
    literal = defaultLiteral(entry.data_type, 1);
end

function literal = literalAbove(rhs)
    literal = adjustTypedNumericLiteral(rhs, +1);
end

function literal = literalBelow(rhs, signalPath, signalCatalog)
    numericValue = extractNumericLiteral(rhs);
    if ~isempty(numericValue) && numericValue > 0
        literal = adjustTypedNumericLiteral(rhs, -1);
    else
        literal = typedZeroLiteral(signalPath, signalCatalog);
    end
end

function literal = literalDifferentFrom(rhs, signalPath, signalCatalog)
    if strcmp(strtrim(rhs), "true")
        literal = "false";
        return;
    end
    if strcmp(strtrim(rhs), "false")
        literal = "true";
        return;
    end

    numericValue = extractNumericLiteral(rhs);
    if ~isempty(numericValue)
        literal = adjustTypedNumericLiteral(rhs, +1);
    else
        literal = typedZeroLiteral(signalPath, signalCatalog);
    end
end

function literal = adjustTypedNumericLiteral(rhs, direction)
    rhs = string(strtrim(rhs));
    tok = regexp(char(rhs), '^([A-Za-z]\w*)\(\s*([-+]?\d*\.?\d+(?:[eE][-+]?\d+)?)\s*\)$', 'tokens', 'once');
    if isempty(tok)
        numericValue = extractNumericLiteral(rhs);
        if isempty(numericValue)
            literal = rhs;
            return;
        end
        literal = string(num2str(adjustNumericValue(numericValue, direction)));
        return;
    end

    castName = string(tok{1});
    numericValue = str2double(tok{2});
    adjustedValue = adjustNumericValue(numericValue, direction);
    if startsWith(castName, ["uint", "int"])
        adjustedValue = round(adjustedValue);
    end
    literal = castName + "(" + string(num2str(adjustedValue, '%.15g')) + ")";
end

function value = adjustNumericValue(value, direction)
    if abs(value) < 1
        delta = 0.1;
    else
        delta = max(abs(value) * 0.1, 1);
        if value < 10
            delta = 0.1;
        end
    end

    if direction > 0
        value = value + delta;
    else
        value = value - delta;
    end
end

function entry = findSignalEntry(signalPath, signalCatalog)
    basePath = stripIndex(signalPath);
    idx = find(strcmp(string({signalCatalog.base_path}), basePath) & strcmp(string({signalCatalog.scope}), "input"), 1);
    if isempty(idx)
        entry = [];
    else
        entry = signalCatalog(idx);
    end
end

function literal = defaultLiteral(dataType, dimensions)
    dataType = string(dataType);
    if nargin < 2 || isempty(dimensions)
        dimensions = 1;
    end

    if isscalar(dimensions)
        dims = [dimensions 1];
    else
        dims = dimensions;
    end

    if numel(dims) >= 2 && dims(1) == 1 && dims(2) == 1
        dims = 1;
    end

    if dims == 1
        if strcmpi(dataType, "boolean")
            literal = "false";
        elseif startsWith(dataType, "single")
            literal = "single(0)";
        elseif startsWith(dataType, "double")
            literal = "0";
        elseif startsWith(dataType, ["uint", "int"])
            literal = dataType + "(0)";
        else
            literal = "0";
        end
        return;
    end

    count = prod(double(dims));
    zerosList = join(repmat("0", 1, count), ";");
    vectorLiteral = "[" + zerosList + "]";
    if startsWith(dataType, "single")
        literal = "single(" + vectorLiteral + ")";
    elseif startsWith(dataType, ["uint", "int"])
        literal = dataType + "(" + vectorLiteral + ")";
    else
        literal = vectorLiteral;
    end
end

function condition = cleanCondition(condition)
    condition = string(condition);
    condition = regexprep(condition, '/\*.*?\*/', '');
    condition = replace(condition, newline, ' ');
    condition = replace(condition, "...", " ");
    condition = strtrim(regexprep(condition, '\s+', ' '));
end

function text = stripOuterParens(text)
    text = string(strtrim(text));
    while startsWith(text, "(") && endsWith(text, ")")
        inner = extractBetween(text, 2, strlength(text)-1);
        if isBalancedParens(inner)
            text = string(inner);
        else
            break;
        end
    end
end

function tf = isBalancedParens(text)
    chars = char(text);
    balance = 0;
    for i = 1:numel(chars)
        if chars(i) == '('
            balance = balance + 1;
        elseif chars(i) == ')'
            balance = balance - 1;
        end
        if balance < 0
            tf = false;
            return;
        end
    end
    tf = balance == 0;
end

function name = stripExtension(name, extension)
    if endsWith(string(name), string(extension))
        name = extractBefore(string(name), strlength(string(name)) - strlength(string(extension)) + 1);
    end
    name = char(name);
end

function tokens = splitCamelCase(text)
    text = regexprep(char(text), '([a-z])([A-Z])', '$1 $2');
    text = regexprep(text, '[_\-]', ' ');
    tokens = split(string(strtrim(text)));
    tokens = tokens(tokens ~= "");
end

function token = normalizeToken(text)
    token = lower(char(text));
    token = regexprep(token, '[^a-z0-9]+', '');
    token = strrep(token, 'communications', 'comms');
    token = strrep(token, 'communication', 'comms');
end
