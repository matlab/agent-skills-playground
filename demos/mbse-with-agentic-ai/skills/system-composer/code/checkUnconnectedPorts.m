function checkUnconnectedPorts(modelName)
% CHECKUNCONNECTEDPORTS Report unconnected ports in a System Composer architecture.
%   checkUnconnectedPorts(modelName) prints every component port that has no
%   connector, and confirms when all ports are connected.
%
%   Input:
%     modelName - Name of an open System Composer model (string)

    model = systemcomposer.openModel(modelName);
    arch  = model.Architecture;

    anyUnconnected = false;
    for i = 1:numel(arch.Components)
        ports = arch.Components(i).Ports;
        for j = 1:numel(ports)
            if isempty(ports(j).Connectors)
                fprintf("Unconnected: %s.%s\n", arch.Components(i).Name, ports(j).Name);
                anyUnconnected = true;
            end
        end
    end
    if ~anyUnconnected
        fprintf("All ports connected (%d connectors).\n", numel(arch.Connectors));
    end

end
