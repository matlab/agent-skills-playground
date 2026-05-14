function buildMyVariantComposite(modelName, wrapperName, archDir)
% BUILDMYVARIANTCOMPOSITE Template for a System Composer variant component.
%   Demonstrates the canonical build sequence for converting a composite
%   into a variant wrapper with multiple architectural alternatives. Wire
%   the wrapper from the outer architecture as if it were a regular
%   composite; under the hood, only the active choice's sub-structure is
%   visible to `instantiate` at analysis time.
%
%   Reference the skill doc's "Variant Components" section for the list of
%   gotchas this template encodes. The short version:
%     - After makeVariant the original Component ref is STALE; re-fetch.
%     - Rename choice AND call setCondition to keep them in sync.
%     - applyStereotype on the wrapper errors -- apply on each choice.
%     - Numeric stereotype properties propagate choice -> wrapper instance;
%       STRING properties do not (encode variant flags as numbers).
%
%   Inputs:
%     modelName   - Name of the SC model (string)
%     wrapperName - Name of the variant component to create (string)
%     archDir     - Folder to save the .slx and profile .xml (string)

    slxFile     = fullfile(archDir, char(modelName) + ".slx");
    profileName = "MyVariantProfile";
    profileFile = fullfile(archDir, char(profileName) + ".xml");

    if bdIsLoaded(char(modelName)), close_system(char(modelName), 0); end
    systemcomposer.profile.Profile.closeAll();
    if isfile(slxFile),     delete(slxFile);     end
    if isfile(profileFile), delete(profileFile); end

    % ── 1. Model + baseline composite content ───────────────────────────────
    model = systemcomposer.createModel(char(modelName));
    arch  = model.Architecture;

    comp = addComponent(arch, char(wrapperName));
    % Add boundary ports + baseline sub-components on the COMPOSITE first.
    % After makeVariant this content becomes the first auto-created choice.
    in  = addPort(comp.Architecture, 'Input',  'in');
    out = addPort(comp.Architecture, 'Output', 'out');
    baselineSub = addComponent(comp.Architecture, 'BaselineImpl');
    addPort(baselineSub.Architecture, 'In',  'in');
    addPort(baselineSub.Architecture, 'Out', 'out');
    connect(in,  baselineSub.getPort('In'));
    connect(baselineSub.getPort('Out'), out);

    % ── 2. Convert to variant wrapper ───────────────────────────────────────
    vc = comp.makeVariant();

    % ── 3. Re-fetch -- original `comp` is stale in the new variant scope ────
    wrapper = arch.getComponent(char(wrapperName)); %#ok<NASGU>

    % ── 4. Rename the auto-choice + sync its condition ──────────────────────
    choices = vc.getChoices();
    choices(1).Name = 'V0_Baseline';
    vc.setCondition(choices(1), 'V0_Baseline');

    % ── 5. Add alternative choices -- each is a regular Component ───────────
    v1 = vc.addChoice({'V1_Alternative'});
    % Boundary ports on this choice (match the wrapper's boundary shape)
    v1In  = addPort(v1.Architecture, 'Input',  'in');
    v1Out = addPort(v1.Architecture, 'Output', 'out');
    % Internal content -- different from V0 to justify the variant existing
    altA = addComponent(v1.Architecture, 'AltA');
    altB = addComponent(v1.Architecture, 'AltB');
    addPort(altA.Architecture, 'In',  'in');
    addPort(altA.Architecture, 'Out', 'out');
    addPort(altB.Architecture, 'In',  'in');
    addPort(altB.Architecture, 'Out', 'out');
    connect(v1In, altA.getPort('In'));
    connect(altA.getPort('Out'), altB.getPort('In'));
    connect(altB.getPort('Out'), v1Out);

    % ── 6. Stereotype profile + per-variant properties ──────────────────────
    profile = systemcomposer.profile.Profile.createProfile(char(profileName));
    st = addStereotype(profile, "Props", AppliesTo="Component");
    addProperty(st, "Cost",                   Type="double", DefaultValue="0");
    addProperty(st, "Throughput",             Type="double", DefaultValue="0");
    % Numeric flag for topology-dependent rollup: 0 = MIN/serial, 1 = SUM/parallel.
    % Must be numeric -- string stereotype properties do not propagate from a
    % variant choice to the wrapper's instance at instantiate time.
    addProperty(st, "UseParallelThroughput", Type="double", DefaultValue="0");
    profile.save(char(archDir));

    applyProfile(model, char(profileName));

    stPath = char(profileName) + ".Props";

    % Apply stereotype + values to EACH choice (not the variant wrapper).
    % V0 serial aggregation; V1 parallel aggregation.
    applyStereotype(choices(1), stPath);
    setProperty(choices(1), stPath + ".Cost",                   "0");
    setProperty(choices(1), stPath + ".Throughput",             "0");
    setProperty(choices(1), stPath + ".UseParallelThroughput",  "0");   % MIN

    applyStereotype(v1, stPath);
    setProperty(v1, stPath + ".Cost",                   "0");
    setProperty(v1, stPath + ".Throughput",             "0");
    setProperty(v1, stPath + ".UseParallelThroughput",  "1");   % SUM

    % Sub-components also get stereotyped with their own values.
    applyStereotype(baselineSub, stPath);
    setProperty(baselineSub, stPath + ".Cost",       "100");
    setProperty(baselineSub, stPath + ".Throughput", "50");

    applyStereotype(altA, stPath);
    setProperty(altA, stPath + ".Cost",       "40");
    setProperty(altA, stPath + ".Throughput", "30");
    applyStereotype(altB, stPath);
    setProperty(altB, stPath + ".Cost",       "40");
    setProperty(altB, stPath + ".Throughput", "30");

    % ── 7. Default active variant ──────────────────────────────────────────
    vc.setActiveChoice('V0_Baseline');

    % ── 8. Layout -- reach inactive choices explicitly ─────────────────────
    Simulink.BlockDiagram.arrangeSystem(char(modelName));
    arrangeCompositesIncludingVariants(arch, char(modelName));

    save_system(char(modelName), char(slxFile));
    fprintf("Variant composite %s (choices: V0_Baseline, V1_Alternative) saved.\n", wrapperName);
end

function arrangeCompositesIncludingVariants(arch, pathPrefix)
% .Architecture on a VariantComponent returns only the ACTIVE choice, so a
% walker that follows .Architecture never reaches inactive variants. Iterate
% getChoices() explicitly so every choice's canvas gets laid out.
    for c = arch.Components
        subPath = [pathPrefix, '/', c.Name];
        if isa(c, 'systemcomposer.arch.VariantComponent')
            try, Simulink.BlockDiagram.arrangeSystem(subPath); catch, end
            for ch = c.getChoices()
                choicePath = [subPath, '/', ch.Name];
                try, Simulink.BlockDiagram.arrangeSystem(choicePath); catch, end
                arrangeCompositesIncludingVariants(ch.Architecture, choicePath);
            end
        elseif ~isempty(c.Architecture) && ~isempty(c.Architecture.Components)
            Simulink.BlockDiagram.arrangeSystem(subPath);
            arrangeCompositesIncludingVariants(c.Architecture, subPath);
        end
    end
end
