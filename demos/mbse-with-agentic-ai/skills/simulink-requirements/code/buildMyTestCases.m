function buildMyTestCases(srFile, tcFile)
% BUILDMYTESTCASES Create test case requirements linked to system requirements.
%   Loads the system requirements set and recreates the test case set and its
%   paired .slmx link file on every run (idempotent).
%
%   Inputs:
%     srFile - Full path to the System Requirements file (.slreqx) (string)
%     tcFile - Full path to the Test Cases file (.slreqx) to create (string)

    tcLink = strrep(tcFile, '.slreqx', '~slreqx.slmx');

    slreq.clear();
    srSet = slreq.load(srFile);   % slreq.load() for scripts; slreq.open() opens the UI
    if isfile(tcFile), delete(tcFile); end
    if isfile(tcLink), delete(tcLink); end
    tcSet = slreq.new(tcFile);

    % { TC-ID, Summary, Description, SR-ID }
    testCases = {
        'TC-SYS-001', 'Verify SR-001', ...
            'Apply stimulus X. Measure Y. Pass if Y meets criterion Z.', ...
            'SR-SYS-001';
    };

    for i = 1:size(testCases, 1)
        tc             = tcSet.add();
        tc.Id          = testCases{i, 1};
        tc.Summary     = testCases{i, 2};
        tc.Description = testCases{i, 3};
        tc.Rationale   = ['Verifies ', testCases{i, 4}];
        sr             = srSet.find('Id', testCases{i, 4});
        lnk            = slreq.createLink(tc, sr);
        lnk.Type       = 'Verify';
    end
    slreq.saveAll();
end
