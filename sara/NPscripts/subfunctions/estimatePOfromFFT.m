function PO = estimatePOfromFFT(RF, xgrid, ygrid)
% estimatePOfromFFT  Estimate preferred orientation from the 2D FFT of an RF map.
% Finds the spatial frequency with peak power, and returns its direction
% mod 180 (orientation, not direction).

dx = mean(diff(xgrid));   % deg/pixel
dy = mean(diff(ygrid));
Nx = numel(xgrid); Ny = numel(ygrid);

F  = fftshift(fft2(RF));          % RF should be Ny x Nx, same convention as before
fx = (-floor(Nx/2):ceil(Nx/2)-1) / (Nx*dx);   % cycles/deg
fy = (-floor(Ny/2):ceil(Ny/2)-1) / (Ny*dy);
[FX, FY] = meshgrid(fx, fy);

mag = abs(F);
mag(FX==0 & FY==0) = 0;           % zero out DC so it doesn't win the max

[~, idx] = max(mag(:));
PO = mod(atan2d(FY(idx), FX(idx)), 180);   % orientation = SF-vector angle mod 180
end