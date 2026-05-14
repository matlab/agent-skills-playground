function reqSet = importMyRequirements(xlsxFile, setName, opts)
% IMPORTMYREQUIREMENTS Import an Excel file into an editable requirement set.
%   Wrapper over slreq.import that (1) skips the header row, (2) maps the
%   standard columns Id/Summary/Description/Rationale, (3) saves the result
%   to disk — slreq.import leaves the set Dirty in memory by default, and
%   (4) by default unwraps the auto-created "<File>!<Sheet>" Container so
%   requirements sit at the top level of the set.
%
%   Inputs:
%     xlsxFile - Full path to the source .xlsx file
%     setName  - Name (and filename stem) for the new requirement set
%     opts     - Optional name-value pairs:
%                destDir           (default: folder containing xlsxFile)
%                rows              (default: [2 lastRow] — skip header)
%                idColumn          (default: 1)
%                summaryColumn     (default: 2)
%                descriptionColumn (default: 3)
%                rationaleColumn   (default: 4)
%                attributeColumn   (default: [] — e.g. 5 to map DerivedFrom)
%                attributes        (default: {} — e.g. {'DerivedFrom'})
%                flatten           (default: true — unwrap the auto-Container)
%
%   Output:
%     reqSet - slreq.ReqSet (saved to disk)

    arguments
        xlsxFile (1,1) string
        setName  (1,1) string
        opts.destDir           string = ""
        opts.rows              double = []
        opts.idColumn          (1,1) double = 1
        opts.summaryColumn     (1,1) double = 2
        opts.descriptionColumn (1,1) double = 3
        opts.rationaleColumn   (1,1) double = 4
        opts.attributeColumn   double = []
        opts.attributes        cell   = {}
        opts.flatten           (1,1) logical = true
    end

    if strlength(opts.destDir) == 0
        opts.destDir = fileparts(xlsxFile);
    end
    if isempty(opts.rows)
        t = readtable(xlsxFile, 'VariableNamingRule','preserve');
        opts.rows = [2, height(t) + 1];   % +1 because readtable skips header row
    end

    % slreq.import writes the new .slreqx into the current folder — cd first.
    oldCd = cd(opts.destDir);
    c = onCleanup(@() cd(oldCd));

    args = {xlsxFile, ...
        'ReqSet',            char(setName), ...
        'AsReference',       false, ...
        'rows',              opts.rows, ...
        'idColumn',          opts.idColumn, ...
        'summaryColumn',     opts.summaryColumn, ...
        'descriptionColumn', opts.descriptionColumn, ...
        'rationaleColumn',   opts.rationaleColumn};
    if ~isempty(opts.attributeColumn)
        args = [args, {'attributeColumn', opts.attributeColumn, 'attributes', opts.attributes}];
    end

    [n, ~, reqSet] = slreq.import(args{:});

    if opts.flatten
        flattenImportContainer(reqSet);
    end

    reqSet.save();   % slreq.import does NOT save to disk on its own

    fprintf('Imported %d requirements -> %s\n', n, reqSet.Filename);
end

function flattenImportContainer(rs)
% Unwrap the auto-created "<File>!<Sheet>" Container that slreq.import adds.
% Promote each direct child forward (preserving any sub-tree beneath that
% child — real nested hierarchy is NOT touched), then remove the now-empty
% Container. No-op if no Container is present, or if more than one
% Container node sits at the top level (which would not be the auto-wrapper
% signature, so we stay conservative).
    top = rs.children();
    containers = top(strcmp({top.Type}, 'Container'));
    if numel(containers) ~= 1
        return;
    end
    cont = containers(1);
    kids = cont.children();
    % Forward order: each promote inserts the child just above the Container,
    % preserving sibling order relative to each other. Reverse-order promote
    % would reverse the sibling order in the resulting flat list.
    for i = 1:numel(kids)
        promote(kids(i));
    end
    cont.remove();
end
