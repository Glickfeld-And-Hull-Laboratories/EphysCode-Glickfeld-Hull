function [prefOri, OSI, prefSF, R, theta] = estimatePOfromFFT(RF, xgrid, ygrid, SF, pad, doPlot)
% estimatePOfromFFT  Preferred orientation, OSI, and orientation tuning
% curve from the 2D FFT of an RF map.
%
%   [prefOri, OSI, prefSF, R, theta] = estimatePOfromFFT(RF, xgrid, ygrid)
%       Whole-spectrum version: prefOri from the peak-power bin, R is the
%       power summed over all spatial frequencies, binned by orientation.
%
%   [prefOri, OSI, prefSF, R, theta] = estimatePOfromFFT(RF, xgrid, ygrid, SF)
%       Grating tuning curve at spatial frequency SF (cycles/deg): power
%       sampled around a ring of radius SF in the Fourier plane.
%       prefOri is the peak of that curve, prefSF == SF.
%
% Outputs:
%   prefOri : preferred STRIPE orientation (deg), 0-179. This is the
%             FFT wave-vector angle + 90 (stripes are perpendicular to
%             the wave vector).
%   OSI     : vector-strength OSI on the doubled angle (invariant to the
%             90 deg shift).
%   prefSF  : preferred SF (cycles/deg); echoes SF if provided.
%   R       : 1 x 180 orientation tuning curve, in the same stripe-
%             orientation frame as prefOri (R(k) is the response at
%             theta(k)).
%   theta   : 0:179, orientation axis (deg) for R.

if nargin < 4, SF = []; end
if nargin < 5 || isempty(pad), pad = 1; end
if nargin < 6 || isempty(doPlot), doPlot = false; end

dx = mean(diff(xgrid));   % deg/pixel
dy = mean(diff(ygrid));
Nx = numel(xgrid); Ny = numel(ygrid);
Mx = Nx*pad;  My = Ny*pad;               % padded size

F = fftshift(fft2(padCentered(RF, My, Mx))); % centers RF in the padding
fx = (-floor(Mx/2):ceil(Mx/2)-1) / (Mx*dx);         % cycles/deg
fy = (-floor(My/2):ceil(My/2)-1) / (My*dy);
[FX, FY] = meshgrid(fx, fy);
FY = -FY;       % screen elevation is up, rows go down

  

mag = abs(F);
mag(FX==0 & FY==0) = 0;           % remove DC

theta    = 0:179;                 % 1-deg bins, mod 180
thetaRad = deg2rad(theta);

if isempty(SF)          
    % ---- peak-based preferred orientation, whole spectrum ----
    [~, idx] = max(mag(:));
    prefOri = mod(atan2d(FY(idx), FX(idx)), 180);   % wave-vector angle
    prefSF  = hypot(FX(idx), FY(idx));

    ang    = mod(atan2d(FY, FX), 180);
    binIdx = mod(round(ang), 180) + 1;
    R      = accumarray(binIdx(:), mag(:), [180, 1], @sum)';
else
    % ---- grating tuning curve: ring at radius SF ----
    R = zeros(size(theta));
    for k = 1:numel(theta)
        R(k) = interp2(FX, FY, mag, SF*cosd(theta(k)), SF*sind(theta(k)), 'linear', 0);
    end
    [~, kmax] = max(R);
    prefOri = theta(kmax);                          % wave-vector angle
    prefSF  = SF;
end

prefOri = mod(prefOri, 180);
prefOri_plot = mod(prefOri + 90, 180); 
R       = circshift(R, 90);       % keep the curve in the same frame as prefOri

OSI = abs(sum(R .* exp(2i * thetaRad))) / sum(R);

% ===== optional diagnostic plot (delete this block + local function below) =====
if doPlot
    localPlotDiag(RF, xgrid, ygrid, SF, pad, prefOri_plot, prefSF);
end
% ===============================================================================

end


% ======================= DIAGNOSTIC PLOT (safe to delete) =======================
function localPlotDiag(RF, xgrid, ygrid, SF, pad, prefOri, prefSF)
% Row 1: original RF.  Row 2: zero-padded RF.
% Cols : RF (gray) | FFT magnitude + ring + pref-ori line | orientation tuning
dx = mean(diff(xgrid));  dy = mean(diff(ygrid));
Nx = numel(xgrid);       Ny = numel(ygrid);
theta = 0:179;
useRing = ~isempty(SF);
if useRing, rad = SF; else, rad = prefSF; end
waveAng = mod(prefOri - 90, 180);          % wave-vector angle (prefOri is stripe ori)
pads    = [1 pad];
labels  = {'original', sprintf('padded %dx', pad)};

figure('Name','estimatePOfromFFT diagnostics','Color','w');
tl = tiledlayout(2,3,'TileSpacing','compact','Padding','compact');
if useRing, mode = sprintf('ring at stim SF = %.3g', SF);
else,       mode = sprintf('whole spectrum, peak SF = %.3g', prefSF); end
title(tl, sprintf('%s | final prefOri = %.1f deg', mode, prefOri));

for v = 1:2
    Mx = Nx*pads(v);  My = Ny*pads(v);

    % ---- RF (padded version placed top-left, same as fft2(RF,My,Mx)) ----
    P  = padCentered(RF, My, Mx);
    xp = mean(xgrid) + ((0:Mx-1) - (Mx-1)/2)*dx;    % padded axes, centered on the
    yp = mean(ygrid) + ((0:My-1) - (My-1)/2)*dy;    % original grid's center
    nexttile; imagesc(xp, yp, P); colormap(gca, gray); axis image
    xlabel('x (deg)'); ylabel('y (deg)'); title(['RF, ' labels{v}])

    % ---- FFT magnitude (y-axis flipped so elevation is up) ----
    F  = fftshift(fft2(P));
    fx = (-floor(Mx/2):ceil(Mx/2)-1) / (Mx*dx);
    fy = (-floor(My/2):ceil(My/2)-1) / (My*dy);
    fyAsc   = fliplr(-fy);                 % ascending elevation freq
    magFlip = flipud(abs(F));
    [FXg, FYg] = meshgrid(fx, fyAsc);
    magFlip(FXg==0 & FYg==0) = 0;          % remove DC

    nexttile; imagesc(fx, fyAsc, magFlip); axis xy; colormap(gca, gray)
    hold on
    t = linspace(0, 2*pi, 361);
    plot(rad*cos(t), rad*sin(t), 'r--', 'LineWidth', 1);           % SF circle
    lim = 2.5*rad;
    plot(lim*cosd(waveAng)*[-1 1], lim*sind(waveAng)*[-1 1], ...
         'c-', 'LineWidth', 1.5);                                   % pref ori (wave vector)
    xlim([-lim lim]); ylim([-lim lim]); axis square
    xlabel('f_x (cyc/deg)'); ylabel('f_y (cyc/deg)'); title(['FFT, ' labels{v}])

    % ---- orientation tuning (stripe frame, same as R in main function) ----
    if useRing
        R = interp2(fx, fyAsc, magFlip, rad*cosd(theta), rad*sind(theta), 'linear', 0);
    else
        ang    = mod(atan2d(FYg, FXg), 180);
        binIdx = mod(round(ang), 180) + 1;
        R      = accumarray(binIdx(:), magFlip(:), [180 1])';
    end
    R = circshift(R, 90);

    nexttile; plot(theta, R, 'k', 'LineWidth', 1.2); hold on
    xline(prefOri, 'c-', 'LineWidth', 1.5);
    xlim([0 180]); xticks(0:45:180); box off
    xlabel('stripe orientation (deg)'); ylabel('FFT magnitude'); title(['tuning, ' labels{v}])
end
movegui('center')
end
% ================================================================================

function P = padCentered(RF, My, Mx)
% Embed RF in the middle of a My x Mx field of zeros.
[Ny, Nx] = size(RF);
r0 = floor((My - Ny)/2);
c0 = floor((Mx - Nx)/2);
P = zeros(My, Mx);
P(r0 + (1:Ny), c0 + (1:Nx)) = RF;
end
