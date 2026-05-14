function buildMySystemModel(modelName, dictFile, archDir)
% BUILDMYSYSTEMMODEL Create a System Composer architecture model with interface dictionary.
%   Deletes and recreates the model and dictionary on every run (idempotent).
%
%   Inputs:
%     modelName - Name of the System Composer model (string)
%     dictFile  - Path to the interface dictionary file (.sldd) (string)
%     archDir   - Directory in which to save the model file (string)

    %% Interface Dictionary
    if isfile(dictFile)
        Simulink.data.dictionary.closeAll("-discard");
        delete(dictFile);
    end
    dict = systemcomposer.createDictionary(dictFile);

    % Interfaces — use Type="double" for all elements; document units in comments.
    % Do NOT use addValueType for physical quantities — it creates Simulink.ValueType
    % objects the bus compiler cannot resolve, causing "update diagram" to fail.
    thermalIface = addInterface(dict, "ThermalFluid");
    addElement(thermalIface, "Temperature",  Type="double");   % K
    addElement(thermalIface, "MassFlowRate", Type="double");   % kg/s
    % ... add more interfaces here ...

    % CRITICAL: save dictionary before creating model, then re-fetch interfaces
    dict.save();
    thermalIface = dict.getInterface("ThermalFluid");          % re-fetch after save
    % ... re-fetch all interfaces ...

    %% Architecture Model
    if bdIsLoaded(modelName), close_system(modelName, 0); end
    model = systemcomposer.createModel(modelName);
    arch  = model.Architecture;
    linkDictionary(model, dictFile);

    %% Components
    compA = addComponent(arch, "ComponentA");
    compB = addComponent(arch, "ComponentB");

    %% Ports
    addTypedPort(compA.Architecture, "OutPort1", "out", thermalIface);
    addTypedPort(compB.Architecture, "InPort1",  "in",  thermalIface);

    %% Connections — use connect(srcPort, dstPort), NO architecture argument
    connect(compA.getPort("OutPort1"), compB.getPort("InPort1"));

    %% Layout, Save, and Open
    Simulink.BlockDiagram.arrangeSystem(modelName);
    save_system(char(modelName), char(fullfile(archDir, modelName)));
    open_system(char(modelName));
    fprintf("Model created: %s\n", modelName);
end

% ── Helpers ──────────────────────────────────────────────────────────────────

function addTypedPort(compArch, name, direction, iface)
    port = addPort(compArch, name, direction);
    port.setInterface(iface);
end
