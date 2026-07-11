function boidsGUI()
%BOIDSGUI Interactive Boids flocking simulation with a uihtml control panel.
%   Implements Craig Reynolds' three steering rules (separation, alignment,
%   cohesion) on a wrap-around 2D world. The control panel is HTML/CSS/JS
%   (Warm Dark, via matlab-uihtml-design). All rule weights are tunable
%   live while the flock is flying. Click the sky to trigger a predator
%   strike; boids flee the strike point and regroup.

    L      = 100;   % world is [0,L] x [0,L], toroidal wrap
    margin = 16;
    panelW = 360;

    ss   = get(groot, 'ScreenSize');
    figH = min(920, ss(4) - 160);
    axSize = figH - 2*margin;
    figW   = panelW + axSize + 3*margin;

    themeStr = detectTheme();
    pal = palette(themeStr);

    fig = uifigure( ...
        'Name', 'Boids (uihtml)', ...
        'Position', [60 60 figW figH], ...
        'Color', pal.figBg);

    h = uihtml(fig, 'Position', [margin margin panelW axSize]);
    h.HTMLSource = fullfile(fileparts(mfilename('fullpath')), 'controls.html');

    ax = uiaxes(fig, 'Position', [panelW + 2*margin, margin, axSize, axSize]);
    styleAxes(ax, L, pal);

    sim = initSim(defaultParams(), L);
    sim = initGraphics(sim, ax, pal);
    sim.pal = pal;

    tmr = timer( ...
        'ExecutionMode', 'fixedRate', ...
        'Period',        0.03, ...
        'BusyMode',      'drop', ...
        'TimerFcn',      @(~, ~) stepSim(fig));

    fig.UserData = struct( ...
        'Sim',   sim, ...
        'Timer', tmr, ...
        'Axes',  ax, ...
        'Theme', themeStr, ...
        'UIHtml', h);

    fig.CloseRequestFcn = @(s, ~) closeFig(s);
    ax.ButtonDownFcn    = @(~, evt) strikeAt(fig, evt.IntersectionPoint(1:2));

    h.HTMLEventReceivedFcn = @(src, event) handleEvent(src, event, fig);

    renderFrame(fig);
end

% ------------------------------------------------------------------ events
function handleEvent(src, event, fig)
    name = event.HTMLEventName;
    data = event.HTMLEventData;

    try
        switch name
            case 'Ready'
                sendEventToHTMLSource(src, 'SetTheme', ...
                    struct('theme', fig.UserData.Theme));
                setRunning(fig, true);

            case 'Start'
                setRunning(fig, true);

            case 'Pause'
                setRunning(fig, false);

            case 'Reset'
                s = fig.UserData.Sim;
                sNew = initSim(s.p, s.L);
                sNew = adoptGraphics(sNew, s);
                fig.UserData.Sim = sNew;
                renderFrame(fig);

            case 'SetParams'
                p = validateParams(data);
                s = fig.UserData.Sim;
                s.p.sep    = p.sep;
                s.p.ali    = p.ali;
                s.p.coh    = p.coh;
                s.p.radius = p.radius;
                s.p.speed  = p.speed;
                fig.UserData.Sim = s;

            case 'SetCount'
                n = round(double(data));
                checkRange('count', n, 1, 400);
                fig.UserData.Sim = resizeFlock(fig.UserData.Sim, n);
                renderFrame(fig);

            case 'SetInspect'
                s = fig.UserData.Sim;
                s.inspect = logical(data);
                if ~s.inspect
                    s.circ.Visible  = 'off';
                    s.links.Visible = 'off';
                end
                fig.UserData.Sim = s;
                renderFrame(fig);

            case 'Scatter'
                s = fig.UserData.Sim;
                c = [circMean(s.P(:, 1), s.L), circMean(s.P(:, 2), s.L)];
                strikeAt(fig, c);

            case 'OpenLink'
                url = char(data);
                if startsWith(url, 'https://')
                    web(url, '-browser');
                end

            otherwise
                fprintf('Unknown event: %s\n', name);
        end

    catch ME
        fprintf('Error in %s: %s\n', name, ME.message);
        sendEventToHTMLSource(src, 'SimError', ME.message);
    end
end

function setRunning(fig, run)
    tmr = fig.UserData.Timer;
    if run && strcmp(tmr.Running, 'off')
        start(tmr);
    elseif ~run && strcmp(tmr.Running, 'on')
        stop(tmr);
    end
    sendEventToHTMLSource(fig.UserData.UIHtml, 'SimState', struct('running', run));
end

function strikeAt(fig, pos)
    s = fig.UserData.Sim;
    s.scare.pos = double(pos(:))';
    s.scare.amp = 1;
    fig.UserData.Sim = s;
end

% ------------------------------------------------------------- validation
function p = defaultParams()
    p = struct('sep', 1.5, 'ali', 1.0, 'coh', 1.0, ...
               'radius', 10, 'speed', 25, 'count', 120);
end

function p = validateParams(data)
    required = {'sep', 'ali', 'coh', 'radius', 'speed'};
    for k = 1:numel(required)
        if ~isfield(data, required{k})
            error('Missing parameter: %s', required{k});
        end
    end
    p.sep    = double(data.sep);
    p.ali    = double(data.ali);
    p.coh    = double(data.coh);
    p.radius = double(data.radius);
    p.speed  = double(data.speed);

    checkRange('sep',    p.sep,    0, 3);
    checkRange('ali',    p.ali,    0, 3);
    checkRange('coh',    p.coh,    0, 3);
    checkRange('radius', p.radius, 2, 30);
    checkRange('speed',  p.speed,  5, 80);
end

function checkRange(name, v, lo, hi)
    if ~isscalar(v) || ~isfinite(v) || v < lo || v > hi
        error('%s = %g is out of range [%g, %g]', name, v, lo, hi);
    end
end

% ------------------------------------------------------------- simulation
function s = initSim(p, L)
    n = p.count;
    s.L  = L;
    s.p  = p;
    s.P  = rand(n, 2) * L;
    ang  = rand(n, 1) * 2 * pi;
    v0   = 0.8 * p.speed;               % velocities are in world units/s
    s.V  = v0 * [cos(ang), sin(ang)];
    s.scare   = struct('pos', [0 0], 'amp', 0);
    s.inspect = false;
    s.cnt     = zeros(n, 1);
    s.tick    = 0;
    s.dtReal  = 0.03;
    s.tickTic = tic;
    s.statTic = tic;
end

function s = resizeFlock(s, n)
    nOld = size(s.P, 1);
    if n > nOld
        add = n - nOld;
        ang = rand(add, 1) * 2 * pi;
        v0  = 0.8 * s.p.speed;
        s.P = [s.P; rand(add, 2) * s.L];
        s.V = [s.V; v0 * [cos(ang), sin(ang)]];
    elseif n < nOld
        s.P = s.P(1:n, :);
        s.V = s.V(1:n, :);
    end
    s.p.count = n;
    s.cnt = zeros(n, 1);
end

function stepSim(fig)
    if ~isvalid(fig)
        return;
    end
    s = fig.UserData.Sim;
    % Integrate with measured wall-clock time so the on-screen speed matches
    % the Speed setting regardless of achieved frame rate. Clamped so a long
    % stall (breakpoint, window drag) cannot produce a huge jump.
    s.dtReal  = min(max(toc(s.tickTic), 0.005), 0.1);
    s.tickTic = tic;
    s = physics(s);
    fig.UserData.Sim = s;
    renderFrame(fig);
    maybeSendStats(fig);
end

function s = physics(s)
    N = size(s.P, 1);
    if N == 0
        return;
    end

    dt    = s.dtReal;
    vmax  = s.p.speed;         % world units/s
    vmin  = 0.5 * vmax;
    fmax  = 4 * vmax * dt;     % max steering delta-v this tick (turn rate 4/s)
    rCore = 1.2;               % contact distance, boids never pack tighter

    % Pairwise wrapped offsets: DX(i,j) = xj - xi on the torus
    DX = s.P(:, 1)' - s.P(:, 1);
    DY = s.P(:, 2)' - s.P(:, 2);
    DX = DX - s.L * round(DX / s.L);
    DY = DY - s.L * round(DY / s.L);
    D2 = DX.^2 + DY.^2;

    r2   = s.p.radius^2;
    mask = D2 < r2 & D2 > 0;
    cnt  = sum(mask, 2);
    s.cnt = cnt;

    % Cohesion: steer toward the mean offset of visible neighbors.
    % Arrival damping: the pull fades as the local center gets close,
    % otherwise strong cohesion collapses the flock into a point.
    cohV = [sum(mask .* DX, 2), sum(mask .* DY, 2)] ./ max(cnt, 1);
    cohV(cnt == 0, :) = 0;
    cohScale = min(1, vecnorm(cohV, 2, 2) / (0.5 * s.p.radius));

    % Crowding damping: cohesion also fades as the immediate neighborhood
    % fills up, so maximum cohesion packs the flock to a finite density
    % instead of pumping boids into a point.
    nClose   = sum(D2 < (2 * rCore)^2 & D2 > 0, 2);
    cohScale = cohScale .* max(0, 1 - nClose / 8);

    % Alignment: steer toward the mean velocity of visible neighbors
    aliV = (mask * s.V) ./ max(cnt, 1);
    aliV(cnt == 0, :) = 0;

    % Separation: push away from close neighbors, 1/d^2 falloff
    rs2   = (0.45 * s.p.radius)^2;
    maskS = D2 < rs2 & D2 > 0;
    w     = 1 ./ max(D2, 0.01);
    sepV  = -[sum(maskS .* DX .* w, 2), sum(maskS .* DY .* w, 2)];

    acc = s.p.sep * steer(sepV, s.V, vmax, fmax) ...
        + s.p.ali * steer(aliV, s.V, vmax, fmax) ...
        + s.p.coh * cohScale .* steer(cohV, s.V, vmax, fmax);

    % Predator strike: flee the scare point while it decays
    if s.scare.amp > 0.01
        dxs = s.P(:, 1) - s.scare.pos(1);
        dys = s.P(:, 2) - s.scare.pos(2);
        dxs = dxs - s.L * round(dxs / s.L);
        dys = dys - s.L * round(dys / s.L);
        d2  = dxs.^2 + dys.^2;
        in  = d2 < 30^2;
        fleeV = [dxs, dys] .* in;
        acc = acc + 3 * s.scare.amp * steer(fleeV, s.V, vmax, 3 * fmax);
        s.scare.amp = s.scare.amp * exp(-3.5 * dt);   % ~0.2 s half-life
    end

    s.V = s.V + acc;

    sp = vecnorm(s.V, 2, 2);
    over  = sp > vmax;
    under = sp < vmin & sp > 1e-12;
    if any(over)
        s.V(over, :)  = s.V(over, :)  ./ sp(over, 1)  * vmax;
    end
    if any(under)
        s.V(under, :) = s.V(under, :) ./ sp(under, 1) * vmin;
    end

    s.P = mod(s.P + s.V * dt, s.L);

    % Hard core: contact handling when boids get closer than rCore,
    % independent of the rule weights. Steering alone cannot resolve a
    % dense clump because opposing contributions cancel. Two parts, like a
    % collision solver: kill the velocity component approaching the nearest
    % neighbor, then relax all pairwise overlaps positionally (one Jacobi
    % iteration per tick, using start-of-tick distances).
    if N > 1
        [dmin2, jmin] = min(D2 + diag(inf(N, 1)), [], 2);
        core = find(dmin2 < rCore^2);
        if ~isempty(core)
            idx  = sub2ind([N N], core, jmin(core));
            d    = sqrt(dmin2(core));
            away = -[DX(idx), DY(idx)];
            n0   = d < 1e-6;
            if any(n0)  % coincident pair: split along an index-based direction
                a = 2 * pi * core(n0) / N;
                away(n0, :) = [cos(a), sin(a)];
            end
            if any(~n0)
                away(~n0, :) = away(~n0, :) ./ d(~n0, 1);
            end

            appr = -sum(s.V(core, :) .* away, 2);   % speed toward the neighbor
            hit  = appr > 0;
            if any(hit)
                s.V(core(hit), :) = s.V(core(hit), :) + appr(hit, 1) .* away(hit, :);
            end

            % All-pairs overlap relaxation: each contact pushes half its
            % overlap apart; capped so one tick cannot teleport a boid.
            CM = D2 < rCore^2 & D2 > 0;
            Dc = sqrt(max(D2, 1e-12));
            Ov = (rCore - Dc) .* CM;
            pushX = -0.5 * sum(DX ./ Dc .* Ov, 2);
            pushY = -0.5 * sum(DY ./ Dc .* Ov, 2);
            pm = hypot(pushX, pushY);
            f  = min(1, (0.5 * rCore) ./ max(pm, 1e-9));
            s.P = mod(s.P + [pushX, pushY] .* f, s.L);
        end
    end

    s.tick = s.tick + 1;
end

function F = steer(desired, V, vmax, fmax)
%STEER Reynolds steering: (desired direction at vmax) minus current velocity,
%   clamped to a maximum force. Rows with no desired direction contribute 0.
%   Note the (ok, 1) subscripts: indexing a scalar with a false logical
%   yields 0x0, which breaks implicit expansion when N == 1.
    n  = vecnorm(desired, 2, 2);
    ok = n > 1e-9;
    des = zeros(size(desired));
    if any(ok)
        des(ok, :) = desired(ok, :) ./ n(ok, 1) * vmax;
    end
    F = des - V;
    F(~ok, :) = 0;
    fn   = vecnorm(F, 2, 2);
    clip = fn > fmax;
    if any(clip)
        F(clip, :) = F(clip, :) ./ fn(clip, 1) * fmax;
    end
end

function c = circMean(x, L)
%CIRCMEAN Mean position on a circle of circumference L.
    ang = x / L * 2 * pi;
    c = mod(atan2(mean(sin(ang)), mean(cos(ang))), 2 * pi) / (2 * pi) * L;
end

% ------------------------------------------------------------------ theme
function themeStr = detectTheme()
    themeStr = 'dark';
    try
        st = settings;
        themeStr = lower(char(st.matlab.appearance.MATLABTheme.ActiveValue));
    catch
        % settings.matlab.appearance not available; keep the default
    end
    if ~ismember(themeStr, {'dark', 'light'})
        themeStr = 'dark';
    end
end

function pal = palette(themeStr)
%PALETTE Warm Dark colors (matlab-uihtml-design) for figure and plot.
    if strcmp(themeStr, 'dark')
        pal.figBg    = [0.102 0.102 0.102];   % #1a1a1a
        pal.axBg     = [0.129 0.129 0.129];   % #212121
        pal.axBorder = [0.25 0.24 0.23];
        pal.c0 = [0.62 0.60 0.58];            % lone boid, warm gray
        pal.c1 = [0.984 0.749 0.141];         % amber #fbbf24
        pal.c2 = [0.976 0.451 0.086];         % orange #f97316
        pal.inspectBoid = [0.98 0.98 0.97];
        pal.circ  = [0.98 0.98 0.97 0.5];
        pal.links = [0.984 0.749 0.141 0.45];
        pal.ring  = [0.976 0.451 0.086];
    else
        pal.figBg    = [0.980 0.980 0.976];   % #fafaf9
        pal.axBg     = [1 1 1];
        pal.axBorder = [0.80 0.78 0.77];
        pal.c0 = [0.55 0.52 0.50];
        pal.c1 = [0.851 0.467 0.024];         % amber #d97706
        pal.c2 = [0.761 0.255 0.047];         % rust #c2410c
        pal.inspectBoid = [0.11 0.10 0.09];
        pal.circ  = [0.11 0.10 0.09 0.45];
        pal.links = [0.851 0.467 0.024 0.5];
        pal.ring  = [0.918 0.345 0.047];      % #ea580c
    end
end

% -------------------------------------------------------------- rendering
function styleAxes(ax, L, pal)
    ax.Color     = pal.axBg;
    ax.XColor    = pal.axBorder;
    ax.YColor    = pal.axBorder;
    ax.XTick     = [];
    ax.YTick     = [];
    ax.Box       = 'on';
    ax.LineWidth = 0.5;
    ax.XLim      = [0 L];
    ax.YLim      = [0 L];
    ax.DataAspectRatio = [1 1 1];
    disableDefaultInteractivity(ax);
    ax.Toolbar.Visible = 'off';
end

function sim = initGraphics(sim, ax, pal)
    hold(ax, 'on');
    sim.patch = patch(ax, ...
        'Vertices', [], 'Faces', [], ...
        'FaceColor', 'flat', 'EdgeColor', 'none', ...
        'HitTest', 'off', 'PickableParts', 'none');
    sim.circ = line(ax, NaN, NaN, ...
        'Color', pal.circ, 'LineWidth', 1, ...
        'Visible', 'off', 'HitTest', 'off', 'PickableParts', 'none');
    sim.links = line(ax, NaN, NaN, ...
        'Color', pal.links, 'LineWidth', 0.75, ...
        'Visible', 'off', 'HitTest', 'off', 'PickableParts', 'none');
    sim.ring = line(ax, NaN, NaN, ...
        'Color', pal.ring, 'LineWidth', 1.5, ...
        'Visible', 'off', 'HitTest', 'off', 'PickableParts', 'none');
    hold(ax, 'off');
end

function sNew = adoptGraphics(sNew, sOld)
    sNew.patch = sOld.patch;
    sNew.circ  = sOld.circ;
    sNew.links = sOld.links;
    sNew.ring  = sOld.ring;
    sNew.inspect = sOld.inspect;
    sNew.pal   = sOld.pal;
end

function renderFrame(fig)
    if ~isvalid(fig)
        return;
    end
    s = fig.UserData.Sim;
    N = size(s.P, 1);
    if N == 0
        return;
    end

    sp = vecnorm(s.V, 2, 2);
    sp(sp < 1e-12) = 1;
    u  = s.V ./ sp;
    nv = [-u(:, 2), u(:, 1)];

    sz  = 1.4;
    tip = s.P + 1.0  * sz * u;
    bl  = s.P - 0.70 * sz * u + 0.45 * sz * nv;
    br  = s.P - 0.70 * sz * u - 0.45 * sz * nv;

    verts = [tip; bl; br];
    faces = [(1:N)', (1:N)' + N, (1:N)' + 2*N];

    % Color by local density: lone boids in warm gray, dense flock in amber
    % ramping to orange.
    t  = min(s.cnt / 10, 1);
    lo = t < 0.5;
    C  = zeros(N, 3);
    if any(lo)
        C(lo, :)  = (1 - 2*t(lo, 1))  .* s.pal.c0 + 2*t(lo, 1)        .* s.pal.c1;
    end
    if any(~lo)
        C(~lo, :) = (2 - 2*t(~lo, 1)) .* s.pal.c1 + (2*t(~lo, 1) - 1) .* s.pal.c2;
    end

    if s.inspect
        C(1, :) = s.pal.inspectBoid;
    end

    set(s.patch, 'Vertices', verts, 'Faces', faces, 'FaceVertexCData', C);

    updateInspect(s);
    updateStrikeRing(s);

    drawnow limitrate;
end

function updateInspect(s)
    if ~s.inspect
        return;
    end
    th = linspace(0, 2*pi, 64);
    r  = s.p.radius;
    set(s.circ, ...
        'XData', s.P(1, 1) + r * cos(th), ...
        'YData', s.P(1, 2) + r * sin(th), ...
        'Visible', 'on');

    % Links to visible neighbors of boid 1, drawn on the torus
    DX = s.P(:, 1) - s.P(1, 1);
    DY = s.P(:, 2) - s.P(1, 2);
    DX = DX - s.L * round(DX / s.L);
    DY = DY - s.L * round(DY / s.L);
    D2 = DX.^2 + DY.^2;
    idx = find(D2 < r^2 & D2 > 0);
    if isempty(idx)
        set(s.links, 'XData', NaN, 'YData', NaN, 'Visible', 'on');
    else
        m  = numel(idx);
        xs = [repmat(s.P(1, 1), 1, m); (s.P(1, 1) + DX(idx))'; nan(1, m)];
        ys = [repmat(s.P(1, 2), 1, m); (s.P(1, 2) + DY(idx))'; nan(1, m)];
        set(s.links, 'XData', xs(:), 'YData', ys(:), 'Visible', 'on');
    end
end

function updateStrikeRing(s)
    if s.scare.amp > 0.01
        th = linspace(0, 2*pi, 64);
        r  = (1 - s.scare.amp) * 26 + 2;
        fade = s.scare.amp;
        col  = fade * s.pal.ring + (1 - fade) * s.pal.axBg;
        set(s.ring, ...
            'XData', s.scare.pos(1) + r * cos(th), ...
            'YData', s.scare.pos(2) + r * sin(th), ...
            'Color', col, 'Visible', 'on');
    else
        s.ring.Visible = 'off';
    end
end

% ------------------------------------------------------------------ stats
function maybeSendStats(fig)
    s = fig.UserData.Sim;
    if mod(s.tick, 6) ~= 0
        return;
    end
    elapsed = toc(s.statTic);
    s.statTic = tic;
    fig.UserData.Sim = s;

    sp = vecnorm(s.V, 2, 2);
    sp(sp < 1e-12) = 1;
    order = norm(mean(s.V ./ sp, 1));

    fps = 6 / max(elapsed, 1e-3);
    h = fig.UserData.UIHtml;
    if isvalid(h)
        sendEventToHTMLSource(h, 'Stats', struct( ...
            'order', order, ...
            'fps',   fps, ...
            'n',     size(s.P, 1)));
    end
end

% ---------------------------------------------------------------- cleanup
function closeFig(fig)
    if isstruct(fig.UserData) && isfield(fig.UserData, 'Timer')
        tmr = fig.UserData.Timer;
        if ~isempty(tmr) && isvalid(tmr)
            try
                stop(tmr);
            catch
            end
            delete(tmr);
        end
    end
    delete(fig);
end
