function setupMBSEProject(projectName, projectFolder)
% SETUPMBSEPROJECT Create a new MBSE MATLAB project with the standard RFLPV folder layout.
%   Thin wrapper over setupProject (from the matlab-project skill) that pins
%   the MBSE folder set: requirements/, architecture/, analysis/, verification/,
%   scripts/ — all tracked and on the path — plus derived/cache and
%   derived/codegen for Simulink build outputs (untracked).
%
%   Inputs:
%     projectName   - Name for the MATLAB project (string)
%     projectFolder - Full path to the folder where the project will be created (string)
%
%   Both setupProject.m and setupMBSEProject.m are generated into the user's
%   scripts/ folder so they are on the project path together.

    setupProject(projectName, projectFolder, ...
        {'requirements', 'architecture', 'analysis', 'verification', 'scripts'}, ...
        {fullfile('derived','cache'), fullfile('derived','codegen')});
end
