clear; clc;

%% load data
load('Copy of i2761-250701_fastASD_examplecells.mat');

[T, P] = size(x);
[Ty, Ncells] = size(y);
x_white = zscore(x);   % whiten stimulus

if T ~= Ty
    error('ERROR: x and y must have SAME number of time samples.');
end

fprintf('Loaded: %d samples, %d pixels, %d neurons\n', T, P, Ncells);
fprintf('RF shape nks = [%s]\n', num2str(nks));


%% ASD parameters
minlens = [2 2];   % minimum length scale


%% Gabor fit options
options.shape = 'elliptical';
options.runs = 100;
options.parallel = false;
options.visualize = false;


%% storage
ASD_filters = cell(1, Ncells);
Gabor_filters = cell(1, Ncells);


%% process each neuron
%Ncells = 1;   % uncomment for test mode on first neuron only

for nn = 1:Ncells
    fprintf('\nNeuron %d / %d\n', nn, Ncells);

    ycell = y(:, nn);   % response vector

    fprintf('Running fastASD...\n');
    [k_asd, stats] = fastASD(x_white, ycell, nks, minlens);
    ASD = reshape(k_asd, nks);

    ASD_filters{nn} = ASD;

    RF = ASD_filters{nn};
    [ONmask, OFFmask, RFproc] = segmentRF(RF);   % segmentation

    fprintf('Fitting 2D Gabor...\n');
    try
        gfit = fit2dGabor(ASD, options);
        if isempty(gfit)
            warning('Gabor fit failed for neuron %d', nn);
            Gabor_filters{nn} = nan(size(ASD));
        else
            Gabor_filters{nn} = gfit.patch;
        end
    catch ME
        warning('fit2dGabor crashed for neuron %d: %s', nn, ME.message);
        Gabor_filters{nn} = nan(size(ASD));
    end

end


%% plot
figure('Name','ASD vs Gabor Fits','Color','w');
set(gcf,'Position',[100 100 1600 400]);

for nn = 1:Ncells
    subplot(2, Ncells, nn);
    ASD = ASD_filters{nn};
    imagesc(ASD);
    colormap(gca, gray);
    axis image off;
    title(sprintf('ASD %d', nn));

    subplot(2, Ncells, Ncells + nn);
    G = Gabor_filters{nn};
    imagesc(G);
    colormap(gca, gray);
    axis image off;
    title(sprintf('Gabor %d', nn));
end


%% output
save('ASD_Gabor_results.mat', 'ASD_filters', 'Gabor_filters');

fprintf('\nDONE. All ASD + Gabor filters computed and saved.\n');
