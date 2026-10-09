function result = buildHarnessesFromApprovedYaml(modelName, yamlPath, varargin)
%BUILDHARNESSESFROMAPPROVEDYAML Generate harnesses from an approved YAML file.
%   RESULT = buildHarnessesFromApprovedYaml(MODELNAME, YAMLPATH) converts the
%   approved YAML review file into signalMappings and creates associated
%   external harnesses directly against the source model by default.
%
%   RESULT = buildHarnessesFromApprovedYaml(..., 'AssociateWithSourceModel', false)
%   uses the legacy staged-build fallback. That mode generates harnesses in a
%   writable temp workspace and copies the resulting .slx files back into the
%   source directory, but those copied files are not registered as harnesses
%   on the source model.

    parser = inputParser;
    addParameter(parser, 'SourceDir', pwd, @(x) ischar(x) || isstring(x));
    addParameter(parser, 'DestinationRoot', tempdir, @(x) ischar(x) || isstring(x));
    addParameter(parser, 'OutputFolderName', 'test_harnesses', @(x) ischar(x) || isstring(x));
    addParameter(parser, 'CopyHarnessesBack', true, @(x) islogical(x) || isnumeric(x));
    addParameter(parser, 'AssociateWithSourceModel', true, @(x) islogical(x) || isnumeric(x));
    parse(parser, varargin{:});

    sourceDir = char(parser.Results.SourceDir);
    destinationRoot = char(parser.Results.DestinationRoot);
    outputFolderName = char(parser.Results.OutputFolderName);
    copyHarnessesBack = logical(parser.Results.CopyHarnessesBack);
    associateWithSourceModel = logical(parser.Results.AssociateWithSourceModel);

    yamlSourcePath = resolveSourcePath(sourceDir, yamlPath);
    sourceHarnessFolder = fullfile(sourceDir, outputFolderName);
    sourceModelPath = fullfile(sourceDir, [modelName '.slx']);

    if associateWithSourceModel
        ensureSourceModelWritable(sourceModelPath);

        originalDir = pwd;
        cleaner = onCleanup(@() cd(originalDir));
        cd(sourceDir);

        signalMappings = generateSignalMappingsFromYaml(yamlSourcePath);
        generateTestSequencesFromRequirements(modelName, signalMappings, 'OutputFolder', sourceHarnessFolder);

        result = struct();
        result.source_dir = string(sourceDir);
        result.build_dir = "";
        result.output_folder = string(sourceHarnessFolder);
        result.source_output_folder = string(sourceHarnessFolder);
        result.yaml_source_path = string(yamlSourcePath);
        result.yaml_build_path = "";
        result.copied_harnesses = collectHarnesses(sourceHarnessFolder);
        result.test_sequence_blocks = deriveTestSequenceBlocks(result.copied_harnesses);
        result.association_mode = "associated_external_harness";
        return;
    end

    buildInfo = prepareWritableBuildWorkspace(sourceDir, 'DestinationRoot', destinationRoot);
    buildDir = char(buildInfo.build_dir);
    outputFolder = fullfile(buildDir, outputFolderName);

    yamlBuildPath = fullfile(buildDir, relativeSourcePath(sourceDir, yamlSourcePath));

    originalDir = pwd;
    cleaner = onCleanup(@() cd(originalDir));
    cd(buildDir);

    signalMappings = generateSignalMappingsFromYaml(yamlBuildPath);
    generateTestSequencesFromRequirements(modelName, signalMappings, 'OutputFolder', outputFolder);

    copiedHarnesses = strings(0,1);
    if copyHarnessesBack && exist(outputFolder, 'dir')
        if ~exist(sourceHarnessFolder, 'dir')
            mkdir(sourceHarnessFolder);
        end
        harnessFiles = dir(fullfile(outputFolder, '*.slx'));
        for i = 1:numel(harnessFiles)
            copyfile(fullfile(outputFolder, harnessFiles(i).name), fullfile(sourceHarnessFolder, harnessFiles(i).name));
            copiedHarnesses(end+1,1) = string(fullfile(sourceHarnessFolder, harnessFiles(i).name)); %#ok<AGROW>
        end
    end

    result = struct();
    result.source_dir = string(sourceDir);
    result.build_dir = string(buildDir);
    result.output_folder = string(outputFolder);
    result.source_output_folder = string(sourceHarnessFolder);
    result.yaml_source_path = string(yamlSourcePath);
    result.yaml_build_path = string(yamlBuildPath);
    result.copied_harnesses = copiedHarnesses;
    result.test_sequence_blocks = deriveTestSequenceBlocks(result.copied_harnesses);
    result.association_mode = "copied_standalone_harness_files";
end

function path = resolveSourcePath(sourceDir, inputPath)
    inputPath = char(inputPath);
    if isfile(inputPath)
        path = inputPath;
    else
        path = fullfile(sourceDir, inputPath);
    end
end

function relPath = relativeSourcePath(sourceDir, sourcePath)
    sourceDir = string(char(java.io.File(sourceDir).getCanonicalPath()));
    sourcePath = string(char(java.io.File(sourcePath).getCanonicalPath()));

    prefix = sourceDir + filesep;
    if startsWith(sourcePath, prefix)
        relPath = char(extractAfter(sourcePath, strlength(prefix)));
    elseif sourcePath == sourceDir
        relPath = '';
    else
        [~, name, ext] = fileparts(sourcePath);
        relPath = [name ext];
    end
end

function ensureSourceModelWritable(modelPath)
    if ~isfile(modelPath)
        error('Source model file not found: %s', modelPath);
    end

    [status, attributes] = fileattrib(modelPath);
    if status && isfield(attributes, 'UserWrite') && ~attributes.UserWrite
        error(['Source model is not writable: %s\n' ...
            'Associated external harness creation updates and saves the owner model. ' ...
            'Set ''AssociateWithSourceModel'', false only if you want copied harness files without source-model association.'], modelPath);
    end
end

function harnessPaths = collectHarnesses(folderPath)
    harnessPaths = strings(0,1);
    if ~exist(folderPath, 'dir')
        return;
    end

    harnessFiles = dir(fullfile(folderPath, '*.slx'));
    for i = 1:numel(harnessFiles)
        harnessPaths(end+1,1) = string(fullfile(folderPath, harnessFiles(i).name)); %#ok<AGROW>
    end
end

function blockPaths = deriveTestSequenceBlocks(harnessPaths)
    blockPaths = strings(0,1);
    for i = 1:numel(harnessPaths)
        [~, harnessName] = fileparts(char(harnessPaths(i)));
        blockPaths(end+1,1) = string([harnessName '/Test Sequence']); %#ok<AGROW>
    end
end
