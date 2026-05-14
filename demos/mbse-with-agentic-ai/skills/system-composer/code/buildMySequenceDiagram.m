function buildMySequenceDiagram(modelName, archDir)
% BUILDMYSEQUENCEDIAGRAM Template for a System Composer sequence diagram.
%   Demonstrates the canonical programmatic build sequence:
%     - make an Interaction on the model
%     - add Lifelines bound to existing components
%     - add Messages on RootFragment.Operands(1), naming real ports
%     - add an Alt fragment with guarded operands and messages inside each
%     - add a DurationConstraint between two messages
%     - idempotent rebuild via destroy-before-recreate
%
%   Reference: the Sequence Diagrams section in the system-composer SKILL.
%
%   Inputs:
%     modelName - SC model to attach the interaction to (string)
%     archDir   - folder to save the .slx into (string)
%
%   This template builds a small self-contained model with two components
%   wired together, then attaches a scenario. Adapt by pointing at an
%   existing model via systemcomposer.openModel() and replacing the
%   sample lifelines and messages.

    slxFile = fullfile(archDir, char(modelName) + ".slx");
    if bdIsLoaded(char(modelName)), close_system(char(modelName), 0); end
    if isfile(slxFile), delete(slxFile); end

    % ── 1. Minimal model with two wired components ──────────────────────────
    model = systemcomposer.createModel(char(modelName));
    arch  = model.Architecture;

    client = addComponent(arch, 'Client');
    server = addComponent(arch, 'Server');
    addPort(client.Architecture, 'Request',  'out');
    addPort(client.Architecture, 'Response', 'in');
    addPort(server.Architecture, 'Request',  'in');
    addPort(server.Architecture, 'Response', 'out');
    connect(client.getPort('Request'),  server.getPort('Request'));
    connect(server.getPort('Response'), client.getPort('Response'));

    % ── 2. Idempotent rebuild of the interaction ────────────────────────────
    ixnName = 'RequestReply';
    destroyInteractionIfPresent(model, ixnName);
    diagram = model.addInteraction(ixnName);

    % ── 3. Lifelines -- path OR Component object both accepted ──────────────
    clientLL = diagram.addLifeline([char(modelName), '/Client']);
    serverLL = diagram.addLifeline([char(modelName), '/Server']);

    % ── 4. Straight-line messages on the root operand ───────────────────────
    % addMessage(srcLifeline, srcPortName, dstLifeline, dstPortName, guard)
    % srcPortName/dstPortName MUST match existing ports on the components
    % underlying the lifelines; otherwise SC throws "Name must match a port
    % on the component corresponding to the lifeline".
    op = diagram.RootFragment.Operands(1);
    m1 = op.addMessage(clientLL, 'Request',  serverLL, 'Request',  'send');
    m2 = op.addMessage(serverLL, 'Response', clientLL, 'Response', 'ack');

    % ── 5. Alt fragment with two guarded operands ───────────────────────────
    % addFragment('Alt'|'Loop'|'Opt'|'Par'); Alt has two operands out of the
    % box. Messages inside a fragment go on the fragment's operand(s), NOT
    % on the fragment itself (fragments have no addMessage).
    altFrag = op.addFragment('Alt');
    branch1 = altFrag.Operands(1);
    branch2 = altFrag.Operands(2);
    branch1.Guard = 'Response.Status == OK';
    branch2.Guard = 'Response.Status == FAIL';
    branch1.addMessage(clientLL, 'Request', serverLL, 'Request', 'followUp');
    branch2.addMessage(clientLL, 'Request', serverLL, 'Request', 'retry');

    % ── 6. Duration constraint between two message events ──────────────────
    % MessageEvent refs: message.Start / message.End
    diagram.addDurationConstraint(m1.End, m2.End, 't < 100ms');

    % ── 7. Persist inside the model .slx; open for view ────────────────────
    save_system(char(modelName), char(slxFile));
    open(diagram);

    fprintf("Sequence diagram '%s' built on %s:\n", ixnName, modelName);
    fprintf("  Lifelines: %d\n", numel(diagram.Lifelines));
    fprintf("  Root messages: 2 + Alt fragment with 2 guarded branches\n");
end

function destroyInteractionIfPresent(model, name)
% model.addInteraction(name) errors on duplicate name; walk the existing
% interactions and destroy the matching one first. Idempotent rebuild
% pattern -- match the style of delete-and-recreate used for .slreqx
% and .mldatx build scripts.
    try, ixns = model.getInteractions(); catch, ixns = []; end
    for i = 1:numel(ixns)
        if strcmp(ixns(i).Name, name), ixns(i).destroy(); return; end
    end
end
