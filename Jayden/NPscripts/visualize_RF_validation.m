function visualize_RF_validation(STA, modelRF, params)

% params = [Ac As sigmaC deltaSigma tau theta x0 y0 f phi dx dy]

theta = params(6);
f     = params(9);

[ny,nx] = size(STA);

%% ----------------------------
% PANEL 1 : STA
%% ----------------------------
figure

subplot(1,3,1)
imagesc(STA)
axis image
colormap gray
colorbar
title('STA')

%% ----------------------------
% PANEL 2 : Model result + orientation
%% ----------------------------
subplot(1,3,2)
imagesc(modelRF)
axis image
colormap gray
colorbar
title('Model RF')
hold on

% center of RF
cx = nx/2;
cy = ny/2;

% scale line length with frequency
L = f * 80;   % since RF is 20 pixels wide

dx = L * cos(theta);
dy = L * sin(theta);

% draw orientation line
plot([cx-dx cx+dx], [cy-dy cy+dy], 'r', 'LineWidth', 2)

%% ----------------------------
% PANEL 3 : FFT frequency domain
%% ----------------------------
subplot(1,3,3)

STA = STA - mean(STA(:));

F = fftshift(fft2(STA));
powerSpec = abs(F);

fx = (-nx/2:nx/2-1)/nx;
fy = (-ny/2:ny/2-1)/ny;

imagesc(fx,fy,log(powerSpec+1))
axis image
colormap gray
colorbar
title('Frequency domain')
hold on

% predicted frequency location
kx = f*cos(theta);
ky = f*sin(theta);

plot(kx,ky,'co','MarkerSize',12,'LineWidth',2)
plot(-kx,-ky,'co','MarkerSize',12,'LineWidth',2)

xlabel('Spatial frequency X')
ylabel('Spatial frequency Y')

end