function [prefOri, OSI, prefSF, R, theta] = estimatePOfromFFT(RF, xgrid, ygrid, SF)
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

dx = mean(diff(xgrid));   % deg/pixel
dy = mean(diff(ygrid));
Nx = numel(xgrid); Ny = numel(ygrid);

F  = fftshift(fft2(RF));
fx = (-floor(Nx/2):ceil(Nx/2)-1) / (Nx*dx);   % cycles/deg
fy = (-floor(Ny/2):ceil(Ny/2)-1) / (Ny*dy);
[FX, FY] = meshgrid(fx, fy);

mag = abs(F);
mag(FX==0 & FY==0) = 0;           % remove DC

theta    = 0:179;                 % 1-deg bins, mod 180
thetaRad = deg2rad(theta);

if nargin < 4 || isempty(SF)
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

% ---- wave-vector angle -> stripe orientation (+90) ----
prefOri = mod(prefOri + 90, 180);
R       = circshift(R, 90);       % keep the curve in the same frame as prefOri

OSI = abs(sum(R .* exp(2i * thetaRad))) / sum(R);

end