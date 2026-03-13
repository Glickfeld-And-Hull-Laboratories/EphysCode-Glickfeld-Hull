function plotIdealGaborAndFFT()

%% Grid
nx = 20;
ny = 20;

x = (1:nx) - mean(1:nx);
y = (1:ny) - mean(1:ny);

[X,Y] = meshgrid(x,y);

%% Gabor parameters
A     = 1;
sigma = 4;
gamma = 0.6;
theta = pi/6;      % orientation
f     = 0.12;      % cycles/pixel
phi   = 0;

%% Rotate coordinates
Xp =  cos(theta)*X + sin(theta)*Y;
Yp = -sin(theta)*X + cos(theta)*Y;

%% Gabor
env   = exp(-(Xp.^2 + (gamma^2)*(Yp.^2))/(2*sigma^2));
Gabor = A * env .* cos(2*pi*f*Xp + phi);

%% FFT
F = fftshift(fft2(Gabor));
powerSpec = abs(F);

fx = (-nx/2:nx/2-1)/nx;
fy = (-ny/2:ny/2-1)/ny;

%% predicted frequency location
kx = f*cos(theta);
ky = f*sin(theta);

%% Orientation line length
L = f * 80;

cx = 0;
cy = 0;

xline = [-L/2 L/2] * cos(theta) + nx/2;
yline = [-L/2 L/2] * sin(theta) + ny/2;

%% Plot
figure('Color','w')

subplot(1,2,1)
imagesc(Gabor)
axis image
colormap gray
colorbar
title('Ideal Gabor')
hold on
plot(xline,yline,'r','LineWidth',3)

subplot(1,2,2)
imagesc(fx,fy,log(powerSpec+1))
axis image
% colormap hot
colorbar
hold on
plot(kx,ky,'co','MarkerSize',12,'LineWidth',2)
plot(-kx,-ky,'co','MarkerSize',12,'LineWidth',2)
title('FFT of Ideal Gabor')
xlabel('Spatial frequency X')
ylabel('Spatial frequency Y')

end