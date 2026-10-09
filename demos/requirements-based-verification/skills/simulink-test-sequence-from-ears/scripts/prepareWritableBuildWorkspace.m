function buildInfo = prepareWritableBuildWorkspace(sourceDir, varargin)
%PREPAREWRITABLEBUILDWORKSPACE Copy project artifacts to a writable folder.
%   BUILDINFO = prepareWritableBuildWorkspace(SOURCEDIR) stages the source
%   directory in a temporary writable location for staged validation or
%   copy-only harness export workflows when the source model cannot be
%   updated directly.

    if nargin < 1 || strlength(string(sourceDir)) == 0
        sourceDir = pwd;
    end

    parser = inputParser;
    addParameter(parser, 'DestinationRoot', tempdir, @(x) ischar(x) || isstring(x));
    addParameter(parser, 'Exclude', {'slprj', 'test_harnesses', '.git'}, @(x) iscell(x) || isstring(x));
    parse(parser, varargin{:});

    sourceDir = char(sourceDir);
    destinationRoot = char(parser.Results.DestinationRoot);
    excludeNames = string(parser.Results.Exclude);

    buildDir = fullfile(destinationRoot, ['simulink_test_sequence_build_' char(string(java.util.UUID.randomUUID))]);
    mkdir(buildDir);

    entries = dir(sourceDir);
    copied = strings(0,1);
    for i = 1:numel(entries)
        name = string(entries(i).name);
        if name == "." || name == ".." || any(name == excludeNames)
            continue;
        end
        copyfile(fullfile(sourceDir, char(name)), fullfile(buildDir, char(name)));
        copied(end+1,1) = name; %#ok<AGROW>
    end

    buildInfo = struct();
    buildInfo.source_dir = string(sourceDir);
    buildInfo.build_dir = string(buildDir);
    buildInfo.copied_entries = copied;
    buildInfo.instructions = "Use build_dir as the MATLAB project_path for harness generation.";
end
