function runMyAnalysis()
% Driver template for a System Composer roll-up analysis.
%
%   1. Read system-level caps from requirements (not hard-coded)
%   2. Instantiate the architecture against the profile
%   3. Run the analysis function via iterate(..., 'PostOrder', @fn) so every
%      parent in the hierarchy gets aggregated values (visible in the Viewer)
%   4. Read rolled-up totals off the top-level instance
%   5. Report margins and save for the Analysis Viewer
%
% Convention: the analysis function file (`myRollupAnalysis.m`) lives in the
% project's `analysis/` folder, NOT `scripts/`. It's an analysis artifact, not
% a build step. The project path includes `analysis/`, so the function resolves
% by name. This driver registers it with the project alongside the .mat output.

    proj        = currentProject();
    reqDir      = fullfile(proj.RootFolder, 'requirements');
    archDir     = fullfile(proj.RootFolder, 'architecture');
    analysisDir = fullfile(proj.RootFolder, 'analysis');
    profileName = 'MyProfile';
    modelName   = 'MySystem';
    prefix      = [profileName, '.Stereotype.'];

    % --- Read caps from requirements ---------------------------------------
    slreq.clear();
    srSet     = slreq.open(fullfile(reqDir, 'SystemRequirements.slreqx'));
    capMass   = parseBudgetValue(srSet, 'SR-SYS-010', 'kg');
    capPower  = parseBudgetValue(srSet, 'SR-SYS-011', 'W');

    % --- Instantiate and iterate -------------------------------------------
    addpath(archDir);
    model    = systemcomposer.openModel(modelName);
    arch     = model.Architecture;
    instance = instantiate(arch, profileName, 'MyAnalysis');

    iterate(instance, 'PostOrder', @myRollupAnalysis);

    % --- Read top-level aggregated values ----------------------------------
    totMass  = sumTop(instance.Components, [prefix, 'mass']);
    totPower = sumTop(instance.Components, [prefix, 'power']);

    % --- Report -------------------------------------------------------------
    report = { ...
        'Mass (kg)',  totMass,  capMass,  capMass  - totMass,  totMass  <= capMass; ...
        'Power (W)',  totPower, capPower, capPower - totPower, totPower <= capPower; ...
    };
    fprintf('\n%-20s %12s %12s %12s %8s\n', 'Metric','Value','Cap','Margin','OK');
    fprintf('%s\n', repmat('-', 1, 70));
    for i = 1:size(report,1)
        fprintf('%-20s %12.2f %12.2f %12.2f %8s\n', report{i,1:4}, ...
            ternary(report{i,5}, 'PASS', 'FAIL'));
    end

    % --- Save for the Analysis Viewer --------------------------------------
    save(instance, fullfile(analysisDir, 'MyAnalysis.mat'));
    % Open the Analysis Viewer with the LIVE (post-iterate) instance.
    % R2025b requires an instance object; the name-string form
    % openViewer('MyAnalysis') does NOT work — "A name is expected" error.
    systemcomposer.analysis.openViewer('Source', instance);
    fprintf('\nSaved: analysis/MyAnalysis.mat  (viewer opened with live instance)\n');

    % Register both the analysis output and the analysis function file with
    % the project. The function file lives in analysis/, not scripts/.
    if ~isempty(matlab.project.currentProject)
        registerWithProject({ ...
            fullfile(analysisDir, 'MyAnalysis.mat'), ...
            fullfile(analysisDir, 'myRollupAnalysis.m'), ...
        });
    end
end

function s = sumTop(comps, prop)
    s = 0;
    for i = 1:numel(comps)
        s = s + comps(i).getValue(prop);
    end
end

function value = parseBudgetValue(srSet, reqId, unit)
% Extract numeric cap from a "shall not exceed ..." requirement description.
% Accepts both unit orderings: "not exceed X <unit>" (35 kg) and
% "not exceed <unit> X" (USD 1000) — the latter is common when the unit is a
% currency symbol or ISO code that conventionally precedes the number.
    req  = srSet.find('Id', reqId);
    desc = req.Description;
    tok = regexp(desc, ['not exceed\s+([\d.]+)\s+', unit], 'tokens', 'once');
    if isempty(tok)
        tok = regexp(desc, ['not exceed\s+', unit, '\s+([\d.]+)'], 'tokens', 'once');
    end
    if isempty(tok)
        error('parseBudgetValue:noMatch', 'Cannot parse %s from %s.', unit, reqId);
    end
    value = str2double(tok{1});
end

function value = parseMinValue(srSet, reqId, unit)
% Extract numeric floor from a "shall provide >= X <unit>", "at least X <unit>",
% or "support[s] X <unit>" requirement description. Tolerates HTML-encoded
% ">=" (stored as "&gt;=" in the .Description HTML payload). Falls back to the
% first "<number> <unit>" occurrence anywhere in the description — lenient so
% simple shall-statements parse without ceremony.
    req  = srSet.find('Id', reqId);
    desc = req.Description;
    patterns = {
        ['(?:&gt;=|>=|at least|support[s]?)\s*([\d.]+)\s+', unit]
        ['([\d.]+)\s+', unit]
    };
    tok = [];
    for i = 1:numel(patterns)
        tok = regexp(desc, patterns{i}, 'tokens', 'once');
        if ~isempty(tok), break; end
    end
    if isempty(tok)
        error('parseMinValue:noMatch', 'Cannot parse %s from %s.', unit, reqId);
    end
    value = str2double(tok{1});
end

function s = ternary(cond, a, b)
    if cond, s = a; else, s = b; end
end
