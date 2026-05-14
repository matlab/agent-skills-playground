function reportCoverageAggregate(projRoot)
% REPORTCOVERAGEAGGREGATE Print link coverage summary across all ReqSets in a project.
%   Loads all requirement and link files under projRoot, then prints a per-ReqSet
%   table of Derive, Implement, and Verify link counts.
%
%   Input:
%     projRoot - Root directory of the project (string)

    loadProjectRequirements(projRoot);

    allRS = slreq.find('type', 'ReqSet');
    fprintf('%-35s  %5s  %7s  %5s  %6s\n', 'ReqSet', 'Reqs', 'Derive', 'Impl', 'Verify');
    fprintf('%s\n', repmat('-', 1, 70));
    for i = 1:numel(allRS)
        rs_i = allRS(i);
        reqs = rs_i.find('Type', 'Requirement');
        nD = 0; nI = 0; nV = 0;
        for j = 1:numel(reqs)
            r   = reqs(j);
            out = r.outLinks();
            for k = 1:numel(out)
                switch out(k).Type
                    case 'Derive';    nD = nD + 1;
                    case 'Implement'; nI = nI + 1;
                    case 'Verify';    nV = nV + 1;
                end
            end
            in_ = r.inLinks();
            for k = 1:numel(in_)
                switch in_(k).Type
                    case 'Derive';    nD = nD + 1;
                    case 'Implement'; nI = nI + 1;
                    case 'Verify';    nV = nV + 1;
                end
            end
        end
        fprintf('%-35s  %5d  %7d  %5d  %6d\n', rs_i.Name, numel(reqs), nD, nI, nV);
    end
end
