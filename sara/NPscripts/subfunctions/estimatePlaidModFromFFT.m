function [peakPhase, A1, A2, dirs, Fsamp, AplaidPrefOri, S] = estimatePlaidModFromFFT(RF, xgrid, ygrid, SF, compAngle, phaseOffsets, dirs, doPlot, opts)
% estimatePlaidModFromFFT  Linear prediction of how much a cell's response
% to plaids is modulated by shifting the relative phase of ONE component,
% from the Fourier transform of its spatial RF (amplitude AND phase).
%
%   [modDepth, peakPhase, A1, A2, dirs, Fsamp, S] = ...
%       estimatePlaidModFromFFT(RF, xgrid, ygrid, SF)
%   [...] = estimatePlaidModFromFFT(RF, xgrid, ygrid, SF, compAngle, ...
%                                   phaseOffsets, dirs, doPlot, opts)
%
% Inputs (first four match estimatePOfromFFT):
%   RF           : Ny x Nx RF map (e.g. fitted / de-noised STA)
%   xgrid, ygrid : pixel coordinates (deg), 1 x Nx and 1 x Ny, in the same
%                  frame as the stimulus (see opts.stimOrigin)
%   SF           : grating spatial frequency (cycles/deg). If empty, the
%                  whole-spectrum preferred SF from estimatePOfromFFT is used.
%   compAngle    : angle between plaid components, deg      (default 120)
%   phaseOffsets : relative start phase(s) of component 2, deg
%                                                   (default [0 90 180 270])
%   dirs         : plaid directions of motion, deg  (default 0:30:330)
%   doPlot       : true to show the step-by-step figure     (default false;
%                  forced true if opts.pdfFile is given)
%   opts         : optional struct with fields
%                    .stimOrigin [x y]  RF coords where grating phase = 0
%                                       (default [0 0])
%                    .flipY      true if y axis points down (default false)
%                    .exampleDir plaid direction (deg) for the figure.
%                                DEFAULT = the plaid direction centred on
%                                the cell's PREFERRED orientation at SF
%                                (nearest entry of dirs).
%                    .prefOri    preferred STRIPE orientation (deg, 0-179), e.g.
%                                the prefOri output of estimatePOfromFFT. Used
%                                to choose the example direction and mark the
%                                preferred orientation in the figure. If empty
%                                (default), it is taken from the peak of the
%                                function's own 1-deg ring at SF.
%                                (S.OSI is always computed from that ring.)
%                    .padN       zero-padding for the spectrum picture (512)
%                    .label      text added to the figure title (e.g. cell ID)
%                    .pdfFile    if non-empty, export the figure to this PDF
%                    .pdfAppend  true to append to an existing PDF, so a loop
%                                over cells builds one multi-page file (false)
%                    .closeFig   true to close the figure after exporting
%                                (figure is created invisible) (false)
%                  PDF export needs MATLAB R2020a+ (exportgraphics).
%
% Outputs (1 x nDirs unless noted; indexed by dirs):
%   peakPhase       : phase offset (deg, 0-360) at which the two components sum
%                    maximally = angle(G1) - angle(G2).
%   A1, A2          : |G| of component 1 (dir - compAngle/2) and 2 (dir + compAngle/2),
%                       RF units * deg^2.
%   dirs            : direction axis (deg) for the outputs.
%   Fsamp           : nDirs x nPhases predicted F1 amplitude per phase condition.
%   AplaidPrefOri   : normalized amplitudes for all phase conditions
%                    at the FFT-derived preferred stripe orientation.
%   S               : struct with everything else: G1, G2 (complex), Gsingle,
%                   depthFull (=min/max, the CEILING: depth over a full 360-deg
%                   phase sweep; balance only), absRange (=2*min(A1,A2)),
%                   sampRange, sampDepth (=modDepth), refAmp (peak single-grating
%                   |G| at SF), ring/ringAng (|G| at 1-deg steps of wave-vector
%                   angle 0:179), prefOriSF (peak of that ring, stripe deg),
%                   prefOriInput (opts.prefOri, [] if not given), prefOri (the one
%                   used for the example direction: input if given, else SF),
%                   prefWaveAng, OSI, exampleIdx.
%
% MODEL
%   Grating  cos(2*pi*(k.x - f*t) + phi), k = SF*[cos(dir) sin(dir)] moves
%   along +k (dir = direction of motion = wave-vector angle; stripe
%   orientation = dir + 90, as in estimatePOfromFFT).
%   Linear response  r(t) = Re{ G(k) e^{i phi} e^{-i 2 pi f t} },
%       G(k) = integral RF(x) exp(+i 2 pi k.x) dx   (= conj of standard FFT)
%   Both components share TF, so any temporal-kernel gain/lag cancels.
%   Plaid F1 amplitude:  F1(dphi) = | G1 + G2 exp(i*dphi) |.
%   modDepth = (max - min)/(max + min) of F1 over the sampled dphi.
%   Full-sweep ceiling = min(A1,A2)/max(A1,A2); angle(G1)-angle(G2) sets
%   where the peak falls, which determines how close modDepth gets to it.
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
if nargin < 5 || isempty(compAngle),    compAngle = 120;               end
if nargin < 6 || isempty(phaseOffsets), phaseOffsets = [0 90 180 270]; end
if nargin < 7 || isempty(dirs),         dirs = 0:30:330;               end
if nargin < 8 || isempty(doPlot),       doPlot = false;                end
if nargin < 9 || isempty(opts),         opts = struct();               end
if ~isfield(opts,'stimOrigin'), opts.stimOrigin = [0 0]; end
if ~isfield(opts,'flipY'),      opts.flipY = false;      end
if ~isfield(opts,'padN'),       opts.padN = 512;         end
if ~isfield(opts,'prefOri'),    opts.prefOri = [];       end
if ~isfield(opts,'label'),      opts.label = '';         end
if ~isfield(opts,'pdfFile'),    opts.pdfFile = '';       end
if ~isfield(opts,'pdfAppend'),  opts.pdfAppend = false;  end
if ~isfield(opts,'closeFig'),   opts.closeFig = false;   end
doPlot = doPlot || ~isempty(opts.pdfFile);

xgrid = xgrid(:).';  ygrid = ygrid(:).';
[X, Y] = meshgrid(xgrid - opts.stimOrigin(1), ygrid - opts.stimOrigin(2));
c = struct('RF',RF,'xgrid',xgrid,'ygrid',ygrid,'X',X,'Y',Y,'stimOrigin',opts.stimOrigin, ...
           'dA',mean(diff(xgrid))*mean(diff(ygrid)));
P = struct('sf',SF,'compAngle',compAngle,'phaseOffsets',phaseOffsets(:).', ...
           'dirs',dirs(:).','flipY',opts.flipY,'padN',opts.padN);

% ---- component G's at every plaid direction ----
nD = numel(P.dirs);  h = compAngle/2;
S.G1 = zeros(1,nD);  S.G2 = zeros(1,nD);  S.Gsingle = zeros(1,nD);
for i = 1:nD
    S.G1(i)      = gAt(c, P, P.dirs(i) - h);
    S.G2(i)      = gAt(c, P, P.dirs(i) + h);
    S.Gsingle(i) = gAt(c, P, P.dirs(i));
end
S.A1 = abs(S.G1);  S.A2 = abs(S.G2);
S.peakPhase = mod(rad2deg(angle(S.G1) - angle(S.G2)), 360);

% ---- predicted F1 at the sampled phases ----
dph = deg2rad(P.phaseOffsets);
S.Fsamp = abs(S.G1(:) + S.G2(:).*exp(1i*dph));

% ---- orientation tuning at SF (1-deg steps) ----
S.ringAng = 0:179;
S.ring = zeros(1,180);

for k = 1:180
    S.ring(k) = abs(gAt(c, P, S.ringAng(k)));
end

S.refAmp = max(S.ring);
[~, kmax] = max(S.ring);

S.prefOriRing = mod(S.ringAng(kmax) + 90, 180);
S.prefOriSF = S.prefOriRing;
S.prefOriInput = [];

if ~isempty(opts.prefOri)
    S.prefOriInput = mod(opts.prefOri, 180);
end

if ~isempty(opts.prefOri)
    S.prefOri = mod(opts.prefOri, 180);
else
    S.prefOri = S.prefOriRing;
end

S.prefWaveAng = mod(S.prefOri - 90, 180);
oriAxis = mod(S.ringAng + 90, 180);
S.OSI = abs(sum(S.ring .* exp(2i*deg2rad(oriAxis)))) / max(sum(S.ring), eps);


% ---- plaid amplitudes at FFT-derived preferred orientation ----
% Preferred stripe orientation -> wave-vector direction.
h = compAngle/2;
dirPrefFFT = S.prefOriSF - 90;

G1PrefFFT = gAt(c, P, dirPrefFFT - h);
G2PrefFFT = gAt(c, P, dirPrefFFT + h);

% One normalized amplitude for each phase offset.
AplaidPrefOri = abs(G1PrefFFT + G2PrefFFT .* exp(1i*dph)) / max(S.refAmp, eps);

% Store the results for convenient access.
S.G1PrefFFT = G1PrefFFT;
S.G2PrefFFT = G2PrefFFT;
S.AplaidPrefOri = AplaidPrefOri;
S.prefOriFFTAmp = S.refAmp;


% ---- example direction: FFT preferred orientation at selected SF ----
% Convert preferred stripe orientation to wave-vector direction.
dirPrefFFT = mod(S.prefOriSF - 90, 180);

% Select the closest available plaid direction in dirs.
dd = abs(mod(P.dirs - dirPrefFFT + 180, 360) - 180);
[~, S.exampleIdx] = min(dd);

% ---- outputs ----
peakPhase = S.peakPhase;
A1 = S.A1;
A2 = S.A2;
dirs = P.dirs;
Fsamp = S.Fsamp;

% ---- optional figure / PDF ----
if doPlot
    fig = plotCombined(c, P, S, S.exampleIdx, opts);
    if ~isempty(opts.pdfFile)
        if ~opts.pdfAppend && isfile(opts.pdfFile), delete(opts.pdfFile); end
        exportgraphics(fig, opts.pdfFile, 'ContentType','vector', ...
            'Append', opts.pdfAppend && isfile(opts.pdfFile));
        if opts.closeFig, close(fig); end
    end
end
end

%% =====================================================================
%  LOCAL FUNCTIONS
%% =====================================================================

function G = gAt(c, P, dirDeg)
% G(k) = integral RF(x) exp(+i 2 pi k.x) dx at wave-vector angle dirDeg,
% |k| = P.sf, by direct summation. c.X, c.Y are relative to stimOrigin, so
% grating phase = 0 at the stimulus origin.
sgn = 1 - 2*P.flipY;
kx = P.sf*cosd(dirDeg);  ky = sgn*P.sf*sind(dirDeg);
G  = sum(sum(c.RF .* exp(1i*2*pi*(kx*c.X + ky*c.Y)))) * c.dA;
end

function fig = plotCombined(c, P, S, iEx, opts)
% One figure on a 4 x 5 grid, read as a single argument:
%   rows 1-2        Step 1  RF overlap with each component -> complex G1, G2
%   rows 3-4, cols 1-3 (3/5 width)
%     row 3         Step 2  Fourier plane + tuning -> amplitudes A1, A2 (balance)
%     row 4         Step 3  vector addition G1 + G2 e^{i dphi} (numbered 1..nPhases)
%   rows 3-4, cols 4-5 (2/5 width)
%     row 3         Panel A  same numbered points on the full phase sweep -> modDepth
%     row 4         Panel B  predicted F1 tuning: comp 1 alone and plaids at each sampled phase
% Amplitudes are normalised by the peak single-grating |G| at SF (refAmp).

deg   = char(176);
nrm   = max(S.refAmp, eps);
h     = P.compAngle/2;
dirEx = P.dirs(iEx);
angs  = dirEx + [-h h];                     % component wave-vector angles
cols  = [.8 .2 .2; .2 .4 .8];               % comp 1 red, comp 2 blue
Gn    = [S.G1(iEx) S.G2(iEx)] / nrm;
sgn   = 1 - 2*P.flipY;
np    = numel(P.phaseOffsets);

vis = 'on'; if opts.closeFig, vis = 'off'; end
fig = figure('Position',[30 30 1400 1650],'Visible',vis);
outer = tiledlayout(fig,4,5,'TileSpacing','compact','Padding','compact');   % 5 columns: left block 3/5, right block 2/5

%% ---- Step 1 (rows 1-2): RF x grating -> G ----
t1 = tiledlayout(outer,2,4,'TileSpacing','compact','Padding','compact');
t1.Layout.Tile = 1;  t1.Layout.TileSpan = [2 5];

% gratings are drawn on their own fixed fine grid so they look clean
% regardless of the RF's pixel size
nd = 160;
xd = linspace(c.xgrid(1),c.xgrid(end),nd);  yd = linspace(c.ygrid(1),c.ygrid(end),nd);
[Xd,Yd] = meshgrid(xd - c.stimOrigin(1), yd - c.stimOrigin(2));

for j = 1:2
    kx = P.sf*cosd(angs(j));  ky = sgn*P.sf*sind(angs(j));
    ph = 2*pi*(kx*c.X + ky*c.Y);
    I_re = c.RF.*cos(ph);  I_im = c.RF.*sin(ph);

    ax = nexttile(t1,(j-1)*4+1);
    showImg(ax,c.xgrid,c.ygrid,c.RF,[]);
    title(sprintf('Comp %d (dir %d%s): RF',j,mod(angs(j),360),deg),'Color',cols(j,:));

    ax = nexttile(t1,(j-1)*4+2);
    imagesc(ax,xd,yd,cos(2*pi*(kx*Xd + ky*Yd)));  styleImg(ax,[-1 1]);
    hold(ax,'on'); plot(ax,c.stimOrigin(1),c.stimOrigin(2),'k+');
    title(sprintf('Comp %d: cos grating',j),'Color',cols(j,:));

    ax = nexttile(t1,(j-1)*4+3);
    showImg(ax,c.xgrid,c.ygrid,I_re,[]);
    title(sprintf('Comp %d: RF \\times cos,  Re G = %.2f',j,sum(I_re(:))*c.dA/nrm),'Color',cols(j,:));

    ax = nexttile(t1,(j-1)*4+4);
    showImg(ax,c.xgrid,c.ygrid,I_im,[]);
    title(sprintf('Comp %d: RF \\times sin,  Im G = %.2f',j,sum(I_im(:))*c.dA/nrm),'Color',cols(j,:));
end
title(t1,'Overlap of the RF with each component gives a complex number  G = Re + i Im', ...
    'FontWeight','bold');

%% ---- Step 2 (row 3, cols 1-2): Fourier plane + tuning -> amplitudes ----
t2 = tiledlayout(outer,1,2,'TileSpacing','compact','Padding','compact');
t2.Layout.Tile = 11;  t2.Layout.TileSpan = [1 3];

N = P.padN;  dx = mean(diff(c.xgrid));  dy = mean(diff(c.ygrid));
Fm = abs(fftshift(fft2(c.RF,N,N)))*dx*dy;
fx = (-N/2:N/2-1)/(N*dx);  fy = (-N/2:N/2-1)/(N*dy);
tt = linspace(0,2*pi,200);

nexttile(t2,1);
imagesc(fx,fy,Fm); axis xy image; hold on; colormap(gca,parula);
xlim([-0.2 0.2]); ylim([-0.2 0.2]); xlabel('f_x (cpd)'); ylabel('f_y (cpd)');
hRing = plot(P.sf*cos(tt),P.sf*sin(tt),'w--');
hComp = gobjects(1,2);
for j = 1:2
    kx = P.sf*cosd(angs(j));  ky = sgn*P.sf*sind(angs(j));
    hComp(j) = plot(kx,ky,'o','Color','w','MarkerFaceColor',cols(j,:),'MarkerSize',8);
    text(kx,ky,sprintf('  |G_%d| = %.2f',j,abs(Gn(j))),'Color','w','FontWeight','bold');
end
legend([hRing hComp],{sprintf('SF = %.3g cpd',P.sf),'comp 1','comp 2'}, ...
    'Location','southoutside','FontSize',8,'NumColumns',3);
title(sprintf('|FFT| of RF at SF = %.3g cpd', P.sf));

nexttile(t2,2); hold on;
theta = 0:179;
Rori = zeros(size(theta));

for k = 1:numel(theta)
    waveAng = mod(theta(k) - 90, 180);
    idx = mod(waveAng, 180) + 1;
    Rori(k) = S.ring(idx) / nrm;
end

hTune = plot(theta, Rori, 'Color', [0.5 0.5 0.5], 'LineWidth', 2);

hCo = gobjects(1,2);
for j = 1:2
    oc = mod(angs(j)+90,180);
    hCo(j) = plot(oc,abs(Gn(j)),'o','Color',cols(j,:),'MarkerFaceColor',cols(j,:),'MarkerSize',8);
    xline(oc,'--','Color',cols(j,:));
end
hPrefSF = xline(S.prefOriSF,'-.','Color','k','LineWidth',1.5);
hl = [hTune hCo hPrefSF];
ll = {'|G| at SF','comp 1','comp 2',sprintf('prefOri (SF) = %d%s',round(S.prefOriSF),deg)};
if ~isempty(S.prefOriInput)
    hPrefIn = xline(S.prefOriInput,'-','Color',[0 .6 .3],'LineWidth',1.5);
    hl(end+1) = hPrefIn;
    ll{end+1} = sprintf('prefOri (input) = %d%s',round(S.prefOriInput),deg);
end
xlabel('stripe orientation (deg)'); ylabel('|G| / peak'); xlim([0 180]); ylim([0 1.1]);
legend(hl,ll,'Location','southoutside','FontSize',8,'NumColumns',3);
title(sprintf('Amplitudes.  OSI (at SF) = %.2f',S.OSI));

%% ---- Step 3 (row 4, cols 1-2): phasor addition ----
t3 = tiledlayout(outer,1,np,'TileSpacing','compact','Padding','compact');
t3.Layout.Tile = 16;  t3.Layout.TileSpan = [1 3];
A1n = abs(Gn(1));  A2n = abs(Gn(2));
lim = 1.15*(A1n + A2n);  if lim == 0, lim = 1; end
Fs  = abs(Gn(1) + Gn(2)*exp(1i*deg2rad(P.phaseOffsets)));    % normalised F1 at samples
for p = 1:np
    nexttile(t3,p); hold on;
    g2 = Gn(2)*exp(1i*deg2rad(P.phaseOffsets(p)));
    plot(real(Gn(1))+A2n*cos(tt),imag(Gn(1))+A2n*sin(tt),':','Color',[.7 .7 .7]);
    quiver(0,0,real(Gn(1)),imag(Gn(1)),0,'Color',cols(1,:),'LineWidth',2,'MaxHeadSize',.4);
    quiver(real(Gn(1)),imag(Gn(1)),real(g2),imag(g2),0,'Color',cols(2,:),'LineWidth',2,'MaxHeadSize',.4);
    quiver(0,0,real(Gn(1)+g2),imag(Gn(1)+g2),0,'k','LineWidth',2.5,'MaxHeadSize',.4);
    axis equal; xlim([-lim lim]); ylim([-lim lim]); grid on; xline(0); yline(0);
    xlabel('Re'); if p == 1, ylabel('Im'); end
    title({sprintf('%d:  \\Delta\\phi = %d%s',p,P.phaseOffsets(p),deg), sprintf('|sum| = %.2f',Fs(p))});
end
title(t3,{'G_1 (red) + G_2 (blue, rotated by \Delta\phi) = sum (black)', ...
    sprintf('G_1 = %.2f\\angle%d%s,   G_2 = %.2f\\angle%d%s',A1n,round(rad2deg(angle(Gn(1)))),deg, ...
    A2n,round(rad2deg(angle(Gn(2)))),deg)},'FontWeight','bold','FontSize',10);


%% ---- Panel B (row 4, cols 4-5): predicted F1 tuning curves ----
axB = axes(outer);  axB.Layout.Tile = 19;  axB.Layout.TileSpan = [1 2];
hold on;
dirsT = 0:1:179;                                          % fine grid, not limited to P.dirs
G1f = arrayfun(@(d) gAt(c,P,d - h), dirsT);               % component 1 at each plaid direction
G2f = arrayfun(@(d) gAt(c,P,d + h), dirsT);               % component 2
pc = parula(np+1);  pc = pc(1:np,:);                      % one color per phase
Y1 = abs(G1f)/nrm;                                        % comp 1 alone
YP = abs(G1f(:) + G2f(:).*exp(1i*deg2rad(P.phaseOffsets)))/nrm;   % nDirs x nPhases
%hC1 = plot(dirsT,Y1,'--','Color',cols(1,:),'LineWidth',1.5);
hPl = gobjects(1,np);
for p = 1:np
    hPl(p) = plot(dirsT,YP(:,p),'-','Color',pc(p,:),'LineWidth',1.5);
end

hEx = xline(axB, S.prefOriSF, 'r-', 'LineWidth', 1.5);
ymax = max([Y1(:); YP(:)]);  if ymax == 0, ymax = 1; end
ylim([0 1.1*ymax]);  xticks(0:30:180);  xlim([0 180]);
xlabel('plaid direction (deg)'); ylabel('predicted F1 (normalised)');
labs = [arrayfun(@(a) sprintf('plaid, \\Delta\\phi = %d%s',a,deg), P.phaseOffsets, 'UniformOutput',false)];
legend([hPl hEx], [labs,  {sprintf('Example direction = %d%s', round(mod(dirEx,180)), deg)}], 'Location','southoutside','FontSize',8,'NumColumns',3);
title('Panel B: predicted F1 tuning to plaids');

%% ---- global title ----
head = sprintf('SF %.3g cpd, components %d%s apart.  Example: preferred orientation %d%s', ...
    P.sf,P.compAngle,deg,round(S.prefOri),deg);
if ~isempty(opts.label), head = [strrep(opts.label,'_','\_') '  |  ' head]; end
title(outer,{head, 'F1(\Delta\phi) = |G_1 + G_2 e^{i\Delta\phi}|'}, ...
    'FontWeight','bold');
end

function showImg(ax, xg, yg, M, clims)
% Display-only helper: block-average large maps down to <= ~120 px so a small
% tile does not alias/look noisy (all sums are computed on the full-res map).
if isempty(clims)
    m = max(abs(M(:)));  if m == 0, m = 1; end
    clims = [-m m];
end
s = ceil(max(size(M))/120);
if s > 1
    M  = conv2(M, ones(s)/s^2, 'same');
    M  = M(1:s:end, 1:s:end);
    xg = xg(1:s:end);  yg = yg(1:s:end);
end
imagesc(ax, xg, yg, M);
styleImg(ax, clims);
end

function styleImg(ax, clims)
% Common style for all image tiles: no ticks, box or axis labels.
axis(ax,'xy'); axis(ax,'image');
colormap(ax, redblue());  caxis(ax, clims);
axis(ax,'off');
end

function clim_sym(M)
m = max(abs(M(:))); if m == 0, m = 1; end
caxis([-m m]);
end

function cm = redblue()
x = linspace(0,1,64)';
cm = flipud([min(1,2*x), 1-abs(2*x-1), min(1,2*(1-x))]);   % red = positive
end