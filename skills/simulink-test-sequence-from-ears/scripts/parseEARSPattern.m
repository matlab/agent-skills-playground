function [pattern, trigger, behavior] = parseEARSPattern(reqText)
%PARSEEARSPATTERN Extract EARS pattern components from requirement text
%
%   Supported EARS patterns:
%     Ubiquitous:        "The system shall [behavior]"
%     Event-Driven:      "When [trigger], the system shall [behavior]"
%     State-Driven:      "While [state], the system shall [behavior]"
%     Unwanted Behavior: "If [condition], then the system shall [behavior]"
%     Optional:          "Where [feature], the system shall [behavior]"
%
%   Returns empty strings for pattern/trigger/behavior if no pattern matched.

    pattern  = '';
    trigger  = '';
    behavior = '';

    % Event-Driven: "When [trigger], the system shall [behavior]"
    tok = regexp(reqText, 'When\s+(.+?),\s+the\s+system\s+shall\s+(.+?)\.?$', ...
        'tokens', 'ignorecase');
    if ~isempty(tok)
        pattern  = 'Event-Driven';
        trigger  = strtrim(tok{1}{1});
        behavior = strtrim(tok{1}{2});
        return;
    end

    % State-Driven: "While [state], the system shall [behavior]"
    tok = regexp(reqText, 'While\s+(.+?),\s+the\s+system\s+shall\s+(.+?)\.?$', ...
        'tokens', 'ignorecase');
    if ~isempty(tok)
        pattern  = 'State-Driven';
        trigger  = strtrim(tok{1}{1});
        behavior = strtrim(tok{1}{2});
        return;
    end

    % Unwanted Behavior: "If [condition], then the system shall [behavior]"
    tok = regexp(reqText, 'If\s+(.+?),\s+then\s+the\s+system\s+shall\s+(.+?)\.?$', ...
        'tokens', 'ignorecase');
    if ~isempty(tok)
        pattern  = 'Unwanted Behavior';
        trigger  = strtrim(tok{1}{1});
        behavior = strtrim(tok{1}{2});
        return;
    end

    % Optional: "Where [feature], the system shall [behavior]"
    tok = regexp(reqText, 'Where\s+(.+?),\s+the\s+system\s+shall\s+(.+?)\.?$', ...
        'tokens', 'ignorecase');
    if ~isempty(tok)
        pattern  = 'Optional';
        trigger  = strtrim(tok{1}{1});
        behavior = strtrim(tok{1}{2});
        return;
    end

    % Ubiquitous: "The system shall [behavior]"  (no trigger condition)
    tok = regexp(reqText, 'The\s+system\s+shall\s+(.+?)\.?$', ...
        'tokens', 'ignorecase');
    if ~isempty(tok)
        pattern  = 'Ubiquitous';
        trigger  = '';
        behavior = strtrim(tok{1}{1});
        return;
    end
end
