function context = analizeRequirements(modelName, reqFilePath)
%ANALIZEREQUIREMENTS Extract requirements, model signals, bus definitions, and enums
%   for use with the simulink-test-sequence-from-ears skill (Phase 1).
%
%   CONTEXT = analizeRequirements(MODELNAME, REQFILEPATH)
%
%   Inputs:
%     modelName   - Simulink model name (without .slx extension)
%     reqFilePath - Path to the .slreqx requirements file
%
%   Outputs:
%     context     - Struct with requirements, interfaces, buses, enums,
%                   and Stateflow transition context
%
%   Side effects printed to console:
%     - Requirements with EARS pattern classification
%     - Model I/O ports with data types
%     - Bus definitions (from .sldd files in current directory)
%     - Enumeration types (from .m files in current directory)

    context = collectSkillContext(modelName, reqFilePath);

    fprintf('\n=== REQUIREMENTS ANALYSIS ===\n\n');
    for i = 1:numel(context.requirements)
        req = context.requirements(i);
        fprintf('Requirement ID: %s\n  Title: %s\n  Description: %s\n  EARS Pattern: %s\n', ...
            req.id, req.summary, req.description, req.pattern);
        if strlength(req.trigger) > 0
            fprintf('  Trigger: "%s"\n', req.trigger);
        end
        if strlength(req.behavior) > 0
            fprintf('  Behavior: "%s"\n', req.behavior);
        end
        fprintf('\n');
    end

    fprintf('\n=== MODEL I/O SIGNALS ===\n');
    fprintf('INPUTS:\n');
    for i = 1:numel(context.interfaces.inputs)
        fprintf('  %s (%s)\n', ...
            context.interfaces.inputs(i).name, context.interfaces.inputs(i).data_type);
    end
    fprintf('OUTPUTS:\n');
    for i = 1:numel(context.interfaces.outputs)
        fprintf('  %s (%s)\n', ...
            context.interfaces.outputs(i).name, context.interfaces.outputs(i).data_type);
    end

    fprintf('\n=== BUS DEFINITIONS ===\n');
    for i = 1:numel(context.buses)
        fprintf('\nBus: %s\n', context.buses(i).name);
        for j = 1:numel(context.buses(i).elements)
            fprintf('  .%s (%s)\n', context.buses(i).elements(j).name, ...
                context.buses(i).elements(j).data_type);
        end
    end

    fprintf('\n=== ENUMERATION TYPES ===\n');
    for i = 1:numel(context.enums)
        fprintf('%s: ', context.enums(i).name);
        for j = 1:numel(context.enums(i).members)
            fprintf('%s(%d) ', context.enums(i).members(j).name, context.enums(i).members(j).value);
        end
        fprintf('\n');
    end

    fprintf('\n=== STATEFLOW TRANSITIONS ===\n');
    for i = 1:numel(context.stateflow.charts)
        fprintf('Chart: %s\n', context.stateflow.charts(i).path);
        for j = 1:numel(context.stateflow.charts(i).transitions)
            tr = context.stateflow.charts(i).transitions(j);
            fprintf('  %s -> %s : %s\n', tr.source_state, tr.destination_state, tr.condition);
        end
    end
end
