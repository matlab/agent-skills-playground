function myRollupAnalysis(instance, varargin)
% Analysis function template for the canonical System Composer roll-up pattern.
% Save this file under the project's `analysis/` folder (not `scripts/`) — it
% is an analysis artifact, not a build step. The project path includes
% `analysis/`, so the driver resolves the function by name.
%
% Invoke from the driver with:
%     iterate(instance, 'PostOrder', @myRollupAnalysis);
%
% PostOrder visits children before parents, so by the time this function runs
% on a parent, every child already has its aggregated value set.
%
% Each block follows the same shape: guard on (isComponent + non-empty
% Components + hasValue), loop children with hasValue guard, setValue at the
% end. The only thing that changes across blocks is the aggregation operator.
% Replace 'MyProfile.Stereotype.*' with your actual profile/stereotype paths.

% --- SUM aggregation (mass, power, cost, volume, …) -------------------------
if instance.isComponent() && ~isempty(instance.Components)...
 && instance.hasValue('MyProfile.Stereotype.mass')
    total = 0;
    for child = instance.Components
        if child.hasValue('MyProfile.Stereotype.mass')
           v = child.getValue('MyProfile.Stereotype.mass');
           total = total + v;
        end
    end
    instance.setValue('MyProfile.Stereotype.mass', total);
end

% --- MIN aggregation, excluding zeros (throughput bottleneck) ---------------
% Zero-throughput children (controllers, sensors) would otherwise short-circuit
% the min; exclude them so the result reflects producing stages only.
if instance.isComponent() && ~isempty(instance.Components)...
 && instance.hasValue('MyProfile.Stereotype.throughput')
    bottleneck = inf;
    for child = instance.Components
        if child.hasValue('MyProfile.Stereotype.throughput')
           v = child.getValue('MyProfile.Stereotype.throughput');
           if v > 0 && v < bottleneck, bottleneck = v; end
        end
    end
    if isfinite(bottleneck)
        instance.setValue('MyProfile.Stereotype.throughput', bottleneck);
    end
end

% --- MEAN aggregation (automation level, utilization, efficiency) -----------
if instance.isComponent() && ~isempty(instance.Components)...
 && instance.hasValue('MyProfile.Stereotype.automationLevel')
    vals = [];
    for child = instance.Components
        if child.hasValue('MyProfile.Stereotype.automationLevel')
           vals(end+1) = child.getValue('MyProfile.Stereotype.automationLevel'); %#ok<AGROW>
        end
    end
    if ~isempty(vals)
        instance.setValue('MyProfile.Stereotype.automationLevel', mean(vals));
    end
end
end
