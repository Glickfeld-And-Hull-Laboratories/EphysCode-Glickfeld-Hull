function plotRF_FFT(RF, xgrid, ygrid, varargin)
% plotRF_FFT  Plot the magnitude of the 2D FFT of an RF (or DoG-fit) map.
%
%   plotRF_FFT(RF, xgrid, ygrid) plots the 2D magnitude spectrum as an
%   image, axes in cycles/deg.
%
%   plotRF_FFT(..., 'SF', SF) additionally overlays a dashed ring at
%   spatial frequency SF (cycles/deg) -- e.g. the plaid's SF.
%
%   plotRF_FFT(..., 'prefOri', prefOri) additionally marks the point(s)
%   on that ring at orientation prefOri (deg, mod 180 -- both prefOri and
%   prefOri+180 are marked, since orientation is direction-agnostic).
%   Requires 'SF' to also be given.
%
%   plotRF_FFT(..., 'title', str) sets the axes title.
%
%   Example
%   -------
%   figure
%   for k = 1:numel(cellsToPlot)
%       ic = cellsToPlot(k);
%       subplot(1,numel(cellsToPlot),k)
%       RF_dog = squeeze(data_DoG_all(ic,:,:));
%       plotRF_FFT(RF_dog, xgrid, ygrid, 'SF', SF, 'prefOri', PO_dog_fft(ic), ...
%           'title', sprintf('cell %d', ic))
%   end
%
%   See also estimatePOfromFFT, fft2, imagesc

p = inputParser;
addParameter(p, 'SF', []);
addParameter(p, 'prefOri', []);
addParameter(p, 'title', '');
parse(p, varargin{:});
SF       = p.Results.SF;
prefOri  = p.Results.prefOri;
titleStr = p.Results.title;

dx = mean(diff(xgrid));   % deg/pixel
dy = mean(diff(ygrid));
Nx = numel(xgrid); Ny = numel(ygrid);

F  = fftshift(fft2(RF));
fx = (-floor(Nx/2):ceil(Nx/2)-1) / (Nx*dx);   % cycles/deg
fy = (-floor(Ny/2):ceil(Ny/2)-1) / (Ny*dy);
[FX, FY] = meshgrid(fx, fy);

mag = abs(F);
mag(FX==0 & FY==0) = 0;           % zero out DC for display, same as estimatePOfromFFT

imagesc(fx, fy, mag)
axis xy image
set(gca, 'TickDir', 'out')
colormap(gca, parula)
xlabel('SF_x (cyc/deg)')
ylabel('SF_y (cyc/deg)')
hold on

if ~isempty(SF)
    thetaFull = linspace(0, 360, 200);
    plot(SF*cosd(thetaFull), SF*sind(thetaFull), 'w-', 'LineWidth', 1)
end

% if ~isempty(SF) && ~isempty(prefOri)
%     for ang = [prefOri, prefOri + 180]   % mark both ends (orientation, mod 180)
%         plot(SF*cosd(ang), SF*sind(ang), 'o', 'MarkerFaceColor', 'r', ...
%             'MarkerEdgeColor', 'w', 'MarkerSize', 7)
%     end
% end

if ~isempty(titleStr)
    title(titleStr, 'Interpreter', 'none')
end

hold off

end