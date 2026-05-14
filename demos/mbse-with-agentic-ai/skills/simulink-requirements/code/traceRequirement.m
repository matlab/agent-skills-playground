function traceRequirement(rs, reqId)
% TRACEREQUIREMENT Print the full traceability chain for a single requirement.
%   Prints all outbound links (derives from / traces to) and inbound links
%   (implemented / verified / derived by) for the given requirement ID.
%
%   Inputs:
%     rs    - slreq.ReqSet containing the requirement (slreq.ReqSet)
%     reqId - Requirement ID string, e.g. 'SR-SYS-001' (string)

    r = rs.find('Id', reqId);
    if isempty(r)
        fprintf('Requirement "%s" not found.\n', reqId);
        return;
    end
    fprintf('=== %s: %s ===\n', r.Id, r.getDescriptionAsText());

    out = r.outLinks();
    if ~isempty(out)
        fprintf('\nDerives from / traces to:\n');
        for k = 1:numel(out)
            lnk = out(k);
            ref = lnk.getReferenceInfo();
            fprintf('  [%s] -> "%s"', lnk.Type, lnk.getDestinationLabel());
            if isstruct(ref)
                fprintf(' (artifact: %s, id: %s)', ref.artifact, ref.id);
            end
            fprintf('\n');
        end
    end

    in_ = r.inLinks();
    if ~isempty(in_)
        fprintf('\nImplemented / verified / derived by:\n');
        for k = 1:numel(in_)
            lnk = in_(k);
            src = lnk.source();
            fprintf('  [%s] <- "%s"', lnk.Type, lnk.getSourceLabel());
            if isstruct(src)
                fprintf(' (domain: %s)', src.domain);
            end
            fprintf('\n');
        end
    end
end
