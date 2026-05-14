function buildAllocation(reqDir, archDir)
% BUILDALLOCATION Create Implement links from architecture elements to system requirements.
%   slreq Implement links go from the implementer (architecture element, source) to
%   the requirement implemented (destination). Three sets are created (idempotent):
%     Function  -> SR:  mandatory — every SR must have at least one Function implementer
%     Logical   -> SR:  for non-functional requirements (timing, performance,
%                       safety, security) or requirements specific to a logical role
%     Physical  -> SR:  for hardware-specific, environmental, EMC, or
%                       packaging/installation requirements
%   Removes all existing Implement links before recreating.
%
%   Inputs:
%     reqDir  - Directory containing SystemRequirements.slreqx (string)
%     archDir - Directory containing the SC models (string)

    slreq.clear();
    srSet = slreq.load(fullfile(reqDir, 'SystemRequirements.slreqx'));
    addpath(archDir);
    funcModel = systemcomposer.openModel('MyFunctional');
    funcArch  = funcModel.Architecture;
    logModel  = systemcomposer.openModel('MyLogical');
    logArch   = logModel.Architecture;
    physModel = systemcomposer.openModel('MySystem');
    physArch  = physModel.Architecture;

    % Remove existing Implement links (idempotent). Implement links go from the
    % architecture element (source) to the requirement (destination), so from a
    % requirement's perspective they are inLinks.
    allReqs = srSet.find('Type', 'Requirement');
    for i = 1:numel(allReqs)
        lnks = allReqs(i).inLinks();   % method on the object — NOT slreq.inLinks(req)
        for j = 1:numel(lnks)
            if strcmp(lnks(j).Type, 'Implement'), lnks(j).remove(); end
        end
    end

    % Function -> SR Implement links (mandatory — every SR must have at least one Function implementer)
    % { SR-ID, { function component names... } }
    funcAllocation = {
        'SR-SYS-001', { 'FunctionA', 'FunctionB' };
        'SR-SYS-002', { 'FunctionA'               };
    };

    for i = 1:size(funcAllocation, 1)
        req = srSet.find('Id', funcAllocation{i, 1});
        for j = 1:numel(funcAllocation{i, 2})
            func     = funcArch.getComponent(funcAllocation{i, 2}{j});
            lnk      = slreq.createLink(func, req);
            lnk.Type = 'Implement';
        end
    end

    % Logical -> SR Implement links
    % Use for: non-functional requirements (timing, performance, safety, security),
    %          requirements specific to a logical solution role
    % { SR-ID, { logical component names... } }
    logAllocation = {
        'SR-SYS-001', { 'SensingUnit'  };
        'SR-SYS-003', { 'ControlUnit'  };
    };

    for i = 1:size(logAllocation, 1)
        req = srSet.find('Id', logAllocation{i, 1});
        for j = 1:numel(logAllocation{i, 2})
            comp     = logArch.getComponent(logAllocation{i, 2}{j});
            lnk      = slreq.createLink(comp, req);
            lnk.Type = 'Implement';
        end
    end

    % Physical -> SR Implement links
    % Use for: hardware-specific requirements, environmental constraints,
    %          EMC, packaging, and installation requirements
    % { SR-ID, { physical component names... } }
    physAllocation = {
        'SR-SYS-002', { 'ComponentA', 'ComponentB' };
        'SR-SYS-004', { 'ComponentA'               };
    };

    for i = 1:size(physAllocation, 1)
        req = srSet.find('Id', physAllocation{i, 1});
        for j = 1:numel(physAllocation{i, 2})
            comp     = physArch.getComponent(physAllocation{i, 2}{j});
            lnk      = slreq.createLink(comp, req);
            lnk.Type = 'Implement';
        end
    end

    slreq.saveAll();

    % Register the link-store files slreq created next to each model. These
    % `{modelName}~mdl.slmx` files store the requirement links into the model
    % and are created automatically the first time a link is added. They must
    % be tracked by the project alongside the .slx, or project checks will
    % fail and traceability won't travel with the project.
    if ~isempty(matlab.project.currentProject)
        registerWithProject({ ...
            fullfile(archDir, 'MyFunctional~mdl.slmx'), ...
            fullfile(archDir, 'MyLogical~mdl.slmx'), ...
            fullfile(archDir, 'MySystem~mdl.slmx'), ...
        });
    end
end
