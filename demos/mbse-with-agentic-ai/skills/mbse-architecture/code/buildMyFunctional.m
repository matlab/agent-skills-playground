function buildMyFunctional(modelName, dictFile, archDir)
% BUILDMYFUNCTIONAL Create a System Composer functional architecture model.
%   Deletes and recreates the functional interface dictionary and model on
%   every run (idempotent). Build this before the physical model.
%
%   Inputs:
%     modelName - Name of the functional SC model, e.g. "MyFunctional" (string)
%     dictFile  - Full path to the functional interface dictionary (.sldd) (string)
%     archDir   - Directory in which to save the model file (string)

    slxFile = fullfile(archDir, char(modelName) + ".slx");

    if bdIsLoaded(modelName), close_system(modelName, 0); end
    Simulink.data.dictionary.closeAll("-discard");
    if isfile(dictFile), delete(dictFile); end
    if isfile(slxFile),  delete(slxFile);  end

    addpath(archDir);
    dict = systemcomposer.createDictionary(dictFile);

    % Add logical interfaces — abstract, no physical implementation detail
    myFlowIface = addInterface(dict, "MyFlow");
    addElement(myFlowIface, "Value", Type="double");
    % ... more interfaces ...
    dict.save();

    % Re-fetch after save (required before use in setInterface)
    myFlowIface = dict.getInterface("MyFlow");

    model = systemcomposer.createModel(modelName);
    arch  = model.Architecture;
    linkDictionary(model, strrep(dictFile, '\', '/'));

    funcA = addComponent(arch, "FunctionA");
    addTypedPort(funcA.Architecture, "FlowOut", "out", myFlowIface);
    % ... more functions, ports, connections ...

    Simulink.BlockDiagram.arrangeSystem(modelName);
    save_system(char(modelName), char(fullfile(archDir, modelName)));
    open_system(char(modelName));
end

% ── Helpers ──────────────────────────────────────────────────────────────────

function addTypedPort(compArch, name, direction, iface)
    port = addPort(compArch, name, direction);
    port.setInterface(iface);
end
