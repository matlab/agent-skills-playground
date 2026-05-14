function buildMyViews(modelName, profilePrefix, viewSpecs)
% BUILDMYVIEWS Create stereotype-query architecture views on an SC model.
%   Views are filtered lenses on a large architecture — components matching
%   a query over stereotype properties. Useful for review dashboards (cost
%   drivers, high-power components, throughput contributors) and for
%   anything else where you want to answer "which components satisfy X?"
%
%   Idempotent: deletes any existing view with the same name before
%   recreating. Run this AFTER buildXxx.m rebuilds the model — a rebuild
%   wipes previously-created views along with everything else.
%
%   Inputs:
%     modelName      - Name of the SC model to add views to (string)
%     profilePrefix  - Stereotype property path prefix, e.g.
%                      'MyProfile.ComponentProperties.'
%                      (MUST end with a '.')
%     viewSpecs      - N-by-4 cell array of view definitions, each row:
%                        {name, propertyName, op, value, color}
%                      where propertyName is relative to profilePrefix,
%                      op is one of 'gt'|'lt'|'ge'|'le'|'eq'|'ne', and
%                      color is a hex string (e.g. '#D62728'). Named colors
%                      like 'red' / 'blue' work, but only a subset — 'magenta'
%                      fails — so prefer hex. The color column is optional;
%                      default is '#1F77B4' (blue).
%
%   Example:
%     buildMyViews('MySystem', 'MyProfile.ComponentProperties.', {
%         'CostDrivers',      'Cost_credits', 'gt',  150000, 'red';
%         'HighPowerConsumers','Power_kW',     'gt',  20,     'orange';
%         'StructuralMass',   'Mass_kg',      'gt',  1000,   'yellow';
%         'ZeroCost_Flag',    'Cost_credits', 'eq',  0,      'magenta';
%         'ProductionPipeline','Throughput',  'gt',  0,      'green';
%     });
%
%   Views appear in the Views Gallery (openViews(model)) and as a dropdown
%   in the System Composer model canvas.
%
%   For allocation-driven or hand-picked views (no single-property query
%   fits), omit Select and use v.Root.addElement(comp) for each member
%   component. See the 'Explicit element views' note in the skill doc.

    arguments
        modelName     (1,1) string
        profilePrefix (1,1) string
        viewSpecs     cell
    end

    assert(endsWith(profilePrefix, '.'), ...
        'profilePrefix must end with a ''.'' (e.g. ''MyProfile.Stereotype.'')');

    import systemcomposer.query.*;

    model = systemcomposer.openModel(modelName);

    nCreated = 0;
    for i = 1:size(viewSpecs, 1)
        name  = viewSpecs{i, 1};
        prop  = viewSpecs{i, 2};
        op    = viewSpecs{i, 3};
        value = viewSpecs{i, 4};
        color = '#1F77B4';
        if size(viewSpecs, 2) >= 5 && ~isempty(viewSpecs{i, 5})
            color = viewSpecs{i, 5};
        end

        % Idempotent — drop any existing view with the same name first
        try, deleteView(model, name); end %#ok<TRYNC>

        fullProp = char(profilePrefix) + string(prop);
        pv       = PropertyValue(fullProp);
        switch lower(op)
            case 'gt', q = pv >  value;
            case 'lt', q = pv <  value;
            case 'ge', q = pv >= value;
            case 'le', q = pv <= value;
            case 'eq', q = pv == value;
            case 'ne', q = pv ~= value;
            otherwise, error('buildMyViews:badOp', 'Unknown op: %s', op);
        end

        v = createView(model, name, Select=q, Color=color);
        n = numel(find(model, q));
        fprintf('  %-28s %s %s %g  ->  %d match(es)\n', ...
                name, prop, op, value, n);
        nCreated = nCreated + 1;
    end

    save_system(modelName);
    fprintf('Created %d view(s) on %s.\n', nCreated, modelName);
end
