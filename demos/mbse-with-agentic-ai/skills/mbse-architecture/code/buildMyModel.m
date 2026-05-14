function buildMyModel(modelName, dictFile, archDir)
% BUILDMYMODEL Create a System Composer physical architecture model.
%   Deletes and recreates the physical interface dictionary and model on
%   every run (idempotent). Build this after the functional model.
%   Add stereotype profile creation and application at the end of this
%   function — see the Stereotype Properties section of the skill guide.
%
%   Inputs:
%     modelName - Name of the physical SC model, e.g. "MySystem" (string)
%     dictFile  - Full path to the physical interface dictionary (.sldd) (string)
%     archDir   - Directory in which to save the model file (string)

    slxFile = fullfile(archDir, char(modelName) + ".slx");

    if bdIsLoaded(modelName), close_system(modelName, 0); end
    Simulink.data.dictionary.closeAll("-discard");
    if isfile(dictFile), delete(dictFile); end
    if isfile(slxFile),  delete(slxFile);  end

    addpath(archDir);
    dict = systemcomposer.createDictionary(dictFile);

    % Add physical interfaces — concrete types, specific fields, physical units
    myPhysIface = addInterface(dict, "MyPhysicalSignal");
    addElement(myPhysIface, "Voltage", Type="double");   % V
    addElement(myPhysIface, "Current", Type="double");   % A
    % ... more interfaces ...
    dict.save();

    myPhysIface = dict.getInterface("MyPhysicalSignal");

    model = systemcomposer.createModel(modelName);
    arch  = model.Architecture;
    linkDictionary(model, strrep(dictFile, '\', '/'));

    compA = addComponent(arch, "ComponentA");
    addTypedPort(compA.Architecture, "PowerIn", "in", myPhysIface);
    % ... more components, ports, connections, then profile ...

    Simulink.BlockDiagram.arrangeSystem(modelName);
    save_system(char(modelName), char(fullfile(archDir, modelName)));
    open_system(char(modelName));
end

% ── Helpers ──────────────────────────────────────────────────────────────────

function addTypedPort(compArch, name, direction, iface)
    port = addPort(compArch, name, direction);
    port.setInterface(iface);
end
