function setupProject(projectName, projectFolder, subfolders, derivedSubfolders)
% SETUPPROJECT Create a new MATLAB Project with standard folder structure.
%   Creates the project, tracked subfolders (also added to the MATLAB path),
%   and derived subfolders for build outputs (untracked). Closes the project
%   at the end so the caller can re-open it at the right time.
%
%   Inputs:
%     projectName       - Name for the MATLAB project (string or char)
%     projectFolder     - Full path to the folder where the project will be
%                         created (string or char)
%     subfolders        - Cell array of folder names to create, track, and
%                         add to the project path. E.g. {'src','tests'}
%     derivedSubfolders - Cell array of folder names for build outputs.
%                         Created but NOT tracked. The first entry is used
%                         as the Simulink cache folder and the second as
%                         the code generation folder, if present.
%                         E.g. {fullfile('derived','cache'), fullfile('derived','codegen')}
%
%   Example:
%     setupProject("MySystem", "C:\work\MySystem", ...
%         {'requirements','architecture','scripts'}, ...
%         {fullfile('derived','cache'), fullfile('derived','codegen')});

    if nargin < 3 || isempty(subfolders),        subfolders = {}; end
    if nargin < 4 || isempty(derivedSubfolders), derivedSubfolders = {}; end

    proj    = matlab.project.createProject(Name=projectName, Folder=projectFolder);
    rootDir = proj.RootFolder;

    % Tracked folders: created, added as project files, and on the project path.
    % IMPORTANT: tracked folders that are on the MATLAB path must also be
    % registered via addPath, or runChecks fails with Project:Checks:ProjectPath.
    for i = 1:numel(subfolders)
        folderPath = fullfile(rootDir, subfolders{i});
        mkdir(folderPath);
        addFolderIncludingChildFiles(proj, folderPath);
        addPath(proj, folderPath);
    end

    % Derived folders: created but NOT tracked (build outputs).
    for i = 1:numel(derivedSubfolders)
        mkdir(fullfile(rootDir, derivedSubfolders{i}));
    end

    % Point Simulink cache/codegen at the first two derived folders if supplied.
    % CRITICAL: use absolute paths — these properties resolve relative to the
    % current working directory, not the project root.
    if numel(derivedSubfolders) >= 1
        proj.SimulinkCacheFolder = fullfile(rootDir, derivedSubfolders{1});
    end
    if numel(derivedSubfolders) >= 2
        proj.SimulinkCodeGenFolder = fullfile(rootDir, derivedSubfolders{2});
    end

    close(proj);
    fprintf("Project created: %s\n", rootDir);
    fprintf("Open with: openProject('%s')\n", rootDir);
end
