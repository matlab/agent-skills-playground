function buildMyRequirements(snFile, srFile)
% BUILDMYREQUIREMENTS Create stakeholder needs and system requirements sets.
%   Deletes and recreates both requirement sets and their paired .slmx link
%   files on every run (idempotent).
%
%   Inputs:
%     snFile - Full path to the Stakeholder Needs file (.slreqx) (string)
%     srFile - Full path to the System Requirements file (.slreqx) (string)

    slreq.clear();
    % Delete files AND their .slmx link files to avoid stale cross-artifact links
    for f = {snFile, srFile, ...
             strrep(snFile, '.slreqx', '~slreqx.slmx'), ...
             strrep(srFile, '.slreqx', '~slreqx.slmx')}
        if isfile(f{1}), delete(f{1}); end
    end

    snSet = slreq.new(snFile);
    sn1 = addReq(snSet, 'SN-SYS-001', 'Title', "The operator shall ...", "Rationale.");
    snSet.save();

    srSet = slreq.new(srFile);
    sr1 = addReq(srSet, 'SR-SYS-001', 'Title', "The system shall ... [criterion].", ...
        "Why this criterion — e.g. 'X picked to cover worst-case load with margin.'");
    srSet.save();

    % Derive link: SN (parent/source) -> SR (derived child/destination).
    lnk = slreq.createLink(sn1, sr1);
    lnk.Type = 'Derive';
    slreq.saveAll();
end

% ── Helpers ──────────────────────────────────────────────────────────────────

function req = addReq(rs, id, summary, description, rationale)
    req             = rs.add();
    req.Id          = id;
    req.Summary     = summary;
    req.Description = description;
    req.Rationale   = rationale;
end
