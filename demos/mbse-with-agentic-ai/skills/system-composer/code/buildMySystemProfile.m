function buildMySystemProfile(profileName, modelName, archDir)
% BUILDMYSYSTEMPROFILE Create and apply a System Composer profile with stereotypes.
%   Always rebuilds the model first to guarantee a clean slate, avoiding the
%   "uniqueness constraint" error from re-applying a profile to an existing model.
%
%   Inputs:
%     profileName - Name of the profile (string)
%     modelName   - Name of the System Composer model (string)
%     archDir     - Directory in which to save the model and profile XML (string)

    % Always rebuild model first — avoids stale stereotype errors on re-runs
    buildMySystemModel(modelName, modelName + "Interfaces.sldd", archDir);

    %% Create Profile
    systemcomposer.profile.Profile.closeAll();
    profile = systemcomposer.profile.Profile.createProfile(profileName);

    %% Stereotypes
    st = addStereotype(profile, "MyComponent", AppliesTo="Component", Description="...");
    addProperty(st, "NominalPower_W", Type="double", Units="W", DefaultValue="0");
    addProperty(st, "SafetyClass",    Type="string",            DefaultValue='"standard"');
    %                                                                       ^^^^^^^^^^^
    %   String DefaultValue must be a quoted MATLAB expression — wrap in extra quotes

    % profile.save(folder) saves <profileName>.xml into that folder — ALWAYS pass a folder.
    % NEVER pass a path ending in .xml — it creates a directory with that name instead.
    profile.save(archDir);

    %% Apply to Model
    model = systemcomposer.openModel(modelName);
    applyProfile(model, profileName);
    arch  = model.Architecture;

    applyStereotype(arch.getComponent("ComponentA"), profileName + ".MyComponent");

    %% Set Property Values
    setProperty(arch.getComponent("ComponentA"), ...
        profileName + ".MyComponent.SafetyClass", '"safety-critical"');
    %                                              ^^^^^^^^^^^^^^^^^^^
    %   String values also need inner quotes when passed to setProperty

    save(model);
    fprintf("Profile applied: %s\n", profileName);
end
