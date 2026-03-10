function checkFrequencyOrientation(STA, params)

% params = [Ac As sigmaC deltaSigma tau theta x0 y0 f phi dx dy]

theta = params(6);
f     = params(9);

[ny,nx] = size(STA);

%% Compute 2D FFT
F = fftshift(fft2(STA));
powerSpec = abs(F);

%% Frequency coordinates
fx = (-nx/2:nx/2-1)/nx;
fy = (-ny/2:ny/2-1)/ny;

[FX,FY] = meshgrid(fx,fy);

%% Predicted frequency location
kx = f*cos(theta);
ky = f*sin(theta);

%% Plot spectrum
figure
imagesc(fx,fy,log(powerSpec+1))
axis image
colormap hot
colorbar
hold on

%% Plot predicted peaks
plot(kx,ky,'co','MarkerSize',10,'LineWidth',2)
plot(-kx,-ky,'co','MarkerSize',10,'LineWidth',2)

xlabel('Spatial frequency X')
ylabel('Spatial frequency Y')
title('FFT of STA with predicted frequency location')

end