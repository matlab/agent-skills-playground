function lorenzGUI()
%LORENZGUI Interactive Lorenz attractor with a uihtml control panel.
%   Inspired by Cleve Moler's lorenzgui from "Numerical Computing with MATLAB"
%   (https://www.mathworks.com/matlabcentral/fileexchange/54611-solving-odes-in-matlab).
%   Control panel is HTML/CSS/JS (Cosmic Dark, via matlab-uihtml-design).
%   Backend uses ode45 and renders the 3D trajectory on a native uiaxes.

    figW = 1100;
    figH = 720;

    fig = uifigure( ...
        'Name', 'Lorenz Attractor (uihtml)', ...
        'Position', [80 80 figW figH], ...
        'Color', [0.039 0.039 0.094]);

    panelW = 380;
    margin = 16;
    h = uihtml(fig, ...
        'Position', [margin margin panelW figH-2*margin]);
    h.HTMLSource = fullfile(fileparts(mfilename('fullpath')), 'controls.html');

    axW = figW - panelW - 3*margin;
    axH = figH - 2*margin;
    ax = uiaxes(fig, ...
        'Position', [panelW + 2*margin, margin, axW, axH], ...
        'Tag', 'lorenzAxes');
    styleAxes(ax);
    initialPlaceholder(ax);

    fig.UserData = struct('AnimTimer', [], 'Axes', ax, 'UIHtml', h);
    fig.CloseRequestFcn = @(s, ~) closeFig(s);

    h.HTMLEventReceivedFcn = @(src, event) handleEvent(src, event, fig);

    pushTheme(h);
end

% -------------------------------------------------------------------------
function handleEvent(src, event, fig)
    name = event.HTMLEventName;
    data = event.HTMLEventData;
    ax   = fig.UserData.Axes;

    try
        switch name
            case 'RunSimulation'
                stopAnimTimer(fig);
                p = validateParams(data);
                t0 = tic;
                [tOut, Y] = integrateLorenz(p);
                elapsedMs = round(toc(t0) * 1000);

                if isfield(data, 'animate') && data.animate
                    speed = 5;
                    if isfield(data, 'speed')
                        speed = max(1, min(50, round(double(data.speed))));
                    end
                    animateTrajectory(fig, ax, tOut, Y, p, speed, elapsedMs);
                else
                    renderTrajectory(ax, tOut, Y, p);
                    sendComplete(src, tOut, Y, elapsedMs);
                end

            case 'Reset'
                stopAnimTimer(fig);
                initialPlaceholder(ax);

            case 'ExportImage'
                exportCurrentImage(fig, src);

            case 'SetSpeed'
                updateAnimSpeed(fig, data);

            case 'StopAnimation'
                stopAnimationGracefully(fig, src);

            otherwise
                fprintf('Unknown event: %s\n', name);
        end

    catch ME
        fprintf('Error in %s: %s\n', name, ME.message);
        sendEventToHTMLSource(src, 'SimError', ME.message);
    end
end

function sendComplete(src, tOut, Y, elapsedMs)
    result = struct( ...
        'nPoints',   numel(tOut), ...
        'finalX',    Y(end, 1), ...
        'finalY',    Y(end, 2), ...
        'finalZ',    Y(end, 3), ...
        'elapsedMs', elapsedMs);
    sendEventToHTMLSource(src, 'SimComplete', result);
end

% -------------------------------------------------------------------------
function p = validateParams(data)
    required = {'x0', 'y0', 'z0', 'sigma', 'rho', 'beta', 'tEnd'};
    for k = 1:numel(required)
        if ~isfield(data, required{k})
            error('Missing parameter: %s', required{k});
        end
    end

    p.x0    = double(data.x0);
    p.y0    = double(data.y0);
    p.z0    = double(data.z0);
    p.sigma = double(data.sigma);
    p.rho   = double(data.rho);
    p.beta  = double(data.beta);
    p.tEnd  = double(data.tEnd);

    checkRange('x0',    p.x0,    -50, 50);
    checkRange('y0',    p.y0,    -50, 50);
    checkRange('z0',    p.z0,    -50, 50);
    checkRange('sigma', p.sigma,   0, 100);
    checkRange('rho',   p.rho,     0, 500);
    checkRange('beta',  p.beta,    0, 50);
    checkRange('tEnd',  p.tEnd,    1, 500);
end

function checkRange(name, v, lo, hi)
    if ~isscalar(v) || ~isfinite(v) || v < lo || v > hi
        error('%s = %g is out of range [%g, %g]', name, v, lo, hi);
    end
end

% -------------------------------------------------------------------------
function [tOut, Y] = integrateLorenz(p)
    rhs = @(t, y) [ ...
        p.sigma * (y(2) - y(1)); ...
        y(1) * (p.rho - y(3)) - y(2); ...
        y(1) * y(2) - p.beta * y(3)];

    opts = odeset('RelTol', 1e-6, 'AbsTol', 1e-8);
    [tOut, Y] = ode45(rhs, [0 p.tEnd], [p.x0; p.y0; p.z0], opts);
end

% -------------------------------------------------------------------------
function styleAxes(ax)
    ax.Color = [0.039 0.039 0.094];
    ax.XColor = [0.55 0.56 0.66];
    ax.YColor = [0.55 0.56 0.66];
    ax.ZColor = [0.55 0.56 0.66];
    ax.GridColor = [0.35 0.35 0.50];
    ax.GridAlpha = 0.25;
    ax.MinorGridColor = [0.25 0.25 0.40];
    ax.Box = 'off';
    ax.FontName = 'Segoe UI';
    ax.FontSize = 10;
    ax.TickDir = 'out';
    grid(ax, 'on');
    xlabel(ax, 'x', 'Color', [0.91 0.91 0.94]);
    ylabel(ax, 'y', 'Color', [0.91 0.91 0.94]);
    zlabel(ax, 'z', 'Color', [0.91 0.91 0.94]);
    view(ax, 3);
end

function initialPlaceholder(ax)
    cla(ax);
    title(ax, 'Press RUN to integrate the Lorenz system', ...
        'Color', [0.55 0.56 0.66], 'FontWeight', 'normal');
    xlim(ax, [-25 25]);
    ylim(ax, [-30 30]);
    zlim(ax, [0 55]);
    view(ax, 3);
end

% -------------------------------------------------------------------------
function renderTrajectory(ax, tOut, Y, p)
    cla(ax);

    x = Y(:, 1);
    y = Y(:, 2);
    z = Y(:, 3);

    cdata = tOut(:);
    surface(ax, [x x], [y y], [z z], [cdata cdata], ...
        'FaceColor', 'none', ...
        'EdgeColor', 'interp', ...
        'LineWidth', 1.4);

    colormap(ax, cosmicMap());

    hold(ax, 'on');
    plot3(ax, p.x0, p.y0, p.z0, 'o', ...
        'MarkerSize', 7, ...
        'MarkerFaceColor', [0.49 0.42 0.94], ...
        'MarkerEdgeColor', 'w', ...
        'LineWidth', 1);
    plot3(ax, x(end), y(end), z(end), 'p', ...
        'MarkerSize', 11, ...
        'MarkerFaceColor', [0.96 0.45 0.71], ...
        'MarkerEdgeColor', 'w', ...
        'LineWidth', 1);
    hold(ax, 'off');

    titleStr = sprintf('\\sigma=%.2f   \\rho=%.2f   \\beta=%.3f   t \\in [0, %g]', ...
        p.sigma, p.rho, p.beta, p.tEnd);
    title(ax, titleStr, 'Color', [0.91 0.91 0.94], 'FontWeight', 'normal');
    axis(ax, 'tight');
    view(ax, 3);
    rotate3d(ax, 'on');
end

% -------------------------------------------------------------------------
function animateTrajectory(fig, ax, tOut, Y, p, ptsPerTick, elapsedMs)
    cla(ax);

    x = Y(:, 1);
    y = Y(:, 2);
    z = Y(:, 3);

    pad = 0.06;
    setLim(ax, 'X', [min(x) max(x)], pad);
    setLim(ax, 'Y', [min(y) max(y)], pad);
    setLim(ax, 'Z', [min(z) max(z)], pad);

    hold(ax, 'on');
    traceLine = animatedline(ax, ...
        'Color', [0.65 0.55 0.94], ...
        'LineWidth', 1.4, ...
        'MaximumNumPoints', numel(tOut));
    plot3(ax, p.x0, p.y0, p.z0, 'o', ...
        'MarkerSize', 7, ...
        'MarkerFaceColor', [0.49 0.42 0.94], ...
        'MarkerEdgeColor', 'w', 'LineWidth', 1);
    headMarker = plot3(ax, x(1), y(1), z(1), 'p', ...
        'MarkerSize', 11, ...
        'MarkerFaceColor', [0.96 0.45 0.71], ...
        'MarkerEdgeColor', 'w', 'LineWidth', 1);
    hold(ax, 'off');

    titleStr = sprintf('\\sigma=%.2f   \\rho=%.2f   \\beta=%.3f   t \\in [0, %g]', ...
        p.sigma, p.rho, p.beta, p.tEnd);
    title(ax, titleStr, 'Color', [0.91 0.91 0.94], 'FontWeight', 'normal');
    view(ax, 3);
    rotate3d(ax, 'on');

    state.x = x;
    state.y = y;
    state.z = z;
    state.idx = 1;
    state.n = numel(tOut);
    state.line = traceLine;
    state.head = headMarker;
    state.step = max(1, ptsPerTick);
    state.t = tOut;
    state.elapsedMs = elapsedMs;
    state.fig = fig;

    tmr = timer( ...
        'ExecutionMode', 'fixedSpacing', ...
        'Period',        0.03, ...
        'BusyMode',      'drop', ...
        'TimerFcn',      @(s, ~) animStep(s, fig));
    tmr.UserData = state;
    fig.UserData.AnimTimer = tmr;

    start(tmr);
end

function animStep(tmr, fig)
    if ~isvalid(fig) || ~isvalid(tmr)
        return;
    end
    s = tmr.UserData;
    iEnd = min(s.n, s.idx + s.step - 1);
    if iEnd >= s.idx
        addpoints(s.line, s.x(s.idx:iEnd), s.y(s.idx:iEnd), s.z(s.idx:iEnd));
        set(s.head, 'XData', s.x(iEnd), 'YData', s.y(iEnd), 'ZData', s.z(iEnd));
        s.idx = iEnd + 1;
        tmr.UserData = s;
        drawnow limitrate;
    end
    if s.idx > s.n
        stop(tmr);
        h = fig.UserData.UIHtml;
        if isvalid(h)
            sendComplete(h, s.t, [s.x s.y s.z], s.elapsedMs);
        end
        delete(tmr);
        fig.UserData.AnimTimer = [];
    end
end

function stopAnimationGracefully(fig, src)
    if ~isvalid(fig) || isempty(fig.UserData) || ~isfield(fig.UserData, 'AnimTimer')
        sendEventToHTMLSource(src, 'SimStopped', emptyStopResult());
        return;
    end
    tmr = fig.UserData.AnimTimer;
    if isempty(tmr) || ~isvalid(tmr)
        sendEventToHTMLSource(src, 'SimStopped', emptyStopResult());
        return;
    end

    s = tmr.UserData;
    stop(tmr);
    delete(tmr);
    fig.UserData.AnimTimer = [];

    nDrawn = max(0, s.idx - 1);
    if nDrawn > 0
        result = struct( ...
            'nPoints',   nDrawn, ...
            'finalX',    s.x(nDrawn), ...
            'finalY',    s.y(nDrawn), ...
            'finalZ',    s.z(nDrawn), ...
            'elapsedMs', s.elapsedMs);
    else
        result = emptyStopResult();
    end
    sendEventToHTMLSource(src, 'SimStopped', result);
end

function r = emptyStopResult()
    r = struct('nPoints', 0, 'finalX', 0, 'finalY', 0, 'finalZ', 0, 'elapsedMs', 0);
end

function updateAnimSpeed(fig, data)
    if ~isvalid(fig) || isempty(fig.UserData) || ~isfield(fig.UserData, 'AnimTimer')
        return;
    end
    tmr = fig.UserData.AnimTimer;
    if isempty(tmr) || ~isvalid(tmr)
        return;
    end
    newStep = max(1, min(50, round(double(data))));
    s = tmr.UserData;
    s.step = newStep;
    tmr.UserData = s;
end

function stopAnimTimer(fig)
    if ~isvalid(fig) || isempty(fig.UserData) || ~isfield(fig.UserData, 'AnimTimer')
        return;
    end
    tmr = fig.UserData.AnimTimer;
    if ~isempty(tmr) && isvalid(tmr)
        try
            stop(tmr);
        catch
        end
        delete(tmr);
    end
    fig.UserData.AnimTimer = [];
end

function setLim(ax, dim, range, pad)
    span = max(diff(range), 1);
    lim = range + [-1 1] * span * pad;
    set(ax, [dim 'Lim'], lim);
end

% -------------------------------------------------------------------------
function exportCurrentImage(fig, src)
    ax = fig.UserData.Axes;
    if isempty(ax.Children)
        sendEventToHTMLSource(src, 'ExportError', 'Nothing to export — run a simulation first');
        return;
    end

    defaultName = sprintf('lorenz_%s.png', datestr(now, 'yyyymmdd_HHMMSS')); %#ok<DATST,TNOW1>
    [file, path] = uiputfile({ ...
        '*.png', 'PNG image (*.png)'; ...
        '*.jpg', 'JPEG image (*.jpg)'; ...
        '*.pdf', 'PDF document (*.pdf)'}, ...
        'Export Lorenz plot', defaultName);

    if isequal(file, 0)
        sendEventToHTMLSource(src, 'ExportComplete', 'cancelled');
        return;
    end

    outPath = fullfile(path, file);
    try
        exportgraphics(ax, outPath, ...
            'Resolution',      300, ...
            'BackgroundColor', [0.039 0.039 0.094]);
        sendEventToHTMLSource(src, 'ExportComplete', file);
    catch ME
        sendEventToHTMLSource(src, 'ExportError', ME.message);
    end
end

function map = cosmicMap()
    n = 256;
    t = linspace(0, 1, n)';
    r = 0.30 + 0.66 * t;
    g = 0.22 + 0.28 * (1 - abs(2*t - 1));
    b = 0.94 - 0.20 * t;
    map = [r g b];
end

% -------------------------------------------------------------------------
function pushTheme(h)
    themeStr = 'dark';
    try
        s = settings;
        v = s.matlab.appearance.MATLABTheme.ActiveValue;
        themeStr = lower(char(v));
    catch
    end
    sendEventToHTMLSource(h, 'SetTheme', struct('theme', themeStr));
end

function closeFig(fig)
    stopAnimTimer(fig);
    delete(fig);
end
