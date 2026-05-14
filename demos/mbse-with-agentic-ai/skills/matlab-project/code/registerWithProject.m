function registerWithProject(files, folders)
% REGISTERWITHPROJECT Add files and folders to the MATLAB project if one is open.
%   registerWithProject(files, folders) tracks files and folders in the currently
%   open MATLAB project and adds folders to the project path. Safe to call
%   repeatedly — addFile and addPath are both idempotent. Silently does nothing
%   if no project is currently open.
%
%   Inputs:
%     files   - Cell array of absolute file paths; non-existent files are skipped
%     folders - Cell array of folder paths; each is tracked and added to project path
%               (optional, defaults to empty)

    if nargin < 2, folders = {}; end
    proj = matlab.project.currentProject();
    if isempty(proj.Name), return; end
    for i = 1:numel(files)
        if isfile(files{i}), addFile(proj, files{i}); end
    end
    for i = 1:numel(folders)
        if isfolder(folders{i})
            addFolderIncludingChildFiles(proj, folders{i});
            addPath(proj, folders{i});
        end
    end
end
