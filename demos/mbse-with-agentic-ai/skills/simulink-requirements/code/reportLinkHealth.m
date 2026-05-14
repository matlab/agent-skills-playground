function reportLinkHealth()
% REPORTLINKHEALTH Report broken and orphan links across all loaded LinkSets.
%   Prints broken and orphan links for every loaded LinkSet that has at least
%   one issue. Silently passes when all LinkSets are healthy.
%
%   Call loadProjectRequirements(projRoot) first to ensure all .slmx files are loaded.

    allLS = slreq.find('type', 'LinkSet');
    for i = 1:numel(allLS)
        ls = allLS(i);
        [broken, ~] = ls.getBrokenLinks();
        orphans     = ls.getOrphanLinks();
        if isempty(broken) && isempty(orphans); continue; end
        [~, fname] = fileparts(ls.Filename);
        fprintf('\n%s:\n', fname);
        for j = 1:numel(broken)
            fprintf('  BROKEN  Src="%s" -> Dst="%s"\n', ...
                broken(j).getSourceLabel(), broken(j).getDestinationLabel());
        end
        fprintf('  %d orphan links\n', numel(orphans));
    end
end
