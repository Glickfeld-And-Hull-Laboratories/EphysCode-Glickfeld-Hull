function fig = rfSingleCycleStaticFigure4PhasePolarThreshold(offset, wv, sx, sy, lag, thresh, compSide)
% rfSingleCycleStaticFigure4PhasePolarThreshold  Same as
% rfSingleCycleStaticFigure4PhaseCartesianThreshold.m (spike-threshold LN
% model; see that file for the full threshold explanation), but the
% tuning-curve columns are plotted on polar axes instead of ordinary
% Cartesian axes.
%
% Layout: column 1 = RF / amplitude-vs-direction / single-cycle panels;
% columns 2-3 = per-phase plaid component traces + polar tuning curves for
% the plaid centered on the PATTERN direction (components at prefDir -/+ 60);
% columns 4-5 = the exact same two panel types for the plaid centered on
% the COMPONENT direction, i.e. shifted so that one of the two gratings
% sits on the preferred direction.
%
% Linear-nonlinear (LN) model: for a given stimulus direction (and, for the
% plaid, relative phase), the linear filter gives a complex weight W so the
% generator potential over one cycle is r(t) = Re[W exp(i t)]. The spike
% output is s(t) = max(0, r(t) - thresh) and the response amplitude used
% everywhere is the F1 (first-harmonic) Fourier amplitude of s(t).
%
% thresh (optional, default 0): spike threshold, same units as W.
% lag (optional, deg, default 90): temporal phase delay of the OFF subfield
%   relative to the ON subfield; lag=0 recovers the non-DS behavior.
% compSide (optional, +1 or -1, default +1): which component-direction plaid
%   to show in columns 4-5. The component-prediction curve has two peaks,
%   at patternDir+60 and patternDir-60. With +1 the plaid is centered at
%   prefDir+60 (components at prefDir and prefDir+120; the phase-shifted
%   component sits ON the preferred direction). With -1 it is centered at
%   prefDir-60 (components at prefDir-120 and prefDir; the reference
%   component sits on the preferred direction).
%
% Usage:
%   fig = rfSingleCycleStaticFigure4PhasePolarThreshold(2, 20, 3, 8);
%   fig = rfSingleCycleStaticFigure4PhasePolarThreshold(2, 20, 3, 8, 90, 0.08);
%   fig = rfSingleCycleStaticFigure4PhasePolarThreshold(2, 20, 3, 8, 90, 0.08, -1);

if nargin < 5 || isempty(lag), lag = 90; end
if nargin < 6 || isempty(thresh), thresh = 0; end
if nargin < 7 || isempty(compSide), compSide = 1; end
compSide = sign(compSide); if compSide == 0, compSide = 1; end

colShift = 1300;                 % x distance between the pattern and component column pairs
FW = 1740 + colShift; FH = 1300;
fig = figure('Color','w','Position',[30 30 FW FH],'Units','pixels');
% All axes/annotation are laid out in FW x FH pixel units but placed
% 'Units','normalized' so the grid scales with the figure window.
px2norm = @(p) [p(1)/FW, p(2)/FH, p(3)/FW, p(4)/FH];

k = 2*pi/wv;
wGauss = @(x0_,y0_,sx_,sy_,theta) exp(1i*k*(x0_*cosd(theta)+y0_*sind(theta)) ...
    - 0.5*k^2*(sx_^2*cosd(theta).^2 + sy_^2*sind(theta).^2));
Wat = @(theta) 0.5*(wGauss(0,0,sx,sy,theta) - wGauss(offset,0,sx,sy,theta)*exp(-1i*deg2rad(lag)));

% ---- fixed one-cycle time grids ----
nT = 200; tdeg = linspace(0,360,nT);
NF = 360; tRadF = 2*pi*(0:NF-1)/NF;

oris12 = 0:30:330; Ng = numel(oris12);

f1v12 = f1ampThresh(arrayfun(Wat, oris12), thresh, tRadF);
[~,PO] = composi(oris12,f1v12); PO = mod(PO,360);

ampPref = f1ampThresh(Wat(PO), thresh, tRadF);
ampNull = f1ampThresh(Wat(mod(PO+180,360)), thresh, tRadF);
if ampNull > ampPref
    prefDir = mod(PO+180,360); ampPref0 = ampNull; ampNull = ampPref; ampPref = ampPref0;
else
    prefDir = PO;
end
DSI = (ampPref-ampNull)/(ampPref+ampNull+eps);

% Pattern-direction plaid: centered on the preferred DIRECTION (snapped to grid)
dirC = mod(30*round(prefDir/30), 360);
POm60 = mod(dirC-60,360);
POp60 = mod(dirC+60,360);
% Component-direction plaid: shifted by +/-60 so one grating sits on prefDir
dirC2 = mod(dirC + 60*compSide, 360);
CPm60 = mod(dirC2-60,360);
CPp60 = mod(dirC2+60,360);

annotation(fig,'textbox','Units','normalized','Position',px2norm([15 1260 1710 30]), ...
    'String',sprintf(['offset=%.2f deg   wv=%.2f deg   sigma_x=%.2f   sigma_y=%.2f   OFF lag=%.0f deg   thresh=%.3f      ' ...
    'PO = %.1f deg   preferred direction = %.1f deg   DSI = %.2f      ' ...
    'PATTERN plaid centered at %.0f deg: components at %.1f deg and %.1f deg'], ...
    offset, wv, sx, sy, lag, thresh, PO, prefDir, DSI, dirC, POm60, POp60), ...
    'FontSize',14,'FontWeight','bold','HorizontalAlignment','left', ...
    'EdgeColor','none','BackgroundColor','w','Interpreter','none');
annotation(fig,'textbox','Units','normalized','Position',px2norm([490+colShift 1260 1230 30]), ...
    'String',sprintf('COMPONENT plaid centered at %.0f deg (prefDir %+d deg): components at %.1f deg and %.1f deg', ...
    dirC2, 60*compSide, CPm60, CPp60), ...
    'FontSize',14,'FontWeight','bold','HorizontalAlignment','left', ...
    'EdgeColor','none','BackgroundColor','w','Interpreter','none');

%% --- column 1: RF real space + magnitude/phase vs theta ---
axRF  = axes(fig,'Units','normalized','Position',px2norm([10 630 460 260]));
axMag = axes(fig,'Units','normalized','Position',px2norm([10 350 460 220]));
axCyc2 = axes(fig,'Units','normalized','Position',px2norm([10  70 460 220]));

%% --- columns 2-3 (pattern) and 4-5 (component): 4 rows, one per phase ---
nPhases = 4;
rowH = 185; rowGap = 20;
colC_x = 490; colC_w = 560;
colD_x = 1070; colD_w = 660;
rowHD = 254; rowGapD = 50; topD = 1230;
axComp  = gobjects(1,nPhases); axTune  = gobjects(1,nPhases);
axComp2 = gobjects(1,nPhases); axTune2 = gobjects(1,nPhases);
for i = 1:nPhases
    yPos = 890 - i*(rowH+rowGap) + rowGap;
    axComp(i)  = axes(fig,'Units','normalized','Position',px2norm([colC_x yPos colC_w rowH]));
    axComp2(i) = axes(fig,'Units','normalized','Position',px2norm([colC_x+colShift yPos colC_w rowH]));
end
% polar column geometry: taller pitch because polaraxes reserve space
% outside their Position for tick labels and titles
for i = 1:nPhases
    yPosD = topD - i*(rowHD+rowGapD) + rowGapD;
    axTune(i)  = polaraxes(fig,'Units','normalized','Position',px2norm([colD_x yPosD colD_w rowHD]));
    axTune2(i) = polaraxes(fig,'Units','normalized','Position',px2norm([colD_x+colShift yPosD colD_w rowHD]));
end

% ---------- column 1a: real-space RF ----------
extent = min(abs(offset)/2 + 4*max(sx,sy) + 2, 80);
gx = linspace(-extent,extent,140); gy = gx;
[XX,YY] = meshgrid(gx,gy);
RFon  = exp(-(XX.^2/(2*sx^2) + YY.^2/(2*sy^2)));
RFoff = exp(-((XX-offset).^2/(2*sx^2) + YY.^2/(2*sy^2)));
RFsigned = RFon - RFoff;
clim = max(abs(RFsigned(:)))+eps;
imagesc(axRF, gx, gy, RFsigned, [-clim clim]); axis(axRF,'image'); set(axRF,'YDir','normal');
colormap(axRF, divergingColormap(256)); hold(axRF,'on');
quiver(axRF, 0,0, 0.4*extent*cosd(prefDir), 0.4*extent*sind(prefDir), 0, 'k','LineWidth',2.5,'MaxHeadSize',2);
plot(axRF, [-0.4*extent*cosd(PO+90) 0.4*extent*cosd(PO+90)], [-0.4*extent*sind(PO+90) 0.4*extent*sind(PO+90)], 'k--','LineWidth',1.5);
hold(axRF,'off');
set(axRF,'TickDir','out'); box off
title(axRF,'RF: red=ON, blue=OFF (arrow=preferred direction, dashed=orientation)');
xlabel(axRF,'deg'); ylabel(axRF,'deg');

% ---------- column 1b: magnitude(theta) ----------
thetaFine = 0:0.5:360;
Wfine = arrayfun(Wat, thetaFine);
magFineLin = abs(Wfine);
magFineThr = f1ampThresh(Wfine, thresh, tRadF);

colsAll = parula(numel(oris12));

plot(axMag, thetaFine, magFineLin, '-', 'Color',[0.75 0.75 0.75],'LineWidth',1); hold(axMag,'on');
plot(axMag, thetaFine, magFineThr, 'k-','LineWidth',1.5); 
scatter(axMag, oris12, f1v12, 60, colsAll, 'filled');
hold(axMag,'off');
set(axMag,'TickDir','out'); box off
xlim(axMag,[0 360]); xticks(axMag,0:60:360);
xlabel(axMag,'\theta (deg)'); ylabel(axMag,'F1 response amplitude');
title(axMag,'amplitude vs direction (gray=linear, black=thresholded)');

% ---------- column 1, bottom panel: single-cycle responses, 120-240 deg ----------
thetas2 = mod(dirC + (-60:30:60), 360); nOri2 = numel(thetas2);
idx2 = thetas2/30 + 1;
colsSamp2 = colsAll(idx2,:);
Wsamp2 = arrayfun(Wat, thetas2);
R2 = real(Wsamp2(:) * exp(1i*deg2rad(tdeg)));
R2thr = max(0, R2 - thresh);
maxAmp2b = max(abs(R2(:))) + eps;

segW = 360; segGap = 70;
hold(axCyc2,'on');
for i = 1:nOri2
    xStart = (i-1)*(segW+segGap);
    plot(axCyc2, [xStart xStart+segW], [0 0], 'Color',[0.8 0.8 0.8],'LineWidth',0.75,'HandleVisibility','off');
    plot(axCyc2, [xStart xStart+segW], [thresh thresh], 'k--','LineWidth',0.75,'HandleVisibility','off');
    plot(axCyc2, xStart+tdeg, R2(i,:), '-', 'Color',[0.75 0.75 0.75], 'LineWidth',1);
    plot(axCyc2, xStart+tdeg, R2thr(i,:), '-', 'Color',colsSamp2(i,:), 'LineWidth',2.2);
    text(axCyc2, xStart+segW/2, maxAmp2b*1.25, sprintf('%d^\\circ',thetas2(i)), ...
        'HorizontalAlignment','center','FontWeight','bold','FontSize',9,'Interpreter','tex');
    if i > 1
        xline(axCyc2, xStart-segGap/2, 'Color',[0.85 0.85 0.85],'LineWidth',0.75);
    end
end
hold(axCyc2,'off');
xlim(axCyc2,[-segGap/2, nOri2*segW+(nOri2-1)*segGap+segGap/2]);
ylim(axCyc2,[-maxAmp2b*1.15, maxAmp2b*1.5]);
set(axCyc2,'XTick',[]);
xlabel(axCyc2,'stimulus phase within one cycle (deg), one segment per direction'); ylabel(axCyc2,'response (a.u.)');
set(axCyc2,'TickDir','out'); box off
title(axCyc2,'single-cycle responses, 120 to 240 deg (gray=linear, colored=thresholded)');

% ---------- columns 2-3: pattern-direction plaid ----------
plotPlaidColumns(axComp, axTune, dirC, NaN, 'PATTERN', Wat, thresh, tdeg, tRadF, oris12, f1v12);
set(axComp,'TickDir','out'); box off
% ---------- columns 4-5: component-direction plaid ----------
plotPlaidColumns(axComp2, axTune2, dirC2, dirC, 'COMPONENT', Wat, thresh, tdeg, tRadF, oris12, f1v12);
set(axComp2,'TickDir','out'); box off

% ---------- make text scale with the window too ----------
textObjs = findall(fig, '-property','FontSize');
for ii = 1:numel(textObjs)
    setappdata(textObjs(ii), 'baseFontSize', textObjs(ii).FontSize);
end
set(fig, 'SizeChangedFcn', @(src,~) rescaleFontsCB(src, FW, FH));

end

function plotPlaidColumns(axComp, axTune, dirCen, dirOther, tagStr, Wat, thresh, tdeg, tRadF, oris12, f1v12)
% Draws one pair of columns (per-phase component traces + polar tuning
% curves) for the plaid whose two components sit at dirCen-60 (phase-
% shifted by phi) and dirCen+60 (reference).
%   dirCen   : plaid center direction highlighted by the green marker
%   dirOther : (optional, NaN to skip) another plaid center to mark with a
%              gray square, e.g. the pattern-direction plaid in the
%              component columns, for reference
Ng = numel(oris12);
phh = 0:pi/2:(3*pi/2); Nph = numel(phh);
shiftP = mod((0:Ng-1)+2, Ng) + 1; shiftM = mod((0:Ng-1)-2, Ng) + 1;
idxC = dirCen/30 + 1;
Cm60 = mod(dirCen-60,360);
Cp60 = mod(dirCen+60,360);

WCm60 = Wat(Cm60);
WCp60 = Wat(Cp60);

pat_pred = f1v12;
comp_pred = circshift(f1v12,2) + circshift(f1v12,-2);

pf1v_all = zeros(Nph,Ng); Zc = zeros(1,Nph); Zp = zeros(1,Nph);
for ph = 1:Nph
    Wvec = arrayfun(Wat, oris12);
    Zvec = Wvec(shiftP) + exp(1i*phh(ph))*Wvec(shiftM);
    pf1v_all(ph,:) = f1ampThresh(Zvec, thresh, tRadF);
    [Rpv,Rcv] = plcomptest(f1v12, pf1v_all(ph,:), 120);
    Zp(ph) = ztrans_right([Rpv Rcv],12);
    Zc(ph) = ztrans_right([Rcv Rpv],12);
end

compA = real(WCm60*exp(1i*phh(:)) * exp(1i*deg2rad(tdeg)));
compB = real(WCp60 * exp(1i*deg2rad(tdeg)));
compB = repmat(compB, Nph, 1);
sumTrace = compA + compB;
sumTraceThr = max(0, sumTrace - thresh);

for ph = 1:Nph
    axc = axComp(ph);
    hold(axc,'on');
    yline(axc,0,'Color',[0.8 0.8 0.8],'LineWidth',0.75);
    yline(axc,thresh,'k--','LineWidth',0.75);
    plot(axc, tdeg, compA(ph,:), '--', 'Color',[0.85 0.4 0.1], 'LineWidth',1.3);
    plot(axc, tdeg, compB(ph,:), '--', 'Color',[0.4 0.1 0.7], 'LineWidth',1.3);
    plot(axc, tdeg, sumTrace(ph,:), '-', 'Color',[0.75 0.75 0.75], 'LineWidth',1);
    plot(axc, tdeg, sumTraceThr(ph,:), 'k-', 'LineWidth',2.2);
    hold(axc,'off');
    xlim(axc,[0 360]);
    ylim(axc,[-0.6 0.6]);
    xticks(axc,0:90:360);
    ylabel(axc, sprintf('\\phi=%.0f^\\circ',phh(ph)*180/pi), 'Interpreter','tex','FontWeight','bold');
    if ph == 1
        title(axc, {sprintf('%s plaid: components at %.0f^\\circ (dashed orange, phase-shifted) and %.0f^\\circ (dashed purple, reference)', tagStr, Cm60, Cp60), ...
            'gray = raw linear sum;  black = thresholded output (spike proxy)'}, 'Interpreter','tex','FontSize',9);
    end
    if ph == Nph
        xlabel(axc,'stimulus phase within one cycle (deg)');
    else
        set(axc,'XTickLabel',[]);
    end
end

% polar tuning curves: amplitude vs probe direction (0-330 deg, closed to 360)
oriClosed = [oris12 360];
thClosed = deg2rad(oriClosed);
for ph = 1:Nph
    axt = axTune(ph);
    plaidcurve = pf1v_all(ph,:);
    scalePat  = max(plaidcurve)/max(pat_pred+eps);
    scaleComp = max(plaidcurve)/max(comp_pred+eps);
    plaidClosed = [plaidcurve plaidcurve(1)];
    patClosed   = [pat_pred*scalePat pat_pred(1)*scalePat];
    compClosed  = [comp_pred*scaleComp comp_pred(1)*scaleComp];
    hold(axt,'on');
    polarplot(axt, thClosed, plaidClosed, 'k-o','LineWidth',2,'MarkerFaceColor','k','MarkerSize',3.5);
    polarplot(axt, thClosed, patClosed, 'b--','LineWidth',1.3);
    polarplot(axt, thClosed, compClosed, 'r--','LineWidth',1.3);
    if ~isnan(dirOther)
        polarplot(axt, deg2rad(dirOther), plaidcurve(dirOther/30+1), 's', 'MarkerSize',9, 'MarkerEdgeColor',[0.5 0.5 0.5], 'LineWidth',1.5);
    end
    polarplot(axt, deg2rad(dirCen), plaidcurve(idxC), 'o', 'MarkerSize',9, 'MarkerEdgeColor',[0 0.7 0], 'LineWidth',2);
    hold(axt,'off');
    thetaticks(axt,0:60:300);
    rticklabels(axt,{});
    title(axt, sprintf('%s  \\phi=%.0f^\\circ   Zc=%.2f  Zp=%.2f',tagStr,phh(ph)*180/pi, Zc(ph), Zp(ph)), 'Interpreter','tex','FontSize',9);
    rlim(axt,[0 0.2]);
end
end

function rescaleFontsCB(fig, FW, FH)
pos = get(fig,'Position');
scale = min(pos(3)/FW, pos(4)/FH);
scale = max(scale, 0.25);
objs = findall(fig, '-property','FontSize');
for ii = 1:numel(objs)
    b = getappdata(objs(ii), 'baseFontSize');
    if ~isempty(b)
        objs(ii).FontSize = max(b*scale, 5);
    end
end
end

function amp = f1ampThresh(Wc, thresh, tRad)
% F1 Fourier amplitude of max(0, Re[Wc*exp(i*tRad)] - thresh).
sz = size(Wc);
r = real(Wc(:) * exp(1i*tRad));
s = max(0, r - thresh);
N = numel(tRad);
F1 = (2/N) * (s * exp(-1i*tRad)');
amp = reshape(abs(F1), sz);
end

function cmap = divergingColormap(n)
half = floor(n/2);
top = [linspace(0,1,half)' linspace(0,1,half)' ones(half,1)];
bot = [ones(n-half,1) linspace(1,0,n-half)' linspace(1,0,n-half)'];
cmap = [top; bot];
end

% ===== inlined dependencies (originally composi.m, plcomptest.m, =====
% ===== ztrans_right.m) so this file is fully self-contained =====

function [osi,ang] = composi(angs,amps)
osi = sqrt( sum(sin(2*angs*pi/180).*amps).^2 + sum(cos(2*angs*pi/180).*amps).^2)/sum(amps);
xm = (sum(amps.*cos(deg2rad(2*angs)))/sum(amps));
ym = (sum(amps.*sin(deg2rad(2*angs)))/sum(amps));
ang = (rad2deg(atan(ym/xm)));
if xm<0
  ang = 180+ang;
elseif ym<0
  ang = 360+ang;
end
ang= ang/2;
end

function [Rp,Rc] = plcomptest(gratedirs,plaiddirs,theta)
if ~(exist('theta','var'))
  theta = 135;
end
ndirs = length(gratedirs);
nrots = (theta * ndirs/360)/2;
comp_pred = circshift(gratedirs,nrots) + circshift(gratedirs,-nrots);
pat_pred = gratedirs;
c = corrcoef(plaiddirs,pat_pred);
corrp = c(1,2);
c = corrcoef(plaiddirs,comp_pred);
corrc = c(1,2);
c = corrcoef(comp_pred,pat_pred);
corrpred = c(1,2);
Rp = (corrp - corrc*corrpred) / (sqrt((1-corrc^2)*(1-corrpred^2)));
Rc = (corrc - corrp*corrpred) / (sqrt((1-corrp^2)*(1-corrpred^2)));
end

function vals = ztrans_right(invals,ndir)
vals = 0.5*log( (1+invals(:,1))./ (1-invals(:,1)))/sqrt(1/(ndir-3));
end