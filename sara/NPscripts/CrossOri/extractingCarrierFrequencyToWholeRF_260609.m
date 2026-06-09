%% determining effective frequency

load(fullfile([pwd, '\CircularDoG_params.mat']),'paramCell', 'RF_cells')


%%

exCell = 470;
iCell = find(cellIDs==exCell);

%%

dogcircFits     = RF_cells;
dogcircParams   = cell2mat(paramCell);
    % 1, 2      - Ac, As
    % 3, 4      - sigmaC, deltaSigma
    % 5         - tau
    % 6         - theta
    % 7, 8      - x0, y0
    % 9         - f
    % 10        - phi
    % 11, 12    - dx, dy


p_f         = dogcircParams(iCell,9);
p_theta     = dogcircParams(iCell,6);
p_phi       = dogcircParams(iCell,10);
p_x0        = dogcircParams(iCell,7);
p_y0        = dogcircParams(iCell,8);
p_dx        = dogcircParams(iCell,11);
p_dy        = dogcircParams(iCell,12);

nx      = 20;
ny      = 20;
x       = (1:nx) - mean(1:nx);
y       = (1:ny) - mean(1:ny);
[X, Y]  = meshgrid(x, y);

Xc = X - p_x0;
Yc = Y - p_y0;
Xs = X - (p_x0 + p_dx);
Ys = Y - (p_y0 + p_dy);


Xcp = cos(p_theta)*Xc + sin(p_theta)*Yc;
Ycp = -sin(p_theta)*Xc + cos(p_theta)*Yc;

Xsp = cos(p_theta)*Xs + sin(p_theta)*Ys;
Ysp = -sin(p_theta)*Xs + cos(p_theta)*Ys;


centCos = cos(2*pi*p_f*Xcp + p_phi);
surCos  = cos(2*pi*p_f*Xsp + p_phi);

figure;
    movegui('center')
    subplot(2,3,1)
        imagesc(centCos)
        colormap('gray'); %caxis([-2 2])
        axis square
        subtitle('center cosine')
    subplot(2,3,2)
        imagesc(surCos)
        axis image
        colormap gray; %caxis([-2 2])
        subtitle('surround cosine')
    subplot(2,3,3)
        imagesc(centCos-surCos)
        axis image
        colormap gray; %caxis([-2 2])
        subtitle('cent + surr')










%% get DoG f peak


p_Ac        = dogcircParams(iCell,1);
p_As        = dogcircParams(iCell,2);
p_sc        = dogcircParams(iCell,3);
p_ss        = dogcircParams(iCell,3) + dogcircParams(iCell,4);
p_tau       = dogcircParams(iCell,5);

Gc = exp(-(Xcp.^2 + (p_tau*Ycp).^2) ./ (2*p_sc^2));
Gs = exp(-(Xsp.^2 + (p_tau*Ysp).^2) ./ (2*p_ss^2));

DoGenv = p_Ac*Gc - p_As*Gs;

F = abs(fftshift(fft2(DoGenv))).^2;

fx = (-nx/2:nx/2-1)/nx;
fy = (-ny/2:ny/2-1)/ny;

[FX,FY] = meshgrid(fx,fy);

FR = sqrt(FX.^2 + FY.^2);

F(round(ny/2),round(nx/2)) = 0;

[~,idx] = max(F(:));

fPeakDoG = FR(idx);

disp(['carrier f = ' num2str(p_f)])
disp(['DoG peak f = ' num2str(fPeakDoG)])


subplot(2,3,4)
    imagesc(DoGenv)
    axis image
    colormap gray
    title('DoG envelope')

subplot(2,3,5)
    imagesc(log10(F+eps))
    axis image
    title(['FFT, fPeak=' num2str(fPeakDoG,'%0.3f')])


