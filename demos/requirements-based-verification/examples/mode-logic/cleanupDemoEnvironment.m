function cleanupDemoEnvironment()
%CLEANUPDEMOENVRIONMENT Remove generated test harnesses and clean up the demo environment.
%
%   cleanupDemoEnvironment() removes all test harnesses associated with the
%   ModeLogic model, deletes the generated harness files, and removes the
%   test_harnesses directory. Safe to run multiple times.

    modelName = 'ModeLogic';
    harnessFolder = fullfile(pwd, 'test_harnesses');

    % Close any open harnesses and remove them from the model
    try
        load_system(modelName);
        harnessInfo = sltest.harness.find(modelName);
        if ~isempty(harnessInfo)
            for i = 1:numel(harnessInfo)
                hName = harnessInfo(i).name;
                fprintf('Removing harness: %s\n', hName);
                try
                    sltest.harness.close(modelName, hName);
                catch
                end
                sltest.harness.delete(modelName, hName);
            end
            save_system(modelName);
            fprintf('Removed %d harness(es) from %s.\n', numel(harnessInfo), modelName);
        else
            fprintf('No harnesses found on %s.\n', modelName);
        end
    catch ME
        fprintf('Warning: Could not clean harnesses from model: %s\n', ME.message);
    end

    % Delete the external harness metadata file
    harnessInfoFile = fullfile(pwd, [modelName '_harnessInfo.xml']);
    if exist(harnessInfoFile, 'file')
        delete(harnessInfoFile);
        fprintf('Deleted %s\n', harnessInfoFile);
    end

    % Delete harness files and directory
    if exist(harnessFolder, 'dir')
        fprintf('Deleting %s and contents...\n', harnessFolder);
        rmdir(harnessFolder, 's');
        fprintf('Done.\n');
    else
        fprintf('No test_harnesses directory to remove.\n');
    end

    fprintf('Cleanup complete.\n');
end
