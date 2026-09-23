function [prefOri, OSI, prefSF] = estimatePOfromFFT(RF, xgrid, ygrid, SF)
% estimatePOfromFFT  Estimate preferred orientation and orientation
% selectivity index (OSI) from the 2D FFT of an RF map.
%
%   [prefOri, OSI, prefSF] = estimatePOfromFFT(RF, xgrid, ygrid)
%       Uses the whole 2D spectrum: prefOri is the angle (mod 180) of the
%       single frequency bin with peak power (as before). OSI is computed
%       from an orientation tuning curve obtained by summing power over
%       all spatial frequencies, binned by angle (1-deg bins). prefSF is
%       the spatial frequency (cycles/deg) of that peak-power bin.
%
%   [prefOri, OSI, prefSF] = estimatePOfromFFT(RF, xgrid, ygrid, SF)
%       Restricts the orientation tuning curve to a single spatial
%       frequency SF (cycles/deg): power is sampled around a ring of
%       radius SF in the Fourier plane (1-deg steps), prefOri is the
%       angle of peak power on that ring, and OSI is computed from that
%       ring's tuning curve. prefSF is simply echoed back as SF, since
%       that's the frequency the tuning curve was computed at.
%
% Outputs:
%   prefOri : preferred orientation (deg), 0-179, mod 180
%   OSI     : orientation selectivity index (vector-strength method)
%             OSI = |sum(R(theta).*exp(2i*theta))| / sum(R(theta))
%             where theta is in radians and R is the power tuning curve.
%             OSI = 1 means power concentrated at a single orientation;
%             OSI = 0 means power is uniform across all orientations.
%   prefSF  : preferred spatial frequency (cycles/deg). Only meaningfully
%             estimated when SF is NOT provided (peak-power bin's
%             radius); when SF is provided, prefSF == SF.

dx = mean(diff(xgrid));   % deg/pixel
dy = mean(diff(ygrid));
Nx = numel(xgrid); Ny = numel(ygrid);

F  = fftshift(fft2(RF));          % RF should be Ny x Nx, same convention as before
fx = (-floor(Nx/2):ceil(Nx/2)-1) / (Nx*dx);   % cycles/deg
fy = (-floor(Ny/2):ceil(Ny/2)-1) / (Ny*dy);
[FX, FY] = meshgrid(fx, fy);

mag = abs(F);
mag(FX==0 & FY==0) = 0;           % zero out DC so it doesn't win the max/tuning curve

theta    = 0:179;                 % 1-deg orientation bins, mod 180
thetaRad = deg2rad(theta);

if nargin < 4 || isempty(SF)
    % ---- Peak-based preferred orientation (original behavior) ----
    [~, idx] = max(mag(:));
    prefOri = mod(atan2d(FY(idx), FX(idx)), 180);
    prefSF  = hypot(FX(idx), FY(idx));          % radius of peak bin, cycles/deg

    % ---- Orientation tuning curve: sum power over ALL spatial
    % frequencies, binned by angle (mod 180) ----
    ang     = mod(atan2d(FY, FX), 180);
    binIdx  = mod(round(ang), 180) + 1;         % 1..180
    R       = accumarray(binIdx(:), mag(:), [180, 1], @sum)';
else
    % ---- Orientation tuning curve sampled on a ring at radius SF ----
    R = zeros(size(theta));
    for k = 1:numel(theta)
        fxq   = SF * cosd(theta(k));
        fyq   = SF * sind(theta(k));
        R(k)  = interp2(FX, FY, mag, fxq, fyq, 'linear', 0);
    end
    [~, kmax] = max(R);
    prefOri = theta(kmax);
    prefSF  = SF;
end

OSI = abs(sum(R .* exp(2i * thetaRad))) / sum(R);

end