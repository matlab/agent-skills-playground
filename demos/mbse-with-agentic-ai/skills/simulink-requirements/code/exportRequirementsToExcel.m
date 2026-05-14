function xlsxFile = exportRequirementsToExcel(slreqxFile, xlsxFile)
% EXPORTREQUIREMENTSTOEXCEL Export a .slreqx to .xlsx preserving hierarchy.
%   Columns: Index, Depth, ParentIndex, Id, Summary, Description, Rationale, DerivedFrom.
%   Rows are emitted in depth-first order so each parent precedes its
%   children; siblings are sorted by natural order on Index (1, 2, 10
%   rather than 1, 10, 2). Index is the
%   hierarchical path ("1", "1.1", "1.1.2"); Depth is 0 for top-level;
%   ParentIndex is blank for top-level. DerivedFrom is filled from
%   incoming Derive links (comma-separated parent IDs).
%
%   There is no public slreq Excel-export API -- slreq.export emits ReqIF
%   only, and the Requirements Editor's xlsx export is GUI-only. This
%   function builds the table manually with writetable.
%
%   Inputs:
%     slreqxFile - Full path to the .slreqx file
%     xlsxFile   - (optional) Output xlsx path; defaults to sibling of slreqx
%
%   Output:
%     xlsxFile - Full path to the written xlsx file

    if nargin < 2 || isempty(xlsxFile)
        xlsxFile = strrep(slreqxFile, '.slreqx', '.xlsx');
    end

    [xlsxDir, xlsxName, xlsxExt] = fileparts(xlsxFile);
    lockFile = fullfile(xlsxDir, ['~$' xlsxName xlsxExt]);
    if isfile(lockFile)
        error('exportRequirementsToExcel:locked', ...
            '%s is open in Excel -- close it and retry.', xlsxFile);
    end

    rs = slreq.load(slreqxFile);
    T  = reqSetToTable(rs);

    if isfile(xlsxFile), delete(xlsxFile); end
    writetable(T, xlsxFile);
    fprintf('%s -> %s (%d reqs)\n', rs.Name, xlsxFile, height(T));
end

function T = reqSetToTable(rs)
    reqs = find(rs, 'Type', 'Requirement');
    n = numel(reqs);
    idxCol   = strings(n,1);
    depthCol = zeros(n,1);
    pidxCol  = strings(n,1);
    idCol    = strings(n,1);
    sumCol   = strings(n,1);
    descCol  = strings(n,1);
    ratCol   = strings(n,1);
    derCol   = strings(n,1);
    row = 0;

    isTop = arrayfun(@(r) ~isa(r.parent(), 'slreq.Requirement'), reqs);
    tops  = sortByIndex(reqs(isTop));
    for i = 1:numel(tops)
        walk(tops(i), 0, "");
    end

    T = table(idxCol, depthCol, pidxCol, idCol, sumCol, descCol, ratCol, derCol, ...
        'VariableNames', {'Index','Depth','ParentIndex','Id','Summary','Description','Rationale','DerivedFrom'});

    function walk(req, d, parentIdx)
        row = row + 1;
        idxCol(row)   = string(req.Index);
        depthCol(row) = d;
        pidxCol(row)  = string(parentIdx);
        idCol(row)    = string(req.Id);
        sumCol(row)   = string(req.Summary);
        descCol(row)  = string(req.getDescriptionAsText());
        ratCol(row)   = string(req.Rationale);
        derCol(row)   = strjoin(deriveParents(req), ', ');
        kids = sortByIndex(req.children());
        for k = 1:numel(kids)
            walk(kids(k), d+1, req.Index);
        end
    end
end

function sorted = sortByIndex(reqs)
    n = numel(reqs);
    if n < 2, sorted = reqs; return; end
    parts = cell(n, 1);
    maxLen = 0;
    for i = 1:n
        parts{i} = str2double(strsplit(string(reqs(i).Index), "."));
        maxLen = max(maxLen, numel(parts{i}));
    end
    padded = zeros(n, maxLen);
    for i = 1:n
        padded(i, 1:numel(parts{i})) = parts{i};
    end
    [~, order] = sortrows(padded);
    sorted = reqs(order);
end

function ids = deriveParents(req)
    ids  = strings(0,1);
    lnks = req.inLinks();
    for k = 1:numel(lnks)
        if strcmp(lnks(k).Type, 'Derive')
            % getSourceLabel() returns "ID Summary"; strtok pulls just the ID
            ids(end+1,1) = string(strtok(lnks(k).getSourceLabel())); %#ok<AGROW>
        end
    end
end
