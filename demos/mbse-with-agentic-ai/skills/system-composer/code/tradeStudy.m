function results = tradeStudy(modelName, profileName, variantCompName, variants, caps, reportPath)
% TRADESTUDY Run a rollup analysis once per variant choice and emit a
%   markdown comparison report. Generic driver suitable as a starting
%   template for project-specific trade studies built on top of System
%   Composer variant components.
%
%   Inputs:
%     modelName       - SC model containing the variant component
%     profileName     - Stereotype profile applied to the model
%     variantCompName - Name of the variant component (top-level, single word)
%     variants        - Nx2 cell array: {choiceName, description}
%     caps            - Struct with fields corresponding to analysis metrics.
%                       Fields of form <Metric>_cap (max) or <Metric>_floor
%                       (min) drive the pass/fail columns. Example:
%                         caps.Cost_cap = 2e6;
%                         caps.Throughput_floor = 200;
%     reportPath      - Full path to the markdown report to generate
%
%   Returns:
%     results - Struct array, one entry per variant, with rollup totals +
%               pass/fail flags per cap/floor.
%
%   Contract with the caller:
%     - An analysis callback `@myProjectRollup` must be on the MATLAB path;
%       this driver does not iterate the instance itself, it delegates to
%       the project's own PostOrder rollup callback (edit below).
%     - The caller supplies a helper `readTopRollup(topComps, prefix)` that
%       returns a struct of metric -> value by reading top-level instance
%       values (sum for additive, min for bottleneck, etc. per project).
%
%   Example caller:
%     results = tradeStudy('MyModel', 'MyProfile', 'CookingLine', ...
%         {'V0_Baseline', 'Serial 50 sph';
%          'V1_Parallel', 'Four parallel at 50 sph';
%          'V2_Large',    'Single larger at 250 sph'}, ...
%         struct('Mass_cap',15000, 'Cost_cap',2e6, 'Throughput_floor',200), ...
%         fullfile(proj.RootFolder,'analysis','TradeStudyReport.md'));

    arguments
        modelName       (1,1) string
        profileName     (1,1) string
        variantCompName (1,1) string
        variants        cell
        caps            struct
        reportPath      (1,1) string
    end

    model = systemcomposer.openModel(char(modelName));
    arch  = model.Architecture;
    vc    = arch.getComponent(char(variantCompName));
    assert(isa(vc,'systemcomposer.arch.VariantComponent'), ...
        'tradeStudy:notVariant', '%s is not a VariantComponent', variantCompName);

    defaultChoice = vc.getActiveChoice().Name;

    results = struct([]);
    for i = 1:size(variants,1)
        vname = variants{i,1};
        vdesc = variants{i,2};

        vc.setActiveChoice(vname);
        inst = instantiate(arch, char(profileName), sprintf('TradeStudy_%s', vname));

        % === Project-specific rollup ============================================
        % Replace with your project's analysis callback. The callback must be
        % on the MATLAB path. See the mbse-architecture skill's analysis
        % reference for the PostOrder + setValue pattern.
        iterate(inst, 'PostOrder', @myProjectRollup);
        metrics = readTopRollup(inst.Components, char(profileName));
        % =======================================================================

        r.Variant     = vname;
        r.Description = vdesc;
        r = mergeStructs(r, metrics);
        r = applyCaps(r, caps);
        if isempty(results), results = r; else, results(end+1) = r; end %#ok<AGROW>
    end

    % Restore default active choice so subsequent single-variant analyses
    % reproduce baseline numbers.
    vc.setActiveChoice(defaultChoice);
    save_system(char(modelName));

    writeReport(char(reportPath), results, caps);
end

% ── Report writer ────────────────────────────────────────────────────────────

function writeReport(path, results, caps)
    fid = fopen(path, 'w'); c = onCleanup(@() fclose(fid));
    fprintf(fid, '# Trade Study Report\n\n');
    fprintf(fid, 'Generated %s\n\n', datestr(now, 'yyyy-mm-dd HH:MM:SS'));

    fprintf(fid, '## Variants\n\n');
    for i = 1:numel(results)
        fprintf(fid, '- **%s** — %s\n', results(i).Variant, results(i).Description);
    end

    % Discover metric fields (anything not in {Variant, Description, Pass_*})
    fields = fieldnames(results);
    metricFields = fields(~startsWith(fields,'Pass_') & ~ismember(fields, {'Variant','Description'}));
    passFields   = fields(startsWith(fields,'Pass_'));

    fprintf(fid, '\n## Comparison\n\n');
    fprintf(fid, '| Variant |');
    for f = metricFields', fprintf(fid, ' %s |', f{1}); end
    fprintf(fid, ' All |\n');
    fprintf(fid, '|---|');
    for f = metricFields', fprintf(fid, '---:|'); end %#ok<NASGU>
    fprintf(fid, ':---:|\n');
    for i = 1:numel(results)
        fprintf(fid, '| `%s` |', results(i).Variant);
        for f = metricFields'
            v = results(i).(f{1});
            if isnumeric(v), fprintf(fid, ' %g |', v); else, fprintf(fid, ' %s |', string(v)); end
        end
        allPass = all(cellfun(@(k) results(i).(k), passFields));
        fprintf(fid, ' %s |\n', passOrFail(allPass));
    end

    fprintf(fid, '\n## Pass / Fail matrix\n\n');
    fprintf(fid, '| Variant |');
    for f = passFields', fprintf(fid, ' %s |', strrep(f{1},'Pass_','')); end
    fprintf(fid, '\n|---|');
    for f = passFields', fprintf(fid, ':---:|'); end %#ok<NASGU>
    fprintf(fid, '\n');
    for i = 1:numel(results)
        fprintf(fid, '| `%s` |', results(i).Variant);
        for f = passFields'
            fprintf(fid, ' %s |', passOrFail(results(i).(f{1})));
        end
        fprintf(fid, '\n');
    end

    fprintf(fid, '\n## Pareto-efficient set\n\n');
    pareto = computePareto(results, caps);
    if isempty(pareto)
        fprintf(fid, '- (none)\n');
    else
        for idx = pareto, fprintf(fid, '- `%s`\n', results(idx).Variant); end
    end
end

function b = passOrFail(v), if v, b='PASS'; else, b='FAIL'; end, end

function r = applyCaps(r, caps)
% Adds Pass_<metric> fields for each cap/floor in the caps struct.
    fs = fieldnames(caps);
    for i = 1:numel(fs)
        f = fs{i};
        if endsWith(f,'_cap')
            metric = extractBefore(f,'_cap');
            if isfield(r, metric), r.(['Pass_', metric]) = r.(metric) <= caps.(f); end
        elseif endsWith(f,'_floor')
            metric = extractBefore(f,'_floor');
            if isfield(r, metric), r.(['Pass_', metric]) = r.(metric) >= caps.(f); end
        end
    end
end

function s = mergeStructs(a, b)
    s = a;
    fs = fieldnames(b);
    for i = 1:numel(fs), s.(fs{i}) = b.(fs{i}); end
end

function idx = computePareto(results, caps)
% Non-dominated set on metrics where _cap means lower-better and _floor means
% higher-better. Ignore any metrics not covered by caps.
    capFields   = fieldnames(caps);
    lowerBetter = cellfun(@(f) endsWith(f,'_cap'),   capFields);
    higherBetter= cellfun(@(f) endsWith(f,'_floor'), capFields);
    lowMetrics  = cellfun(@(f) extractBefore(f,'_cap'),   capFields(lowerBetter),  'UniformOutput',false);
    highMetrics = cellfun(@(f) extractBefore(f,'_floor'), capFields(higherBetter), 'UniformOutput',false);

    n = numel(results); nondom = true(1,n);
    for i = 1:n
        for j = 1:n
            if i==j, continue; end
            if dominates(results(j), results(i), lowMetrics, highMetrics)
                nondom(i) = false; break;
            end
        end
    end
    idx = find(nondom);
end

function b = dominates(a, c, lowM, highM)
    leq = true; strict = false;
    for k = 1:numel(lowM)
        if ~isfield(a, lowM{k}), continue; end
        if a.(lowM{k}) >  c.(lowM{k}), leq = false; break; end
        if a.(lowM{k}) <  c.(lowM{k}), strict = true; end
    end
    geq = true;
    if leq
        for k = 1:numel(highM)
            if ~isfield(a, highM{k}), continue; end
            if a.(highM{k}) <  c.(highM{k}), geq = false; break; end
            if a.(highM{k}) >  c.(highM{k}), strict = true; end
        end
    end
    b = leq && geq && strict;
end
