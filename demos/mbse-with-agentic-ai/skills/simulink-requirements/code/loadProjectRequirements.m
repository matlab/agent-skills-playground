function loadProjectRequirements(projRoot)
% LOADPROJECTREQUIREMENTS Load all requirement sets and link sets in a project tree.
%   Recursively discovers and loads all .slreqx and .slmx files under projRoot.
%   Safe to call on already-loaded files (slreq.load is idempotent).
%
%   Input:
%     projRoot - Root directory of the project (string)

    reqxFiles = dir(fullfile(projRoot, '**', '*.slreqx'));
    slmxFiles = dir(fullfile(projRoot, '**', '*.slmx'));

    for i = 1:numel(reqxFiles)
        slreq.load(fullfile(reqxFiles(i).folder, reqxFiles(i).name));
    end
    for i = 1:numel(slmxFiles)
        try
            slreq.load(fullfile(slmxFiles(i).folder, slmxFiles(i).name));
        catch
            % Skip files that fail to load (missing artifacts, unresolvable links, etc.)
        end
    end
end
