function compileHarnessModel(harnessName)
%COMPILEHARNESSMODEL Update a harness model to ensure it compiles.
%   compileHarnessModel(HARNESSNAME) loads the harness and runs an update
%   diagram compile check without simulating it.

    load_system(harnessName);
    set_param(harnessName, 'SimulationCommand', 'update');
end
