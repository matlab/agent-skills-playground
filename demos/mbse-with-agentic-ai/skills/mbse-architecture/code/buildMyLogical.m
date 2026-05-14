function buildMyLogical(modelName, dictFile, archDir)
% BUILDMYLOGICAL Create a System Composer logical architecture model.
%   The logical layer captures design-agnostic solution principles — the "what"
%   between functions (F) and physical implementation (P). Components represent
%   solution elements (SensingUnit, ControlUnit, ActuationUnit) without
%   committing to specific hardware or software implementations.
%   Deletes and recreates the logical interface dictionary and model on
%   every run (idempotent). Build after the functional model.
%
%   Inputs:
%     modelName - Name of the logical SC model, e.g. "MyLogical" (string)
%     dictFile  - Full path to the logical interface dictionary (.sldd) (string)
%     archDir   - Directory in which to save the model file (string)

    slxFile = fullfile(archDir, char(modelName) + ".slx");

    if bdIsLoaded(modelName), close_system(modelName, 0); end
    Simulink.data.dictionary.closeAll("-discard");
    if isfile(dictFile), delete(dictFile); end
    if isfile(slxFile),  delete(slxFile);  end

    addpath(archDir);
    dict = systemcomposer.createDictionary(dictFile);

    % Logical interfaces — more concrete than functional (typed signals with
    % semantic fields), but design-agnostic (no hardware specs or datasheet values)
    controlSignalIface = addInterface(dict, "ControlSignal");
    addElement(controlSignalIface, "Value", Type="double");
    % ... more interfaces ...
    dict.save();

    % Re-fetch after save (required before use in setInterface)
    controlSignalIface = dict.getInterface("ControlSignal");

    model = systemcomposer.createModel(modelName);
    arch  = model.Architecture;
    linkDictionary(model, strrep(dictFile, '\', '/'));

    % Logical components are solution principles — nouns describing what kind
    % of element solves the function, not what specific hardware implements it.
    % Examples: SensingUnit, ControlUnit, ActuationUnit, PowerConverter
    sensingUnit = addComponent(arch, "SensingUnit");
    addTypedPort(sensingUnit.Architecture, "SignalOut", "out", controlSignalIface);
    % ... more components, ports, connections ...

    Simulink.BlockDiagram.arrangeSystem(modelName);
    save_system(char(modelName), char(fullfile(archDir, modelName)));
    open_system(char(modelName));
end

% ── Helpers ──────────────────────────────────────────────────────────────────

function addTypedPort(compArch, name, direction, iface)
    port = addPort(compArch, name, direction);
    port.setInterface(iface);
end
