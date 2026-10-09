function reviewEntries = generateMappingReviewFromRequirements(modelName, reqFilePath, outputPath, varargin)
%GENERATEMAPPINGREVIEWFROMREQUIREMENTS Auto-generate YAML review entries.
%   REVIEWENTRIES = generateMappingReviewFromRequirements(MODELNAME,
%   REQFILEPATH, OUTPUTPATH) analyzes the requirements and model, infers a
%   first-pass mapping review, and writes the YAML review artifact using
%   writeMappingReviewYaml.
%
%   REVIEWENTRIES = generateMappingReviewFromRequirements(...,
%   'RequirementIds', IDS, 'OpenInEditor', TF) filters the review artifact
%   to the requested requirement IDs before writing it and controls whether
%   the generated YAML opens in the MATLAB Editor. Use this when you want a
%   requirement-specific review file without opening an intermediate
%   aggregate artifact.

    if nargin < 3 || strlength(string(outputPath)) == 0
        outputPath = 'mapping_review.yaml';
    end

    parser = inputParser;
    addParameter(parser, 'RequirementIds', strings(0,1), @(x) ischar(x) || isstring(x) || iscellstr(x));
    addParameter(parser, 'OpenInEditor', true, @(x) islogical(x) || isnumeric(x));
    parse(parser, varargin{:});

    requirementIds = string(parser.Results.RequirementIds);
    openInEditor = logical(parser.Results.OpenInEditor);

    context = collectSkillContext(modelName, reqFilePath);
    if ~isempty(requirementIds)
        requirementIds = strtrim(requirementIds(:));
        keepMask = ismember(string({context.requirements.id}), requirementIds);
        context.requirements = context.requirements(keepMask);
        if isempty(context.requirements)
            error('generateMappingReviewFromRequirements:RequirementIdsNotFound', ...
                'No requirements matched the requested RequirementIds.');
        end
    end

    reviewEntries = struct([]);

    for i = 1:numel(context.requirements)
        entry = buildReviewEntry(context.requirements(i), context);
        if isempty(reviewEntries)
            reviewEntries = entry;
        else
            reviewEntries(end+1,1) = orderfields(entry, reviewEntries); %#ok<AGROW>
        end
    end

    writeMappingReviewYaml(outputPath, reviewEntries, 'OpenInEditor', openInEditor);
end

function entry = buildReviewEntry(req, context)
    candidate = findBestTransition(req, context);
    defaultInit = buildDefaultInitAssignments(context.interfaces.inputs);

    entry = struct();
    entry.requirement_id = req.id;
    entry.summary = req.summary;
    entry.requirement_text = req.description;
    entry.ears_pattern = req.pattern;
    entry.trigger = req.trigger;
    entry.behavior = req.behavior;
    entry.phrase_mappings = struct([]);
    entry.mapping = struct('trigger', struct([]), 'inputs', struct([]), 'behavior', struct([]));
    entry.precondition_path = struct([]);
    entry.init_assignments = defaultInit;
    entry.stimulus_assignments = strings(0,1);
    entry.verify_statements = strings(0,1);
    entry.test_assumptions = strings(0,1);
    entry.open_questions = strings(0,1);
    entry.status = "needs_review";

    if ~isempty(candidate.transition)
        entry.mapping.trigger = buildTriggerMapping(req, candidate, context);

        inputMappings = repmat(struct( ...
            'phrase', "", ...
            'model_signal', "", ...
            'condition', "", ...
            'rationale', ""), 0, 1);
        for i = 1:numel(candidate.transition.mapping_terms)
            term = candidate.transition.mapping_terms(i);
            if ~term.supported || strlength(term.model_signal) == 0
                continue;
            end
            inputMappings(end+1,1) = struct( ... %#ok<AGROW>
                'phrase', term.phrase, ...
                'model_signal', term.model_signal, ...
            'condition', singleLineText(term.condition), ...
            'rationale', "Inferred from the candidate transition condition");
        end
        entry.mapping.inputs = inputMappings;

        behaviorMapping = inferBehaviorMapping(req, candidate.transition, context);
        entry.mapping.behavior = behaviorMapping;
        entry.phrase_mappings = buildPhraseMappings(entry.mapping.trigger, inputMappings, behaviorMapping);

        [preconditionPath, pathNotes] = inferPreconditionPath(candidate, context);
        entry.precondition_path = preconditionPath;
        entry.test_assumptions = [entry.test_assumptions; pathNotes];

        entry.stimulus_assignments = unique([ ...
            string(candidate.transition.assignments(:)); ...
            deriveDestinationHoldAssignments(candidate.transition.destination_state, context)], 'stable');

        if strlength(behaviorMapping.model_signal) > 0 && strlength(behaviorMapping.expected_value) > 0
            entry.verify_statements = "verify(" + behaviorMapping.model_signal + " == " + ...
                behaviorMapping.expected_value + ", '" + escapeSingleQuotes(buildVerifyMessage(req)) + "');";
        else
            entry.open_questions(end+1,1) = "Expected behavior could not be mapped to a concrete output value.";
        end

        if ~candidate.transition.supported
            entry.open_questions(end+1,1) = "The inferred transition contains unsupported clauses that should be reviewed manually.";
        end
        entry.test_assumptions = [entry.test_assumptions; string(candidate.transition.notes(:))];
    else
        entry.open_questions(end+1,1) = "No matching Stateflow transition was inferred automatically. Review the trigger and expected behavior mapping manually.";
        fallbackBehavior = fallbackBehaviorMapping(req, context);
        entry.mapping.behavior = fallbackBehavior;
        entry.phrase_mappings = buildPhraseMappings(entry.mapping.trigger, entry.mapping.inputs, fallbackBehavior);
        if strlength(fallbackBehavior.model_signal) > 0 && strlength(fallbackBehavior.expected_value) > 0
            entry.verify_statements = "verify(" + fallbackBehavior.model_signal + " == " + ...
                fallbackBehavior.expected_value + ", '" + escapeSingleQuotes(buildVerifyMessage(req)) + "');";
        end
    end

    entry.test_assumptions = unique(entry.test_assumptions(entry.test_assumptions ~= ""), 'stable');
    entry.open_questions = unique(entry.open_questions(entry.open_questions ~= ""), 'stable');
end

function candidate = findBestTransition(req, context)
    hints = inferRequirementStateHints(req, context);
    candidate = struct( ...
        'transition', [], ...
        'chart_index', [], ...
        'source_hint', hints.source_state, ...
        'destination_hint', hints.destination_state);
    bestScore = -inf;

    reqText = req.trigger + " " + req.behavior + " " + req.summary + " " + req.description;
    reqTokens = normalizeTokens(reqText);
    triggerTokens = normalizeTokens(req.trigger + " " + req.summary);
    behaviorTokens = normalizeTokens(req.behavior + " " + req.summary);

    for chartIndex = 1:numel(context.stateflow.charts)
        transitions = context.stateflow.charts(chartIndex).transitions;
        for j = 1:numel(transitions)
            transition = transitions(j);
            if strlength(transition.destination_state) == 0
                continue;
            end

            score = 0;
            sourceTokens = normalizeTokens(transition.source_state);
            destinationTokens = normalizeTokens(transition.destination_state);
            conditionPhrases = arrayfun(@(t) string(t.phrase), transition.mapping_terms, 'UniformOutput', false);
            conditionTokens = normalizeTokens(strjoin(cellstr(string(conditionPhrases)), " "));

            score = score + 2 * tokenOverlap(sourceTokens, triggerTokens);
            score = score + 2 * tokenOverlap(destinationTokens, behaviorTokens);
            score = score + 2 * tokenOverlap(conditionTokens, reqTokens);
            score = score + 2 * stateTextScore(transition.destination_state, req.behavior + " " + req.summary);
            score = score + 1 * stateTextScore(transition.source_state, req.trigger + " " + req.summary);
            score = score + 2 * double(transition.supported);

            if strlength(hints.destination_state) > 0
                if stateMatchesHint(transition.destination_state, hints.destination_state)
                    score = score + 25;
                else
                    score = score - 8;
                end
            end

            if strlength(hints.source_state) > 0
                if stateMatchesHint(transition.source_state, hints.source_state)
                    score = score + 20;
                elseif strlength(transition.source_state) == 0
                    score = score - 10;
                else
                    score = score - 6;
                end
            elseif strlength(req.trigger) > 0 && strlength(transition.source_state) == 0
                if contains(lower(char(req.trigger)), 'power')
                    score = score + 8;
                else
                    score = score - 3;
                end
            end

            if score > bestScore
                bestScore = score;
                candidate.transition = transition;
                candidate.chart_index = chartIndex;
            end
        end
    end

    if bestScore <= 0
        candidate.transition = [];
        candidate.chart_index = [];
    end
end

function [pathSteps, notes] = inferPreconditionPath(candidate, context)
    pathSteps = struct([]);
    notes = strings(0,1);

    if isempty(candidate) || isempty(candidate.transition)
        return;
    end

    transition = candidate.transition;
    if isempty(candidate.chart_index)
        notes(end+1,1) = "The inferred transition could not be tied back to a Stateflow chart for path planning.";
        return;
    end

    chart = context.stateflow.charts(candidate.chart_index);
    startState = string(chart.default_state);
    goalState = string(transition.source_state);

    if strlength(startState) == 0 || strlength(goalState) == 0 || startState == goalState
        return;
    end

    [edges, found] = shortestTransitionPath(chart.transitions, startState, goalState);
    if ~found
        notes(end+1,1) = "A precondition path to the inferred source state could not be determined automatically.";
        return;
    end

    for i = 1:numel(edges)
        assignments = string(edges(i).assignments(:));
        assignments = assignments(assignments ~= "");
        step = struct( ...
            'step_name', "Reach " + edges(i).destination_state, ...
            'from_state', edges(i).source_state, ...
            'to_state', edges(i).destination_state, ...
            'transition_condition', singleLineText(edges(i).condition), ...
            'assignments', assignments, ...
            'duration', 0.2);
        if isempty(pathSteps)
            pathSteps = step;
        else
            pathSteps(end+1,1) = orderfields(step, pathSteps); %#ok<AGROW>
        end

        if numel(edges(i).notes) > 0
            notes = [notes; string(edges(i).notes(:))]; %#ok<AGROW>
        end
    end

    if ~isempty(edges)
        notes(end+1,1) = "Precondition path inferred from " + startState + " to " + goalState + ".";
    end
end

function [edges, found] = shortestTransitionPath(transitions, startState, goalState)
    edges = struct([]);
    found = false;

    validTransitions = transitions([transitions.supported] & ...
        strlength(string({transitions.source_state})) > 0 & ...
        strlength(string({transitions.destination_state})) > 0);

    queue = {char(startState)};
    visited = string(startState);
    parents = containers.Map('KeyType', 'char', 'ValueType', 'any');

    while ~isempty(queue)
        current = string(queue{1});
        queue(1) = [];

        if current == goalState
            found = true;
            break;
        end

        outgoing = validTransitions(strcmp(string({validTransitions.source_state}), current));
        for i = 1:numel(outgoing)
            nextState = string(outgoing(i).destination_state);
            if strlength(nextState) == 0 || any(visited == nextState)
                continue;
            end
            visited(end+1,1) = nextState; %#ok<AGROW>
            parents(char(nextState)) = outgoing(i);
            queue{end+1} = char(nextState); %#ok<AGROW>
        end
    end

    if ~found
        return;
    end

    cursor = goalState;
    while cursor ~= startState
        edge = parents(char(cursor));
        edges = [edge; edges]; %#ok<AGROW>
        cursor = string(edge.source_state);
    end
end

function mapping = buildTriggerMapping(req, candidate, context)
    mapping = struct( ...
        'phrase', req.trigger, ...
        'model_signal', "", ...
        'condition', "", ...
        'rationale', "");

    if isempty(candidate) || isempty(candidate.transition)
        return;
    end

    sourceState = string(candidate.transition.source_state);
    if strlength(sourceState) == 0
        if contains(lower(char(req.trigger)), 'power')
            mapping.model_signal = "Chart default transition";
            mapping.condition = "Simulation start";
            mapping.rationale = "Startup behavior is represented by chart initialization rather than by an external input change.";
        else
            mapping.rationale = "No explicit source state exists on the inferred transition; review the trigger mapping manually.";
        end
        return;
    end

    mapping.phrase = "the system is in " + sourceState + " mode";
    mapping.model_signal = "Logic.Mode";
    mapping.condition = resolveStateModeValue(sourceState, context);
    mapping.rationale = "Inferred from the source state of the matching Stateflow transition";
end

function phraseMappings = buildPhraseMappings(triggerMapping, inputMappings, behaviorMapping)
    phraseMappings = repmat(struct( ...
        'phrase', "", ...
        'model_element', "", ...
        'interpretation', ""), 0, 1);

    phraseMappings = appendPhraseMapping(phraseMappings, ...
        getFieldOrDefaultLocal(triggerMapping, 'phrase', ""), ...
        getFieldOrDefaultLocal(triggerMapping, 'model_signal', ""), ...
        buildInterpretationFromTrigger(triggerMapping));

    for i = 1:numel(inputMappings)
        phraseMappings = appendPhraseMapping(phraseMappings, ...
            getFieldOrDefaultLocal(inputMappings(i), 'phrase', ""), ...
            getFieldOrDefaultLocal(inputMappings(i), 'model_signal', ""), ...
            buildInterpretationFromInput(inputMappings(i)));
    end

    phraseMappings = appendPhraseMapping(phraseMappings, ...
        getFieldOrDefaultLocal(behaviorMapping, 'phrase', ""), ...
        getFieldOrDefaultLocal(behaviorMapping, 'model_signal', ""), ...
        buildInterpretationFromBehavior(behaviorMapping));
end

function phraseMappings = appendPhraseMapping(phraseMappings, phrase, modelElement, interpretation)
    phrase = string(phrase);
    modelElement = string(modelElement);
    interpretation = string(interpretation);

    if strlength(phrase) == 0 || strlength(modelElement) == 0
        return;
    end

    entry = struct( ...
        'phrase', phrase, ...
        'model_element', modelElement, ...
        'interpretation', interpretation);

    if isempty(phraseMappings)
        phraseMappings = entry;
        return;
    end

    duplicateIdx = find(strcmp(string({phraseMappings.phrase}), phrase) & ...
        strcmp(string({phraseMappings.model_element}), modelElement), 1);
    if isempty(duplicateIdx)
        phraseMappings(end+1,1) = orderfields(entry, phraseMappings); %#ok<AGROW>
    end
end

function interpretation = buildInterpretationFromTrigger(triggerMapping)
    modelSignal = string(getFieldOrDefaultLocal(triggerMapping, 'model_signal', ""));
    condition = string(getFieldOrDefaultLocal(triggerMapping, 'condition', ""));
    rationale = string(getFieldOrDefaultLocal(triggerMapping, 'rationale', ""));

    if strlength(modelSignal) == 0
        interpretation = rationale;
    elseif strlength(condition) > 0
        interpretation = modelSignal + " is evaluated using " + condition + ".";
    else
        interpretation = rationale;
    end

    interpretation = singleLineText(interpretation);
end

function interpretation = buildInterpretationFromInput(inputMapping)
    modelSignal = string(getFieldOrDefaultLocal(inputMapping, 'model_signal', ""));
    condition = string(getFieldOrDefaultLocal(inputMapping, 'condition', ""));
    rationale = string(getFieldOrDefaultLocal(inputMapping, 'rationale', ""));

    if strlength(modelSignal) == 0
        interpretation = rationale;
    elseif strlength(condition) > 0
        interpretation = modelSignal + " is checked using " + condition + ".";
    else
        interpretation = rationale;
    end

    interpretation = singleLineText(interpretation);
end

function interpretation = buildInterpretationFromBehavior(behaviorMapping)
    modelSignal = string(getFieldOrDefaultLocal(behaviorMapping, 'model_signal', ""));
    expectedValue = string(getFieldOrDefaultLocal(behaviorMapping, 'expected_value', ""));
    rationale = string(getFieldOrDefaultLocal(behaviorMapping, 'rationale', ""));

    if strlength(modelSignal) == 0
        interpretation = rationale;
    elseif strlength(expectedValue) > 0
        interpretation = "Verify " + modelSignal + " == " + expectedValue + ".";
    else
        interpretation = rationale;
    end

    interpretation = singleLineText(interpretation);
end

function value = getFieldOrDefaultLocal(s, fieldName, defaultValue)
    if isstruct(s) && isfield(s, fieldName)
        value = s.(fieldName);
    else
        value = defaultValue;
    end
end

function hints = inferRequirementStateHints(req, context)
    sourceText = req.trigger;
    if contains(lower(char(req.trigger)), 'power')
        sourceText = "";
    end
    states = collectAllStateNames(context);
    hints = struct( ...
        'source_state', findBestStateHint(sourceText, states), ...
        'destination_state', findBestStateHint(req.behavior, states));
end

function stateNames = collectAllStateNames(context)
    stateNames = strings(0,1);
    for i = 1:numel(context.stateflow.charts)
        stateNames = [stateNames; string({context.stateflow.charts(i).states.name}).']; %#ok<AGROW>
    end
    stateNames = unique(stateNames(stateNames ~= ""), 'stable');
end

function stateName = findBestStateHint(text, stateNames)
    stateName = "";
    bestScore = 0;
    for i = 1:numel(stateNames)
        score = stateTextScore(stateNames(i), text);
        if score > bestScore
            bestScore = score;
            stateName = stateNames(i);
        end
    end
end

function score = stateTextScore(stateName, text)
    if strlength(stateName) == 0 || strlength(text) == 0
        score = 0;
        return;
    end

    score = tokenOverlap(expandStateTokens(stateName), normalizeTokens(text));
end

function tf = stateMatchesHint(stateName, hintState)
    tf = strlength(stateName) > 0 && strlength(hintState) > 0 && ...
        tokenOverlap(expandStateTokens(stateName), expandStateTokens(hintState)) > 0;
end

function tokens = expandStateTokens(stateName)
    key = normalizeStateKey(stateName);
    tokens = normalizeTokens(stateName);

    switch key
        case "waitforcomms"
            tokens = [tokens; "wait"; "comms"; "communications"; "establish"];
        case "init"
            tokens = [tokens; "init"; "initialize"; "initialization"];
        case "calibration"
            tokens = [tokens; "calibration"; "calibrate"; "sensors"];
        case "readyforto"
            tokens = [tokens; "ready"; "flight"; "takeoff"; "to"];
    end

    tokens = unique(tokens(tokens ~= ""), 'stable');
end

function key = normalizeStateKey(text)
    key = lower(char(text));
    key = regexprep(key, '[^a-z0-9]+', '');
end

function text = singleLineText(text)
    text = string(text);
    text = replace(text, newline, ' ');
    text = strtrim(regexprep(text, '\s+', ' '));
end

function assignments = deriveDestinationHoldAssignments(stateName, context)
    assignments = strings(0,1);
    if strlength(stateName) == 0
        return;
    end

    for i = 1:numel(context.stateflow.charts)
        outgoing = context.stateflow.charts(i).transitions( ...
            strcmp(string({context.stateflow.charts(i).transitions.source_state}), stateName));
        for j = 1:numel(outgoing)
            negated = negateTransitionTerms(outgoing(j).mapping_terms, context.signal_catalog);
            assignments = [assignments; negated(:)]; %#ok<AGROW>
        end
    end

    assignments = unique(assignments(assignments ~= ""), 'stable');
end

function assignments = negateTransitionTerms(terms, signalCatalog)
    assignments = strings(0,1);
    for i = 1:numel(terms)
        term = terms(i);
        if ~term.supported || strlength(term.model_signal) == 0
            continue;
        end

        if contains(term.assignment, '= true;')
            assignments(end+1,1) = replace(term.assignment, '= true;', '= false;'); %#ok<AGROW>
            return;
        elseif contains(term.assignment, '= false;')
            assignments(end+1,1) = replace(term.assignment, '= false;', '= true;'); %#ok<AGROW>
            return;
        elseif contains(term.condition, '==')
            rhs = extractAfter(term.assignment, '=');
            rhs = strtrim(extractBefore(rhs, ';'));
            assignments(end+1,1) = term.model_signal + " = " + literalDifferentFrom(rhs, term.model_signal, signalCatalog) + ";"; %#ok<AGROW>
            return;
        elseif contains(term.condition, '>') || contains(term.condition, '>=')
            rhs = extractRelationalRhs(term.condition);
            assignments(end+1,1) = term.model_signal + " = " + literalBelow(rhs, term.model_signal, signalCatalog) + ";"; %#ok<AGROW>
            return;
        elseif contains(term.condition, '<') || contains(term.condition, '<=')
            rhs = extractRelationalRhs(term.condition);
            assignments(end+1,1) = term.model_signal + " = " + literalAbove(rhs) + ";"; %#ok<AGROW>
            return;
        end
    end
end

function rhs = extractRelationalRhs(condition)
    tok = regexp(char(condition), '(==|~=|>=|<=|>|<)\s*(.+)$', 'tokens', 'once');
    if isempty(tok)
        rhs = "0";
    else
        rhs = string(strtrim(tok{2}));
    end
end

function behaviorMapping = inferBehaviorMapping(req, transition, context)
    behaviorMapping = struct( ...
        'phrase', req.behavior, ...
        'model_signal', "", ...
        'expected_value', "", ...
        'rationale', "");

    stateValue = resolveStateModeValue(transition.destination_state, context);
    if strlength(stateValue) > 0
        behaviorMapping.model_signal = "Logic.Mode";
        behaviorMapping.expected_value = stateValue;
        behaviorMapping.rationale = "Mapped from the destination state of the inferred Stateflow transition";
        return;
    end

    behaviorMapping = fallbackBehaviorMapping(req, context);
end

function behaviorMapping = fallbackBehaviorMapping(req, context)
    behaviorMapping = struct( ...
        'phrase', req.behavior, ...
        'model_signal', "", ...
        'expected_value', "", ...
        'rationale', "Fallback mapping from output catalog");

    outputModeSignal = findOutputSignal("Mode", context.signal_catalog);
    if strlength(outputModeSignal) > 0
        behaviorMapping.model_signal = outputModeSignal;
        enumMatch = findBestEnumLiteral(req.behavior + " " + req.summary, context.enums);
        if strlength(enumMatch) > 0
            behaviorMapping.expected_value = enumMatch;
        end
    end
end

function signalValue = resolveStateModeValue(stateName, context)
    signalValue = "";
    for i = 1:numel(context.stateflow.charts)
        stateIdx = find(strcmp(string({context.stateflow.charts(i).states.name}), stateName), 1);
        if isempty(stateIdx)
            continue;
        end
        signalValue = context.stateflow.charts(i).states(stateIdx).mode_output_value;
        return;
    end
end

function signalPath = findOutputSignal(signalName, signalCatalog)
    signalPath = "";
    idx = find(strcmp(string({signalCatalog.scope}), "output") & strcmpi(string({signalCatalog.base_path}), "Logic." + signalName), 1);
    if isempty(idx)
        idx = find(strcmp(string({signalCatalog.scope}), "output") & contains(string({signalCatalog.path}), signalName), 1);
    end
    if ~isempty(idx)
        signalPath = signalCatalog(idx).path;
    end
end

function enumLiteral = findBestEnumLiteral(text, enums)
    enumLiteral = "";
    textTokens = normalizeTokens(text);
    bestScore = 0;
    for i = 1:numel(enums)
        for j = 1:numel(enums(i).members)
            score = tokenOverlap(textTokens, normalizeTokens(enums(i).members(j).name));
            if score > bestScore
                bestScore = score;
                enumLiteral = enums(i).name + "." + enums(i).members(j).name;
            end
        end
    end
end

function assignments = buildDefaultInitAssignments(inputs)
    assignments = strings(0,1);
    for i = 1:numel(inputs)
        inputInfo = inputs(i);
        if inputInfo.is_bus
            for j = 1:numel(inputInfo.bus_elements)
                lhs = inputInfo.name + "." + inputInfo.bus_elements(j).name;
                rhs = defaultLiteral(inputInfo.bus_elements(j).data_type, inputInfo.bus_elements(j).dimensions);
                assignments(end+1,1) = lhs + " = " + rhs + ";"; %#ok<AGROW>
            end
        else
            rhs = defaultLiteral(inputInfo.data_type, inputInfo.dimensions);
            assignments(end+1,1) = inputInfo.name + " = " + rhs + ";"; %#ok<AGROW>
        end
    end
end

function message = buildVerifyMessage(req)
    if strlength(req.summary) > 0
        message = req.summary;
    else
        message = "Requirement " + req.id + " should hold";
    end
end

function tokens = normalizeTokens(text)
    if isstring(text)
        text = join(text, " ");
    end
    text = lower(char(text));
    text = regexprep(text, '([a-z])([A-Z])', '$1 $2');
    text = strrep(text, 'communications', 'comms');
    text = strrep(text, 'communication', 'comms');
    text = strrep(text, 'quadcopter', '');
    text = regexprep(text, '[^a-z0-9]+', ' ');
    parts = split(string(strtrim(text)));
    parts = parts(parts ~= "");
    stopWords = ["the","system","shall","when","while","if","then","and","or","is","in","to","from","mode","enter"];
    tokens = unique(parts(~ismember(parts, stopWords)));
end

function score = tokenOverlap(lhs, rhs)
    if isstring(lhs), lhs = lhs(:); end
    if isstring(rhs), rhs = rhs(:); end
    score = numel(intersect(lhs, rhs));
end

function text = escapeSingleQuotes(text)
    text = replace(string(text), "'", "''");
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

    numericValue = extractNumericLiteralLocal(rhs);
    if ~isempty(numericValue)
        literal = adjustTypedNumericLiteralLocal(rhs, +1);
    else
        literal = typedZeroLiteralLocal(signalPath, signalCatalog);
    end
end

function literal = literalAbove(rhs)
    literal = adjustTypedNumericLiteralLocal(rhs, +1);
end

function literal = literalBelow(rhs, signalPath, signalCatalog)
    numericValue = extractNumericLiteralLocal(rhs);
    if ~isempty(numericValue) && numericValue > 0
        literal = adjustTypedNumericLiteralLocal(rhs, -1);
    else
        literal = typedZeroLiteralLocal(signalPath, signalCatalog);
    end
end

function literal = typedZeroLiteralLocal(signalPath, signalCatalog)
    basePath = regexprep(string(signalPath), '\(\d+\)$', '');
    idx = find(strcmp(string({signalCatalog.base_path}), basePath) & strcmp(string({signalCatalog.scope}), "input"), 1);
    if isempty(idx)
        literal = "0";
    else
        literal = defaultLiteral(signalCatalog(idx).data_type, 1);
    end
end

function literal = adjustTypedNumericLiteralLocal(rhs, direction)
    rhs = string(strtrim(rhs));
    tok = regexp(char(rhs), '^([A-Za-z]\w*)\(\s*([-+]?\d*\.?\d+(?:[eE][-+]?\d+)?)\s*\)$', 'tokens', 'once');
    if isempty(tok)
        numericValue = extractNumericLiteralLocal(rhs);
        if isempty(numericValue)
            literal = rhs;
            return;
        end
        literal = string(num2str(adjustNumericValueLocal(numericValue, direction)));
        return;
    end

    castName = string(tok{1});
    numericValue = str2double(tok{2});
    adjustedValue = adjustNumericValueLocal(numericValue, direction);
    if startsWith(castName, ["uint", "int"])
        adjustedValue = round(adjustedValue);
    end
    literal = castName + "(" + string(num2str(adjustedValue, '%.15g')) + ")";
end

function value = adjustNumericValueLocal(value, direction)
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

function value = extractNumericLiteralLocal(text)
    tok = regexp(char(text), '[-+]?\d*\.?\d+(?:[eE][-+]?\d+)?', 'match', 'once');
    if isempty(tok)
        value = [];
    else
        value = str2double(tok);
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
