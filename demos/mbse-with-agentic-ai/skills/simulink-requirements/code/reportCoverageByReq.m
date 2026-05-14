function reportCoverageByReq(rs)
% REPORTCOVERAGEBYREQ Print implementation and verification status per requirement.
%   Prints a table showing whether each requirement in rs has at least one
%   Implement inLink and at least one Verify inLink.
%
%   Input:
%     rs - slreq.ReqSet to report on

    reqs = rs.find('Type', 'Requirement');
    fprintf('%-30s  %-10s  %-8s\n', 'Req ID', 'Impl', 'Verify');
    fprintf('%s\n', repmat('-', 1, 55));
    for i = 1:numel(reqs)
        r         = reqs(i);
        hasImpl   = false;
        hasVerify = false;
        in_ = r.inLinks();
        for k = 1:numel(in_)
            if strcmp(in_(k).Type, 'Implement'); hasImpl   = true; end
            if strcmp(in_(k).Type, 'Verify');    hasVerify = true; end
        end
        fprintf('%-30s  %-10s  %-8s\n', r.Id, tf2str(hasImpl), tf2str(hasVerify));
    end
end

% ── Helpers ──────────────────────────────────────────────────────────────────

function s = tf2str(cond)
    if cond; s = 'YES'; else; s = 'no'; end
end
