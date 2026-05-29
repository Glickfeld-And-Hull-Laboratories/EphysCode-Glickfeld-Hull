%%
close all; clear all

%% Test making plaids at one phase

[s2d_test0, p2d] = sin2d2(-15:0.1:15,10,deg2rad(0),90);
[s2d_mask120, p2d] = sin2d2(-15:0.1:15,10,deg2rad(0),210);

figure(1);
    subplot(1,3,1)
        imagesc(s2d_test0)
        colormap gray
        axis square
        axis off
        clim([-1 1])
        title('100% contrast')
    subplot(1,3,2)
        imagesc((s2d_test0+s2d_mask120).*0.5)
        colormap gray
        axis square
        axis off
        clim([-1 1])
        title('50% + 50% contrast')
    subplot(1,3,3)
        % Make Gaussian mask
            [x, y] = meshgrid(-15:0.1:15, -15:0.1:15);
            sigma = 5; % controls size of aperture
            gaussMask = exp(-(x.^2 + y.^2) / (2*sigma^2));
            gaussMask = gaussMask / max(gaussMask(:)); % normalize to [0 1]
        % Apply to plaid 
            plaid50 = (s2d_test0 + s2d_mask120) * 0.5;
            plaid50_gauss = plaid50 .* gaussMask;
        % Plot
            bg = .7; %0.7
            img = (plaid50_gauss+1)*bg; 
            imagesc(img)
            colormap gray
            axis square off
            set(gca, 'clim',[0 1.2])
            title('50% + 50% (Gaussian)')
     movegui('center')



%% Make 120 plaid for full 360 degrees of motion

% Grid
x = -15:0.1:15;
y = -15:0.1:15;
[X, Y] = meshgrid(x, y);

% Params
sf = 10;                         % spatial frequency
dir1 = deg2rad(-60);              % grating 1 direction
dir2 = deg2rad(60);             % grating 2 direction (offset by 120 deg)

phases = deg2rad(0:5:360);       % full phase cycle (time axis)
nPhase = length(phases);

% Initalize
plaidStack = zeros(length(y), length(x), nPhase);

% Loop over plaid phase
for ip = 1:nPhase
    
    ph = phases(ip);
    
    % Both gratings shift phase TOGETHER
    s1 = sin2d2(x, sf, ph, rad2deg(dir1));
    s2 = sin2d2(x, sf, ph, rad2deg(dir2));
    
    % Combine into plaid
    plaid = (s1 + s2) * 0.5;
    
    plaidStack(:,:,ip) = plaid;
end


% Check plaid drifts across time
figure;
for ip = 1:nPhase
    imagesc(plaidStack(:,:,ip))
    colormap gray
    axis square off
    clim([-1 1])
    title(['Phase ' num2str(rad2deg(phases(ip)))])
    drawnow
end


% Compute variance of individual pixels
varMap = var(plaidStack, 0, 3);

figure;
    imagesc(varMap)
    axis square
    axis off
    colorbar
    colormap parula   
    title('Pixel-wise variance across time')
    movegui('center')


%% Compare variance maps across plaid angles

% Grid (same as before)
x = -15:0.1:15;
y = -15:0.1:15;
[X, Y] = meshgrid(x, y);

% Params
sf = 10;
phases = deg2rad(0:5:360);
nPhase = length(phases);

% Define plaid angle separations
plaidAngles = [45 90 120 135];


for ia = 1:length(plaidAngles)
    
    ang = plaidAngles(ia);
    
    % Symmetric around 0 (like the 120 case: -60 / +60)
    dir1 = deg2rad(-ang/2);
    dir2 = deg2rad( ang/2);
    
    % Initialize stack
    plaidStack = zeros(length(y), length(x), nPhase);
    
    % Build plaid over phase
    for ip = 1:nPhase
        ph = phases(ip);
        s1 = sin2d2(x, sf, ph, rad2deg(dir1));
        s2 = sin2d2(x, sf, ph, rad2deg(dir2));
        plaid = (s1 + s2) * 0.5;
        plaidStack(:,:,ip) = plaid;
    end
    
    % Compute variance map
    varMap = var(plaidStack, 0, 3);
    
    % Plot plaid at first time point
    figure(4);
    subplot(2, 2, ia)
        imagesc(plaidStack(:,:,1))
        axis square off
        colormap gray
        clim([-1 1])
        title([num2str(ang) '° plaid'])
    
    % Variance plot
    figure(5);
    subplot(2, 2, ia)
        imagesc(varMap)
        axis square off
        colormap parula
        colorbar
        title('Variance')
end

figure(4);
    sgtitle('Plaids at different component angles')
    movegui('center')

figure(5);
    sgtitle('Pixel-wise variance across time for different plaid angles')
    movegui('center')




%% Unequal component speeds: 90 deg plaid

% Grid
x = -15:0.1:15;
y = -15:0.1:15;
[X, Y] = meshgrid(x, y);

% Params
sf = 10;
phases = deg2rad(0:5:360);
nPhase = length(phases);

% 90° plaid
ang = 90;
dir1 = deg2rad(-ang/2);
dir2 = deg2rad( ang/2);

% Speed conditions (relative to component 1)
speedFactors = [1 2 4 6];

figure;
for is = 1:length(speedFactors)
    
    sfac = speedFactors(is);
    
    % Initialize
    plaidStack = zeros(length(y), length(x), nPhase);
    
    % Build plaid
    for ip = 1:nPhase
        ph = phases(ip);
        % Component 1: baseline speed
        s1 = sin2d2(x, sf, ph, rad2deg(dir1));
        % Component 2: scaled speed
        s2 = sin2d2(x, sf, sfac*ph, rad2deg(dir2));

        plaid = (s1 + s2) * 0.5;
        plaidStack(:,:,ip) = plaid;
    end
    
    % Variance
    varMap = var(plaidStack, 0, 3);
    

    % Plot variance
    subplot(2, 2, is)
        imagesc(varMap)
        axis square off
        colormap parula
        colorbar
        subtitle(['Fast component, ' num2str(sfac) 'x'])
end

sgtitle('90° plaid: effect of unequal component speeds')
movegui('center')



%% Plaid spatial variance: all plaid angles with speed mismatch

% Grid
x = -15:0.1:15;
y = -15:0.1:15;
[X, Y] = meshgrid(x, y);

% Params
sf = 10;
phases = deg2rad(0:5:360);
nPhase = length(phases);

% Conditions
plaidAngles = [45 90 120 135 160];
speedFactors = [1 2 4 6];

figure;

for ia = 1:length(plaidAngles)
    
    ang = plaidAngles(ia);
    
    % Symmetric directions
    dir1 = deg2rad(-ang/2);
    dir2 = deg2rad( ang/2);
    
    for is = 1:length(speedFactors)
        
        sfac = speedFactors(is);
        
        % Initialize
        plaidStack = zeros(length(y), length(x), nPhase);
        
        % Build plaid over time
        for ip = 1:nPhase
            ph = phases(ip);
            
            % Component 1 (baseline)
            s1 = sin2d2(x, sf, ph, rad2deg(dir1));
            
            % Component 2 (faster)
            s2 = sin2d2(x, sf, sfac*ph, rad2deg(dir2));
            
            plaid = (s1 + s2) * 0.5;
            plaidStack(:,:,ip) = plaid;
        end
        
        % Variance
        varMap = var(plaidStack, 0, 3);
        
        % Optional normalization for fair comparison
        varMap = varMap / max(varMap(:));
        
        % Subplot index (row = angle, col = speed)
        idx = (ia-1)*length(speedFactors) + is;
        
        subplot(length(plaidAngles), length(speedFactors), idx)
            imagesc(varMap)
            axis square off
            colormap parula
            
            % Column titles (top row only)
            if ia == 1
                title([num2str(sfac) 'x speed'])
            end
            
            % Row labels (left column only)
            if is == 1
                ylabel([num2str(ang) '°'], 'Rotation', 0, 'HorizontalAlignment','right')
            end
    end
end

sgtitle('Plaid variance: angle (rows) x speed mismatch (columns)')
movegui('center')





%% ===== AVERAGING across time to look at mean images =====


%% Make 120 plaid for full 360 degrees of motion

% Grid
x = -15:0.1:15;
y = -15:0.1:15;
[X, Y] = meshgrid(x, y);

% Params
sf = 10;                         % spatial frequency
dir1 = deg2rad(-60);              % grating 1 direction
dir2 = deg2rad(60);             % grating 2 direction (offset by 120 deg)

phases = deg2rad(0:5:360);       % full phase cycle (time axis)
nPhase = length(phases);

% Initalize
plaidStack = zeros(length(y), length(x), nPhase);

% Loop over plaid phase
for ip = 1:nPhase
    
    ph = phases(ip);
    
    % Both gratings shift phase TOGETHER
    s1 = sin2d2(x, sf, ph, rad2deg(dir1));
    s2 = sin2d2(x, sf, ph, rad2deg(dir2));
    
    % Combine into plaid
    plaid = (s1 + s2) * 0.5;
    
    plaidStack(:,:,ip) = plaid;
end


% Compute variance of individual pixels
meanMap = mean(plaidStack(:,:,1:(180/5)), 3);

figure;
subplot 221
    imagesc(plaidStack(:,:,1))
    axis square
    axis off
    colorbar
    colormap gray   
    title('1st time point')
    movegui('center')
subplot 222
    imagesc(meanMap)
    axis square
    axis off
    colorbar
    clim([-1 1])
    colormap gray   
    title('Pixel-wise mean across 1/2 cycle')
    movegui('center')



%% Compare mean maps across plaid angles

% Grid (same as before)
x = -15:0.1:15;
y = -15:0.1:15;
[X, Y] = meshgrid(x, y);

% Params
sf = 10;
phases = deg2rad(0:5:360);
nPhase = length(phases);

% Define plaid angle separations
plaidAngles = [45 90 120 135];

figure;
for ia = 1:length(plaidAngles)
    
    ang = plaidAngles(ia);
    
    % Symmetric around 0 (like the 120 case: -60 / +60)
    dir1 = deg2rad(-ang/2);
    dir2 = deg2rad( ang/2);
    
    % Initialize stack
    plaidStack = zeros(length(y), length(x), nPhase);
    
    % Build plaid over phase
    for ip = 1:nPhase
        ph = phases(ip);
        s1 = sin2d2(x, sf, ph, rad2deg(dir1));
        s2 = sin2d2(x, sf, ph, rad2deg(dir2));
        plaid = (s1 + s2) * 0.5;
        plaidStack(:,:,ip) = plaid;
    end
    
    % Compute variance map
    meanMap = mean(plaidStack(:,:,1:(180/5)), 3);
 
    
    % Mean plot
    subplot(2, 3, ia)
        imagesc(meanMap)
        axis square off
        colormap gray
        clim([-1 1])
        colorbar
        subtitle([num2str(ang) ' plaid'])
end

    sgtitle('Pixel-wise mean across 1/2 cycle for different plaid angles')
    movegui('center')



%% Plaid pixel-wise means: all plaid angles with speed mismatch

% Grid
x = -15:0.1:15;
y = -15:0.1:15;
[X, Y] = meshgrid(x, y);

% Params
sf = 10;
phases = deg2rad(0:5:360);
nPhase = length(phases);

% Conditions
plaidAngles = [45 90 120 135 160];
speedFactors = [1 2 4 6];

figure;

for ia = 1:length(plaidAngles)
    
    ang = plaidAngles(ia);
    
    % Symmetric directions
    dir1 = deg2rad(-ang/2);
    dir2 = deg2rad( ang/2);
    
    for is = 1:length(speedFactors)
        
        sfac = speedFactors(is);
        
        % Initialize
        plaidStack = zeros(length(y), length(x), nPhase);
        
        % Build plaid over time
        for ip = 1:nPhase
            ph = phases(ip);
            
            % Component 1 (baseline)
            s1 = sin2d2(x, sf, ph, rad2deg(dir1));
            
            % Component 2 (faster)
            s2 = sin2d2(x, sf, sfac*ph, rad2deg(dir2));
            
            plaid = (s1 + s2) * 0.5;
            plaidStack(:,:,ip) = plaid;
        end
        
        % Variance
        meanMap = mean(plaidStack(:,:,1:(45/5)), 3);
        
        
        % Subplot index (row = angle, col = speed)
        idx = (ia-1)*length(speedFactors) + is;
        
        subplot(length(plaidAngles), length(speedFactors), idx)
            imagesc(meanMap)
            axis square off
            colormap gray
            clim([-1 1])
            
            % Column titles (top row only)
            if ia == 1
                title([num2str(sfac) 'x speed'])
            end
            
            % Row labels (left column only)
            if is == 1
                ylabel([num2str(ang) '°'], 'Rotation', 0, 'HorizontalAlignment','right')
            end
    end
end

sgtitle('Plaid mean: angle (rows) x speed mismatch (columns)')
movegui('center')

