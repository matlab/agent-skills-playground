function writeMappingReviewYaml(outputPath, reviewEntries, varargin)
%WRITEMAPPINGREVIEWYAML Write a YAML review artifact for requirement mapping.
%   writeMappingReviewYaml(OUTPUTPATH, REVIEWENTRIES) serializes a struct
%   scalar or struct array to a YAML file for user review before test
%   generation. The top-level YAML key is "requirements".
%
%   writeMappingReviewYaml(..., 'OpenInEditor', TF) controls whether the
%   generated YAML file should be opened in the MATLAB Editor after it is
%   written. The default is true when a MATLAB desktop session is active.
%
%   Intended use:
%     - Phase 1 extracts requirement text and proposes model signal mappings
%     - The agent writes mapping_review.yaml
%     - The user reviews and approves or edits the file
%     - Phase 2 generates test sequences only after approval
%
%   REVIEWENTRIES is expected to contain fields such as:
%     requirement_id, summary, requirement_text, ears_pattern,
%     trigger, behavior, mapping, test_assumptions, open_questions, status

    if nargin < 2
        error('writeMappingReviewYaml requires outputPath and reviewEntries.');
    end

    parser = inputParser;
    addParameter(parser, 'OpenInEditor', true, @(x) islogical(x) || isnumeric(x));
    parse(parser, varargin{:});
    openInEditor = logical(parser.Results.OpenInEditor);

    if isstring(outputPath)
        outputPath = char(outputPath);
    end

    if isempty(reviewEntries)
        error('reviewEntries must not be empty.');
    end

    if ~isstruct(reviewEntries)
        error('reviewEntries must be a struct scalar or struct array.');
    end

    fid = fopen(outputPath, 'w');
    if fid == -1
        error('Unable to open %s for writing.', outputPath);
    end

    cleaner = onCleanup(@() fclose(fid));

    fprintf(fid, 'requirements:\n');
    writeValue(fid, reviewEntries, 1, true);

    yamlPath = string(outputPath);
    if ~isfile(yamlPath)
        yamlPath = fullfile(pwd, yamlPath);
    end
    yamlPath = string(yamlPath);

    fprintf('Mapping review written to %s\n', yamlPath);
    maybeOpenInEditor(yamlPath, openInEditor);
end

function maybeOpenInEditor(yamlPath, openInEditor)
    if ~openInEditor
        return;
    end

    if ~usejava('desktop')
        return;
    end

    try
        if exist('matlab.desktop.editor.openDocument', 'file') == 2 || ...
                exist('matlab.desktop.editor.openDocument', 'builtin') == 5
            matlab.desktop.editor.openDocument(char(yamlPath));
        else
            edit(char(yamlPath));
        end
    catch ME
        warning('writeMappingReviewYaml:OpenInEditorFailed', ...
            'Wrote mapping review to %s but could not open it in the MATLAB Editor: %s', ...
            yamlPath, ME.message);
    end
end

function writeValue(fid, value, indentLevel, listItem)
    indent = repmat('  ', 1, indentLevel);
    itemPrefix = '';

    if nargin < 4
        listItem = false;
    end

    if listItem
        itemPrefix = [indent '- '];
    end

    if isstruct(value)
        writeStruct(fid, value, indentLevel, listItem);
    elseif iscell(value)
        writeCell(fid, value, indentLevel, listItem);
    elseif isstring(value)
        writeStringArray(fid, value, indentLevel, listItem);
    elseif ischar(value)
        writeChar(fid, value, itemPrefix);
    elseif isnumeric(value) || islogical(value)
        writeNumeric(fid, value, itemPrefix);
    else
        writeChar(fid, char(string(value)), itemPrefix);
    end
end

function writeStruct(fid, s, indentLevel, listItem)
    indent = repmat('  ', 1, indentLevel);

    if numel(s) > 1
        for i = 1:numel(s)
            writeStruct(fid, s(i), indentLevel, true);
        end
        return;
    end

    fields = fieldnames(s);
    if listItem
        if isempty(fields)
            fprintf(fid, '%s- {}\n', indent);
            return;
        end
        firstField = fields{1};
        firstValue = s.(firstField);
        writeKeyValue(fid, firstField, firstValue, indentLevel, true);
        for i = 2:numel(fields)
            writeKeyValue(fid, fields{i}, s.(fields{i}), indentLevel + 1, false);
        end
    else
        if isempty(fields)
            fprintf(fid, '%s{}\n', indent);
            return;
        end
        for i = 1:numel(fields)
            writeKeyValue(fid, fields{i}, s.(fields{i}), indentLevel, false);
        end
    end
end

function writeCell(fid, c, indentLevel, listItem)
    indent = repmat('  ', 1, indentLevel);

    if listItem
        if isempty(c)
            fprintf(fid, '%s- []\n', indent);
            return;
        end
        fprintf(fid, '%s-\n', indent);
        indentLevel = indentLevel + 1;
    elseif isempty(c)
        fprintf(fid, '%s[]\n', indent);
        return;
    end

    for i = 1:numel(c)
        writeValue(fid, c{i}, indentLevel, true);
    end
end

function writeStringArray(fid, s, indentLevel, listItem)
    if isempty(s)
        indent = repmat('  ', 1, indentLevel);
        if listItem
            fprintf(fid, '%s- []\n', indent);
        else
            fprintf(fid, '%s[]\n', indent);
        end
        return;
    end

    if isscalar(s)
        writeChar(fid, char(s), listPrefix(indentLevel, listItem));
        return;
    end

    indent = repmat('  ', 1, indentLevel);
    if listItem
        fprintf(fid, '%s-\n', indent);
        indentLevel = indentLevel + 1;
    end

    for i = 1:numel(s)
        writeChar(fid, char(s(i)), [repmat('  ', 1, indentLevel) '- ']);
    end
end

function writeChar(fid, text, prefix)
    if nargin < 3
        prefix = '';
    end

    if contains(text, newline)
        lines = splitlines(string(text));
        lines = cellstr(lines);
        fprintf(fid, '%s|-\n', prefix);
        blockIndent = blockIndentFromPrefix(prefix);
        for i = 1:numel(lines)
            if i == numel(lines) && isempty(lines{i})
                continue;
            end
            fprintf(fid, '%s%s\n', blockIndent, lines{i});
        end
    else
        fprintf(fid, '%s%s\n', prefix, yamlScalar(text));
    end
end

function writeNumeric(fid, value, prefix)
    if nargin < 3
        prefix = '';
    end

    if isscalar(value)
        if islogical(value)
            if value
                fprintf(fid, '%strue\n', prefix);
            else
                fprintf(fid, '%sfalse\n', prefix);
            end
        else
            fprintf(fid, '%s%s\n', prefix, num2str(value));
        end
        return;
    end

    fprintf(fid, '%s%s\n', prefix, yamlInlineArray(value));
end

function writeKeyValue(fid, key, value, indentLevel, listItem)
    indent = repmat('  ', 1, indentLevel);
    key = char(key);

    if nargin < 4
        listItem = false;
    end

    if listItem
        prefix = [indent '- ' key ': '];
    else
        prefix = [indent key ': '];
    end

    if isstruct(value)
        if isempty(value)
            fprintf(fid, '%s{}\n', prefix);
        elseif isscalar(value)
            fprintf(fid, '%s\n', prefix(1:end-1));
            writeStruct(fid, value, indentLevel + 1, false);
        else
            fprintf(fid, '%s\n', prefix(1:end-1));
            writeStruct(fid, value, indentLevel + 1, true);
        end
    elseif iscell(value)
        if isempty(value)
            fprintf(fid, '%s[]\n', prefix);
        else
            fprintf(fid, '%s\n', prefix(1:end-1));
            writeCell(fid, value, indentLevel + 1, false);
        end
    elseif isstring(value) && ~isscalar(value)
        if isempty(value)
            fprintf(fid, '%s[]\n', prefix);
        else
            fprintf(fid, '%s\n', prefix(1:end-1));
            writeStringArray(fid, value, indentLevel + 1, false);
        end
    elseif (ischar(value) || (isstring(value) && isscalar(value))) && contains(string(value), newline)
        fprintf(fid, '%s|-\n', prefix);
        lines = splitlines(string(value));
        blockIndent = [indent '  '];
        for i = 1:numel(lines)
            if i == numel(lines) && strlength(lines(i)) == 0
                continue;
            end
            fprintf(fid, '%s%s\n', blockIndent, char(lines(i)));
        end
    elseif ischar(value)
        fprintf(fid, '%s%s\n', prefix, yamlScalar(value));
    elseif isstring(value)
        fprintf(fid, '%s%s\n', prefix, yamlScalar(char(value)));
    elseif isnumeric(value) || islogical(value)
        if isscalar(value)
            writeNumeric(fid, value, prefix);
        else
            fprintf(fid, '%s%s\n', prefix, yamlInlineArray(value));
        end
    else
        fprintf(fid, '%s%s\n', prefix, yamlScalar(char(string(value))));
    end
end

function out = yamlScalar(text)
    text = strrep(text, '''', '''''');
    out = ['''' text ''''];
end

function out = yamlInlineArray(value)
    items = strings(1, numel(value));
    for i = 1:numel(value)
        if islogical(value(i))
            items(i) = string(lower(mat2str(value(i))));
        else
            items(i) = string(num2str(value(i)));
        end
    end
    out = ['[' char(strjoin(items, ', ')) ']'];
end

function prefix = listPrefix(indentLevel, listItem)
    indent = repmat('  ', 1, indentLevel);
    if listItem
        prefix = [indent '- '];
    else
        prefix = indent;
    end
end

function indent = blockIndentFromPrefix(prefix)
    if endsWith(prefix, '- ')
        indent = [prefix(1:end-2) '  '];
    else
        indent = [prefix '  '];
    end
end
