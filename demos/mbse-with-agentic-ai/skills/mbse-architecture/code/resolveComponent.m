function comp = resolveComponent(arch, path)
% RESOLVECOMPONENT Look up a component by a slash-delimited path.
%   Walks into sub-architectures for nested components (e.g. a composite
%   functional component containing sub-functions). Use this when the same
%   script needs to address both top-level and nested components uniformly,
%   for example in allocation tables.
%
%   Examples:
%     resolveComponent(arch, 'StoreIngredients')                         % top-level
%     resolveComponent(arch, 'CoordinateOperations/SequenceProduction')  % nested
%     resolveComponent(arch, 'A/B/C')                                    % 3 levels
%
%   Inputs:
%     arch - architecture to search (model.Architecture for the top level)
%     path - char/string, '/'-delimited component path
%
%   Output:
%     comp - the resolved component (errors with getComponent's message if
%            any segment does not exist)

    parts = strsplit(char(path), '/');
    comp  = arch.getComponent(parts{1});
    for k = 2:numel(parts)
        comp = comp.Architecture.getComponent(parts{k});
    end
end
