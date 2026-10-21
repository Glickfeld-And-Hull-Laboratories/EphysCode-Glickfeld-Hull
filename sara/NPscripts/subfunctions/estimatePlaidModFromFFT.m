function [modDepth, peakPhase, A1, A2, dirs, Fsamp, S] = estimatePlaidModFromFFT(RF, xgrid, ygrid, SF, compAngle, phaseOffsets, dirs, doPlot, opts)
% estimatePlaidModFromFFT  Linear prediction of how much a plaid response
% is modulated by the relative starting phase of its components, from the
% Fourier transform of a spatial RF map (amplitude AND phase).
%
%   [modDepth, peakPhase, A1, A2, dirs, Fsamp, S] = ...
%       estimatePlaidModFromFFT(RF, xgrid, ygrid, SF)
%   [...] = estimatePlaidModFromFFT(RF, xgrid, ygrid, SF, compAngle, ...
%                                   phaseOffsets, dirs, doPlot, opts)
%
% Inputs (first four match estimatePOfromFFT):
%   RF           : Ny x Nx RF map (e.g. fitted / de-noised STA)
%   xgrid, ygrid : pixel coordinates (deg), 1 x Nx and 1 x Ny. These must be
%                  in the same frame as the stimulus (see opts.stimOrigin)
%   SF           : grating spatial frequency (cycles/deg). If empty, the
%                  whole-spectrum preferred SF from estimatePOfromFFT is used.
%   compAngle    : angle between plaid components, deg      (default 120)
%   phaseOffsets : relative start phase(s) of component 2, deg
%                                                   (default [0 90 180 270])
%   dirs         : plaid directions of motion, deg  (default 0:30:330)
%   doPlot       : true to show step-by-step figures        (default false)
%   opts         : optional struct with fields
%                    .stimOrigin [x y]  RF coords where grating phase = 0
%                                       (default [0 0])
%                    .flipY      true if y axis points down (default false)
%                    .exampleDir direction (deg) for the step figures;
%                                default = direction with largest predicted
%                                modulation range
%                    .padN       zero-padding for magnitude plot (default 512)
%
% Outputs (1 x nDirs unless noted; indexed by dirs, as R is by theta):
%   modDepth  : (max-min)/(max+min) of the predicted F1 amplitude across the
%               SAMPLED phaseOffsets.
%   peakPhase : phase offset (deg, 0-360) at which the two components sum
%               maximally = angle(G1) - angle(G2).
%   A1, A2    : |G| of component 1 (dir - compAngle/2) and 2 (dir + compAngle/2),
%               in RF units * deg^2.
%   dirs      : direction axis (deg) for the outputs.
%   Fsamp     : nDirs x nPhases predicted F1 amplitude per phase condition.
%   S         : struct with everything else: G1, G2 (complex), Gsingle,
%               depthFull (=min/max, balance only), absRange (=2*min(A1,A2)),
%               sampRange, refAmp (peak single-grating |G| on the ring at SF),
%               ringAng, ring.
%
% MODEL
%   Grating  cos(2*pi*(k.x - f*t) + phi), k = SF*[cos(dir) sin(dir)] moves
%   along +k (dir = direction of motion = wave-vector angle; stripe
%   orientation = dir + 90, as in estimatePOfromFFT).
%   Linear response  r(t) = Re{ G(k) e^{i phi} e^{-i 2 pi f t} },
%       G(k) = integral RF(x) exp(+i 2 pi k.x) dx   (= conj of standard FFT)
%   Both components share TF, so any temporal-kernel gain/lag cancels.
%   Plaid F1 amplitude = | G1 + G2 exp(i*dphi) |.
%   Over a full 360-deg sweep, depth = min(A1,A2)/max(A1,A2) (balance only);
%   angle(G1)-angle(G2) sets where the peak falls, which matters for the
%   sampled depth when only a few phases are shown.
%
% G is evaluated by direct summation on the true coordinates (not FFT bins),
% so it is exact at SF and its phase is referenced to opts.stimOrigin rather
% than to pixel 1 as fft2 would give.
%
% NOTE: spatial-only linear RF => |G(k)| = |G(-k)|, so no direction
% selectivity here; F1 only (F0 of a linear filter is 0 for gratings).

% ---- defaults ----
if nargin < 4 || isempty(SF)
    [~, ~, SF] = estimatePOfromFFT(RF, xgrid, ygrid);
end
if nargin < 5 || isempty(compAngle),   compAngle = 120;            end
if nargin < 6 || isempty(phaseOffsets), phaseOffsets = [0 90 180 270]; end
if nargin < 7 || isempty(dirs),        dirs = 0:30:330;            end
if nargin < 8 || isempty(doPlot),      doPlot = false;             end
if nargin < 9 || isempty(opts),        opts = struct();            end
if ~isfield(opts,'stimOrigin'), opts.stimOrigin = [0 0]; end
if ~isfield(opts,'flipY'),      opts.flipY = false;      end
if ~isfield(opts,'padN'),       opts.padN = 512;         end

c = struct('name','RF','RF',RF,'xgrid',xgrid(:).','ygrid',ygrid(:).');
P = struct('sf',SF,'compAngle',compAngle,'phaseOffsets',phaseOffsets(:).', ...
           'dirs',dirs(:).','stimOrigin',opts.stimOrigin,'flipY',opts.flipY,'padN',opts.padN);

% ---- compute ----
nD = numel(P.dirs);  h = compAngle/2;
S.G1 = zeros(1,nD);  S.G2 = zeros(1,nD);  S.Gsingle = zeros(1,nD);
for i = 1:nD
    S.G1(i)      = gAt(c, P, P.dirs(i) - h);
    S.G2(i)      = gAt(c, P, P.dirs(i) + h);
    S.Gsingle(i) = gAt(c, P, P.dirs(i));
end
S.A1 = abs(S.G1);  S.A2 = abs(S.G2);
S.peakPhase = mod(rad2deg(angle(S.G1) - angle(S.G2)), 360);

dph = deg2rad(P.phaseOffsets);
S.Fsamp = abs(S.G1(:) + S.G2(:).*exp(1i*dph));          % nDirs x nPhases

S.depthFull = min(S.A1,S.A2) ./ max(S.A1,S.A2);
S.absRange  = 2*min(S.A1,S.A2);
mx = max(S.Fsamp,[],2).';  mn = min(S.Fsamp,[],2).';
S.sampRange = mx - mn;
S.sampDepth = (mx - mn) ./ (mx + mn);

ang = 0:5:355;  ring = zeros(size(ang));
for k = 1:numel(ang), ring(k) = abs(gAt(c, P, ang(k))); end
S.refAmp = max(ring);  S.ringAng = ang;  S.ring = ring;

% ---- outputs ----
modDepth  = S.sampDepth;
peakPhase = S.peakPhase;
A1 = S.A1;  A2 = S.A2;  dirs = P.dirs;  Fsamp = S.Fsamp;

% ---- optional plot ----
if doPlot
    if isfield(opts,'exampleDir')
        [~, iEx] = min(abs(P.dirs - opts.exampleDir));
    else
        [~, iEx] = max(S.absRange);
    end
    plotCombined(c, P, S, iEx);
end
end

%% =====================================================================
%  LOCAL FUNCTIONS
%% =====================================================================

function G = gAt(c, P, dirDeg)
% G(k) = integral RF(x) exp(+i 2 pi k.x) dx at wave-vector angle dirDeg,
% |k| = P.sf, by direct summation. Phase 0 at P.stimOrigin.
[X, Y] = meshgrid(c.xgrid - P.stimOrigin(1), c.ygrid - P.stimOrigin(2));
sgn = 1 - 2*P.flipY;
kx = P.sf*cosd(dirDeg);  ky = sgn*P.sf*sind(dirDeg);
dA = mean(diff(c.xgrid))*mean(diff(c.ygrid));
G  = sum(sum(c.RF .* exp(1i*2*pi*(kx*X + ky*Y)))) * dA;
end


function plotCombined(c, P, S, iEx)
% Combined figure:
% RF x grating, Fourier spectrum and orientation tuning, and phasors.
% The predicted response amplitude across phase is shown as a compact plot.

% ---- shared quantities ----
[Xs, Ys] = meshgrid(c.xgrid - P.stimOrigin(1), ...
                    c.ygrid - P.stimOrigin(2));
dA = mean(diff(c.xgrid))*mean(diff(c.ygrid));
sgn = 1 - 2*P.flipY;
h = P.compAngle/2;
angs = P.dirs(iEx) + [-h h];
cols = [.8 .2 .2; .2 .4 .8];

fig = figure('Position',[30 30 1500 1100]);

outer = tiledlayout(3,1,'TileSpacing','compact','Padding','compact');

% ---- Step 1: RF x grating ----
t1 = tiledlayout(outer,2,4,'TileSpacing','compact','Padding','compact');
t1.Layout.Tile = 1;
t1.Layout.TileSpan = [1 1];

for j = 1:2
    kx = P.sf*cosd(angs(j));
    ky = sgn*P.sf*sind(angs(j));
    ph = 2*pi*(kx*Xs + ky*Ys);

    I_re = c.RF.*cos(ph);
    I_im = c.RF.*sin(ph);

    nexttile(t1,(j-1)*4+1);
    imagesc(c.xgrid,c.ygrid,c.RF);
    axis xy image; colormap(gca,redblue()); clim_sym(c.RF);
    title(sprintf('RF (comp %d, dir %d%s)', ...
        j,mod(angs(j),360),char(176)));

    nexttile(t1,(j-1)*4+2);
    imagesc(c.xgrid,c.ygrid,cos(ph));
    axis xy image; colormap(gca,redblue()); caxis([-1 1]);
    title('Cos grating');
    hold on;
    plot(P.stimOrigin(1),P.stimOrigin(2),'k+');

    nexttile(t1,(j-1)*4+3);
    imagesc(c.xgrid,c.ygrid,I_re);
    axis xy image; colormap(gca,redblue()); clim_sym(I_re);
    title(sprintf('RF x cos: Re G = %.3g',sum(I_re(:))*dA));

    nexttile(t1,(j-1)*4+4);
    imagesc(c.xgrid,c.ygrid,I_im);
    axis xy image; colormap(gca,redblue()); clim_sym(I_im);
    title(sprintf('RF x sin: Im G = %.3g',sum(I_im(:))*dA));
end

title(t1,'RF x grating overlap');

% ---- Step 2: Fourier spectrum and orientation tuning ----
t2 = tiledlayout(outer,1,2,'TileSpacing','compact','Padding','compact');
t2.Layout.Tile = 2;

N = P.padN;
dx = mean(diff(c.xgrid));
dy = mean(diff(c.ygrid));
F = fftshift(fft2(c.RF,N,N))*dx*dy;
fx = (-N/2:N/2-1)/(N*dx);
fy = (-N/2:N/2-1)/(N*dy);
mag = abs(F);

nexttile(t2,1);
imagesc(fx,fy,mag);
axis xy image;
hold on;
colormap(gca,parula);
xlim([-0.2 0.2]);
ylim([-0.2 0.2]);
xlabel('f_x (cpd)');
ylabel('f_y (cpd)');
title('Fourier magnitude at stimulus SF');
tt = linspace(0,2*pi,200);
plot(P.sf*cos(tt),P.sf*sin(tt),'w--');

% Plot only the two component locations, without opposite-frequency points.
hComp = gobjects(1,2);
for j = 1:2
    kx = P.sf*cosd(angs(j));
    ky = sgn*P.sf*sind(angs(j));
    hComp(j) = plot(kx,ky,'o','Color',cols(j,:), ...
        'MarkerFaceColor',cols(j,:));
    text(kx,ky,sprintf('  k%d',j),'Color','w');
end

hRing = plot(P.sf*cos(tt),P.sf*sin(tt),'w--');

legend([hRing hComp], ...
    {'Stim SF - 0.05','Component 1','Component 2'}, ...
    'Location','southoutside', ...
    'FontSize',8);

nexttile(t2,2);
[prefOri,OSI,~,R,theta] = ...
    estimatePOfromFFT(c.RF,c.xgrid,c.ygrid,P.sf);

hTune = plot(theta,R/max(R),'k','LineWidth',2);
hold on;
hCompOri = gobjects(1,2);
for j = 1:2
    hCompOri(j) = xline(mod(angs(j)+90,180),'--', ...
        'Color',cols(j,:));
end
hPref = xline(prefOri,'k:');

xlabel('Stripe orientation (deg)');
ylabel('Normalized |FFT|');
xlim([0 180]);
title(sprintf('Orientation tuning: pref %.0f%s', ...
    prefOri,char(176)));

legend([hTune hCompOri hPref], ...
    {'Ori tuning @ 0.05','Component 1','Component 2', ...
     'Preferred orientation'}, ...
    'Location','southoutside', ...
    'FontSize',8, ...
    'NumColumns',2);

title(t2,'Fourier spectrum and orientation tuning');

% ---- Step 3: Phasors and compact phase-response plot ----
np = numel(P.phaseOffsets);

t3 = tiledlayout(outer,1,np+1, ...
    'TileSpacing','compact','Padding','compact');
t3.Layout.Tile = 3;

G1 = S.G1(iEx);
G2 = S.G2(iEx);
A1 = abs(G1);
A2 = abs(G2);
lim = 1.15*(A1+A2);
if lim == 0, lim = 1; end

for p = 1:np
    nexttile(t3,p);
    hold on;

    g2 = G2*exp(1i*deg2rad(P.phaseOffsets(p)));
    tt = linspace(0,2*pi,100);

    plot(real(G1)+A2*cos(tt),imag(G1)+A2*sin(tt), ...
        ':','Color',[.7 .7 .7]);
    quiver(0,0,real(G1),imag(G1),0, ...
        'Color',cols(1,:),'LineWidth',2,'MaxHeadSize',.4);
    quiver(real(G1),imag(G1),real(g2),imag(g2),0, ...
        'Color',cols(2,:),'LineWidth',2,'MaxHeadSize',.4);
    quiver(0,0,real(G1+g2),imag(G1+g2),0, ...
        'k','LineWidth',2,'MaxHeadSize',.4);

    axis equal;
    xlim([-lim lim]);
    ylim([-lim lim]);
    grid on;
    xline(0);
    yline(0);
    xlabel('Re');
    ylabel('Im');
    title(sprintf('\\Delta\\phi = %d%s', ...
        P.phaseOffsets(p),char(176)));
end


% Response vs phase for each ORIENTATION (plaid direction mod 180), colored
% by orientation. d and d+180 give the same amplitudes and the same set of
% sampled values (curve is mirrored in phase), so 0:30:150 covers everything.
nexttile(t3,np+1);
hold on;
ph       = 0:2:360;
dirsPlot = 0:30:150;
cmap     = hsv(256);                                  % circular over 180 deg
oriCol   = @(d) cmap(1 + floor(mod(d,180)/180*255), :);

for k = 1:numel(dirsPlot)
    [~, i] = min(abs(P.dirs - dirsPlot(k)));          % index of that direction
    f = abs(S.G1(i) + S.G2(i)*exp(1i*deg2rad(ph)));
    plot(ph, f, 'Color', oriCol(dirsPlot(k)), 'LineWidth', 1.5);
    plot(S.peakPhase(i), S.A1(i)+S.A2(i), '.', ...    % peak = A1+A2 at peakPhase
        'Color', oriCol(dirsPlot(k)), 'MarkerSize', 12);
end

% example direction used in the phasors above, plus its sampled phases
plot(ph, abs(G1 + G2*exp(1i*deg2rad(ph))), 'k', 'LineWidth', 2.5);
plot(P.phaseOffsets, abs(G1 + G2*exp(1i*deg2rad(P.phaseOffsets))), ...
    'ko', 'MarkerFaceColor', 'k');

colormap(gca, cmap);  caxis([0 180]);
cb = colorbar('eastoutside');
cb.Ticks = dirsPlot;
cb.Label.String = 'Plaid direction mod 180 (deg)';

xlabel('Relative phase (deg)');
ylabel('Predicted F1');
xlim([0 360]);
title('Response vs phase, by orientation (black = example dir)');

end


function clim_sym(M)
m = max(abs(M(:))); if m == 0, m = 1; end
caxis([-m m]);
end

function cm = redblue()
x = linspace(0,1,64)';
cm = flipud([min(1,2*x), 1-abs(2*x-1), min(1,2*(1-x))]);   % red = positive
end