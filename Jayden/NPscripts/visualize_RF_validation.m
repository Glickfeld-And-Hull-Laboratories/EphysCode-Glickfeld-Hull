function fig = visualize_RF_validation(STA, modelRF, params)

% params = [Ac As sigmaC deltaSigma tau theta x0 y0 f phi dx dy]

theta = params(6);
f     = params(9);

[ny,nx] = size(STA);

%% ----------------------------
% Prepare FFT
%% ----------------------------

STA0 = STA - mean(STA(:));

F = fftshift(fft2(STA0));
powerSpec = abs(F).^2;

fx = (-nx/2:nx/2-1)/nx;
fy = (-ny/2:ny/2-1)/ny;

[kxGrid,kyGrid] = meshgrid(fx,fy);

freqRadius = sqrt(kxGrid.^2 + kyGrid.^2);
anglesGrid = atan2(kyGrid,kxGrid);

%% ----------------------------
% Frequency tuning (radial)
%% ----------------------------

freqBins = linspace(0,max(freqRadius(:)),25);
freqPower = zeros(1,length(freqBins)-1);

for i = 1:length(freqBins)-1

    mask = freqRadius >= freqBins(i) & freqRadius < freqBins(i+1);

    freqPower(i) = mean(powerSpec(mask),'all');

end

freqBins = freqBins(1:end-1);
freqPower = freqPower ./ max(freqPower);

%% ----------------------------
% Orientation tuning (angular)
%% ----------------------------

%% ----------------------------
% Orientation tuning (robust)
%%

minFreq = 0.05;   % remove DC
maxFreq = 0.35;   % ignore extreme high freq

validMask = freqRadius >= minFreq & freqRadius <= maxFreq;

nAngles = 36;
oriBins = linspace(-pi/2, pi/2, nAngles);
oriPower = zeros(size(oriBins));

for i = 1:length(oriBins)

    th = oriBins(i);

    dtheta = wrapToPi(anglesGrid - th);

    wedgeMask = abs(dtheta) < pi/(2*nAngles);

    mask = wedgeMask & validMask;

    oriPower(i) = sum(powerSpec(mask),'all');

end

% normalize
oriPower = oriPower / max(oriPower);

%% ----------------------------
% Create Figure
%% ----------------------------

fig = figure('Units','pixels','Position',[100 100 1700 800]);

tiledlayout(2,3,'TileSpacing','compact','Padding','compact')

%% ----------------------------
% PANEL 1 : STA
%% ----------------------------

nexttile
imagesc(STA)
axis image
colormap gray
colorbar
title('STA')
set(gca,'FontSize',14)

%% ----------------------------
% PANEL 2 : Model RF
%% ----------------------------

nexttile
imagesc(modelRF)
axis image
colormap gray
colorbar
title('Model RF')
hold on

cx = nx/2;
cy = ny/2;

L = f * 80;

dx = L*cos(theta);
dy = L*sin(theta);

plot([cx-dx cx+dx],[cy-dy cy+dy],'r','LineWidth',2)

set(gca,'FontSize',14)

%% ----------------------------
% PANEL 3 : FFT
%% ----------------------------

nexttile

imagesc(fx,fy,log(powerSpec+1))
axis image
colormap gray
colorbar
title('Frequency domain')
hold on

kx = f*cos(theta);
ky = f*sin(theta);

plot(kx,ky,'co','MarkerSize',12,'LineWidth',2)
plot(-kx,-ky,'co','MarkerSize',12,'LineWidth',2)

xlabel('Spatial frequency X')
ylabel('Spatial frequency Y')

set(gca,'FontSize',14)

%% ----------------------------
% PANEL 4 : Orientation tuning
%% ----------------------------

nexttile

plot(oriBins*180/pi,oriPower,'k','LineWidth',2)
hold on

plot(theta*180/pi,1,'ro','MarkerSize',10,'LineWidth',2)

xlabel('Orientation (deg)')
ylabel('Normalized power')
title('Orientation tuning')

set(gca,'FontSize',14)

% plot(oriBins, oriPower,'k','LineWidth',2)
% hold on
% plot(thetaDeg,1,'ro','MarkerSize',10,'LineWidth',2)
% 
% xlabel('Orientation (deg)')
% ylabel('Normalized power')
% title('Orientation tuning (model)')

%% ----------------------------
% PANEL 5 : Frequency tuning
%% ----------------------------

nexttile

plot(freqBins,freqPower,'k','LineWidth',2)
hold on

plot(f,1,'ro','MarkerSize',10,'LineWidth',2)

xlabel('Spatial frequency')
ylabel('Normalized power')
title('Frequency tuning')

set(gca,'FontSize',14)

end