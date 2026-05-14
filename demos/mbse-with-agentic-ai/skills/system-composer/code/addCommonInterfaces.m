function ifaces = addCommonInterfaces(dict)
% ADDCOMMONINTERFACES Add common multi-domain interfaces to a System Composer dictionary.
%   ifaces = addCommonInterfaces(dict) adds Thermal, Electrical, Mechanical, and
%   UserCommand interfaces to dict and returns a struct of the interface objects.
%
%   This function is an illustrative starting point, not a complete recipe.
%   Add, remove, or rename interfaces and elements to suit your architecture.
%
%   NOTE: Call dict.save() and re-fetch interfaces before passing them to
%   setInterface(). See the dict.save() + re-fetch pattern in the skill guide.
%
%   Input:
%     dict   - System Composer data dictionary (systemcomposer.data.Dictionary)
%
%   Output:
%     ifaces - Struct with fields:
%                ThermalFluid, HeatFlow, TemperatureSignal
%                ElectricalPower, ControlSignal
%                RotationalMechanical
%                UserCommand

    %% Thermal
    ifaces.ThermalFluid = addInterface(dict, "ThermalFluid");
    addElement(ifaces.ThermalFluid, "Temperature",  Type="double");   % K
    addElement(ifaces.ThermalFluid, "MassFlowRate", Type="double");   % kg/s

    ifaces.HeatFlow = addInterface(dict, "HeatFlow");
    addElement(ifaces.HeatFlow, "HeatFlowRate", Type="double");       % W

    ifaces.TemperatureSignal = addInterface(dict, "TemperatureSignal");
    addElement(ifaces.TemperatureSignal, "Value", Type="double");     % K

    %% Electrical
    ifaces.ElectricalPower = addInterface(dict, "ElectricalPower");
    addElement(ifaces.ElectricalPower, "Voltage", Type="double");     % V
    addElement(ifaces.ElectricalPower, "Current", Type="double");     % A

    ifaces.ControlSignal = addInterface(dict, "ControlSignal");
    addElement(ifaces.ControlSignal, "Value", Type="double");         % boolean 0/1

    %% Mechanical (rotational)
    ifaces.RotationalMechanical = addInterface(dict, "RotationalMechanical");
    addElement(ifaces.RotationalMechanical, "Torque",          Type="double");   % Nm
    addElement(ifaces.RotationalMechanical, "AngularVelocity", Type="double");   % rad/s

    %% User Interface / Control signals
    ifaces.UserCommand = addInterface(dict, "UserCommand");
    addElement(ifaces.UserCommand, "CommandID", Type="double");       % enumerated code

end
