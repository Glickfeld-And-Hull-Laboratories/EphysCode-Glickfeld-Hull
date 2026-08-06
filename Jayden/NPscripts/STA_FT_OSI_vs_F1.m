%% STA_FT_OSI_at_StimSF_vs_Experimental_OSI.m
clear;
close all;
clc;

%% ---------------- Settings ----------------
inFile = "RF_ML_dataset.mat";
outDir = "STA_FT_OSI_at_StimSF";

stimSF_cpd  = 0.05;   % experimental grating spatial frequency
degPerPixel = 2.0;    % visual degrees represented by one STA pixel

% Convert cycles/degree to cycles/pixel.
stimSF_cpp = stimSF_cpd*degPerPixel;

ampMode       = "amplitude";   % "amplitude" or "power"
padFactor     = 8;
useWindow     = true;
removeMean    = true;

% Width of the Fourier ring around the experimental SF.
% This is a half-width, so 0.015 uses approximately 0.085–0.115 cpp
% when stimSF_cpp = 0.1.
stimSFHalfWidth_cpp = 0.015;

% Cells with almost no Fourier amplitude in the stimulus-SF ring
% can have unstable OSI estimates.
minRingFraction = 0.01;

minRespSum = 1e-12;

if ~exist(outDir,'dir')
    mkdir(outDir);
end

fprintf('Experimental grating SF = %.4f cycles/degree\n',stimSF_cpd);
fprintf('STA scale               = %.4f degrees/pixel\n',degPerPixel);
fprintf('Matched Fourier SF      = %.4f cycles/pixel\n',stimSF_cpp);

%% ---------------- Load export ----------------
S = load(inFile);

assert(isfield(S,'STA_images'), ...
    'Missing STA_images in %s.',inFile);

STA_images = S.STA_images;

%% ---------------- Find response variable ----------------
% Prefer an explicitly exported F1 direction-tuning curve.
respCandidates = { ...
    'f1Dir_all_selected', ...
    'F1_dir_all_selected', ...
    'respF1_dir_all_selected', ...
    'respDir_all_selected'};

respName = "";

for i = 1:numel(respCandidates)
    if isfield(S,respCandidates{i})
        respName = string(respCandidates{i});
        break;
    end
end

assert(strlength(respName)>0, ...
    ['No direction-response matrix found. Export a variable such as ' ...
     'f1Dir_all_selected or respDir_all_selected.']);

respDir = double(S.(respName));

if respName == "respDir_all_selected"
    warning([ ...
        'Using respDir_all_selected. Confirm that this variable contains ' ...
        'experimental F1 amplitudes rather than mean responses.']);
end

%% ---------------- Arrange STA dimensions ----------------
% Expected export format:
% STA_images = nCells x height x width

if size(STA_images,1) == size(respDir,1)

    STA = double(STA_images);

elseif size(STA_images,3) == size(respDir,1)

    STA = permute(double(STA_images),[3 1 2]);

else

    error(['Cannot match STA_images to response cells. ' ...
        'STA size = %s; response size = %s.'], ...
        mat2str(size(STA_images)),mat2str(size(respDir)));

end

nCells   = size(STA,1);
ny       = size(STA,2);
nx       = size(STA,3);
nStimDir = size(respDir,2);

assert(mod(nStimDir,2)==0, ...
    'The number of stimulus directions must be even.');

assert(stimSF_cpp>0 && stimSF_cpp<0.5, ...
    ['stimSF_cpp must be between 0 and the Nyquist frequency of ' ...
     '0.5 cycles/pixel. Current value = %.4f.'],stimSF_cpp);

fprintf('\nLoaded %d cells.\n',nCells);
fprintf('STA size: %d x %d pixels.\n',ny,nx);
fprintf('Experimental response variable: %s\n',respName);

%% ---------------- Cell IDs ----------------
if isfield(S,'fittedCellIDs')

    cellID = S.fittedCellIDs(:);

elseif isfield(S,'cellIDs')

    cellID = S.cellIDs(:);

else

    cellID = (1:nCells)';

end

assert(numel(cellID)==nCells, ...
    'Number of cell IDs does not match number of STAs.');

%% ---------------- Direction angles ----------------
dirDeg = linspace(0,360,nStimDir+1);
dirDeg(end) = [];
dirRad = deg2rad(dirDeg);

nOri   = nStimDir/2;
oriDeg = dirDeg(1:nOri);

%% ---------------- Experimental OSI and DSI ----------------
expOSI_vec     = nan(nCells,1);
expDSI_vec     = nan(nCells,1);
expOSI_prefOrth = nan(nCells,1);
expDSI_prefNull = nan(nCells,1);

expPrefOriDeg = nan(nCells,1);
expPrefDirDeg = nan(nCells,1);
expRespSum    = nan(nCells,1);

for ic = 1:nCells

    r = double(respDir(ic,:));

    r(~isfinite(r)) = 0;
    r(r<0) = 0;

    rsum = sum(r);
    expRespSum(ic) = rsum;

    if rsum<=minRespSum
        continue;
    end

    %% Vector DSI
    zDir = sum(r.*exp(1i*dirRad));

    expDSI_vec(ic) = abs(zDir)/rsum;
    expPrefDirDeg(ic) = mod(rad2deg(angle(zDir)),360);

    %% Vector OSI
    zOri = sum(r.*exp(2i*dirRad));

    expOSI_vec(ic) = abs(zOri)/rsum;
    expPrefOriDeg(ic) = mod(rad2deg(angle(zOri))/2,180);

    %% Preferred-null DSI
    [RprefDir,prefDirInd] = max(r);

    nullInd = prefDirInd+nOri;

    if nullInd>nStimDir
        nullInd = nullInd-nStimDir;
    end

    Rnull = r(nullInd);

    if RprefDir+Rnull>0
        expDSI_prefNull(ic) = ...
            (RprefDir-Rnull)/(RprefDir+Rnull);
    end

    %% Preferred-orthogonal OSI
    rOri = (r(1:nOri)+r(nOri+1:end))/2;

    [RprefOri,prefOriInd] = max(rOri);

    orthInd = prefOriInd+nStimDir/4;

    if orthInd>nOri
        orthInd = orthInd-nOri;
    end

    Rorth = rOri(orthInd);

    if RprefOri+Rorth>0
        expOSI_prefOrth(ic) = ...
            (RprefOri-Rorth)/(RprefOri+Rorth);
    end

end

%% ---------------- Fourier coordinates ----------------
nfft = 2^nextpow2(max(nx,ny)*padFactor);

fx = (-nfft/2:nfft/2-1)/nfft;
fy = (-nfft/2:nfft/2-1)/nfft;

[kx,ky] = meshgrid(fx,fy);

kr     = hypot(kx,ky);
ktheta = atan2(ky,kx);

% Ring corresponding to the experimental grating SF.
stimRingMask = ...
    kr >= stimSF_cpp-stimSFHalfWidth_cpp & ...
    kr <= stimSF_cpp+stimSFHalfWidth_cpp;

% Exclude frequencies beyond the spatial Nyquist limit.
validFTMask = kr>0 & kr<=0.5;

stimRingMask = stimRingMask & validFTMask;

assert(any(stimRingMask(:)), ...
    ['No FFT pixels fall inside the requested SF ring. Increase ' ...
     'padFactor or stimSFHalfWidth_cpp.']);

fprintf('\nFFT size                  = %d x %d\n',nfft,nfft);
fprintf('Fourier frequency step    = %.6f cycles/pixel\n',1/nfft);
fprintf('Stimulus-SF ring          = %.4f to %.4f cycles/pixel\n', ...
    stimSF_cpp-stimSFHalfWidth_cpp, ...
    stimSF_cpp+stimSFHalfWidth_cpp);

%% ---------------- STA window ----------------
if useWindow

    wx = localHann(nx);
    wy = localHann(ny);
    win2 = wy*wx';

else

    win2 = ones(ny,nx);

end

%% ---------------- STA Fourier OSI ----------------
STA_OSI_stimSF      = nan(nCells,1);
STA_prefOriDeg      = nan(nCells,1);
STA_ringAmplitude   = nan(nCells,1);
STA_totalAmplitude  = nan(nCells,1);
STA_ringFraction    = nan(nCells,1);
STA_energy          = nan(nCells,1);
STA_reliableRing    = false(nCells,1);

for ic = 1:nCells

    rf = squeeze(STA(ic,:,:));

    rf(~isfinite(rf)) = 0;

    if removeMean
        rf = rf-mean(rf(:));
    end

    rf = rf.*win2;

    STA_energy(ic) = sum(rf(:).^2);

    if STA_energy(ic)<=eps
        continue;
    end

    F = fftshift(fft2(rf,nfft,nfft));

    switch ampMode

        case "amplitude"
            W = abs(F);

        case "power"
            W = abs(F).^2;

        otherwise
            error('ampMode must be "amplitude" or "power".');

    end

    W(~validFTMask) = 0;

    totalAmp = sum(W(:));
    ringAmp  = sum(W(stimRingMask));

    STA_totalAmplitude(ic) = totalAmp;
    STA_ringAmplitude(ic)  = ringAmp;

    if totalAmp<=eps || ringAmp<=eps
        continue;
    end

    STA_ringFraction(ic) = ringAmp/totalAmp;

    % Orientation vector from Fourier amplitudes at the matched SF.
    z2 = sum(W(stimRingMask).*exp(2i*ktheta(stimRingMask))) ...
        /ringAmp;

    STA_OSI_stimSF(ic) = abs(z2);

    % Fourier orientation indicates the direction of the spatial-frequency
    % vector. The receptive-field/bar orientation is perpendicular to it.
    STA_prefOriDeg(ic) = ...
        mod(rad2deg(angle(z2))/2+90,180);

    STA_reliableRing(ic) = ...
        STA_ringFraction(ic)>=minRingFraction;

end

%% ---------------- Orientation error ----------------
oriErrorDeg = oriDiff180(STA_prefOriDeg,expPrefOriDeg);

%% ---------------- Existing exported values ----------------
exportedOSI = nan(nCells,1);
exportedDSI = nan(nCells,1);
F1F0        = nan(nCells,1);
prefFR      = nan(nCells,1);

if isfield(S,'OSI') && numel(S.OSI)==nCells
    exportedOSI = S.OSI(:);
end

if isfield(S,'DSI') && numel(S.DSI)==nCells
    exportedDSI = S.DSI(:);
end

if isfield(S,'F1F0') && numel(S.F1F0)==nCells
    F1F0 = S.F1F0(:);
end

if isfield(S,'prefFR') && numel(S.prefFR)==nCells
    prefFR = S.prefFR(:);
end

%% ---------------- Statistics: all valid cells ----------------
stats = struct;

stats.stimSF_vs_vectorOSI_all = correlationStats( ...
    STA_OSI_stimSF,expOSI_vec);

stats.stimSF_vs_prefOrthOSI_all = correlationStats( ...
    STA_OSI_stimSF,expOSI_prefOrth);

%% ---------------- Statistics: reliable SF-ring cells ----------------
validReliable = STA_reliableRing;

stats.stimSF_vs_vectorOSI_reliable = correlationStats( ...
    setInvalid(STA_OSI_stimSF,~validReliable), ...
    setInvalid(expOSI_vec,~validReliable));

stats.stimSF_vs_prefOrthOSI_reliable = correlationStats( ...
    setInvalid(STA_OSI_stimSF,~validReliable), ...
    setInvalid(expOSI_prefOrth,~validReliable));

fprintf('\nSTA OSI at stimulus SF vs experimental vector OSI:\n');
fprintf('All valid cells:\n');
printStats(stats.stimSF_vs_vectorOSI_all);

fprintf('\nReliable SF-ring cells only:\n');
printStats(stats.stimSF_vs_vectorOSI_reliable);

fprintf('\nSTA OSI at stimulus SF vs preferred-orthogonal OSI:\n');
fprintf('All valid cells:\n');
printStats(stats.stimSF_vs_prefOrthOSI_all);

fprintf('\nReliable SF-ring cells only:\n');
printStats(stats.stimSF_vs_prefOrthOSI_reliable);

fprintf('\nReliable SF-ring cells: %d / %d\n', ...
    sum(STA_reliableRing),nCells);

%% ---------------- Output table ----------------
results = table( ...
    cellID, ...
    STA_OSI_stimSF, ...
    STA_prefOriDeg, ...
    STA_ringAmplitude, ...
    STA_totalAmplitude, ...
    STA_ringFraction, ...
    STA_reliableRing, ...
    expOSI_vec, ...
    expDSI_vec, ...
    expOSI_prefOrth, ...
    expDSI_prefNull, ...
    expPrefOriDeg, ...
    expPrefDirDeg, ...
    oriErrorDeg, ...
    exportedOSI, ...
    exportedDSI, ...
    F1F0, ...
    prefFR, ...
    expRespSum, ...
    STA_energy);

writetable(results,fullfile(outDir, ...
    'STA_FT_OSI_at_StimSF_vs_experimental_OSI.csv'));

save(fullfile(outDir, ...
    'STA_FT_OSI_at_StimSF_vs_experimental_OSI.mat'), ...
    'results','stats','dirDeg','oriDeg', ...
    'stimSF_cpd','degPerPixel','stimSF_cpp', ...
    'stimSFHalfWidth_cpp','minRingFraction', ...
    'respName','ampMode','padFactor','useWindow','removeMean');

%% ---------------- Figure 1: matched vector OSI ----------------
plotComparison( ...
    STA_OSI_stimSF, ...
    expOSI_vec, ...
    STA_reliableRing, ...
    sprintf('STA Fourier OSI at %.2f cpd',stimSF_cpd), ...
    sprintf('Experimental vector OSI at %.2f cpd',stimSF_cpd), ...
    stats.stimSF_vs_vectorOSI_reliable);

exportgraphics(gcf,fullfile(outDir, ...
    'STA_StimSF_OSI_vs_experimental_vector_OSI.pdf'), ...
    'ContentType','vector');

%% ---------------- Figure 2: preferred-orthogonal OSI ----------------
plotComparison( ...
    STA_OSI_stimSF, ...
    expOSI_prefOrth, ...
    STA_reliableRing, ...
    sprintf('STA Fourier OSI at %.2f cpd',stimSF_cpd), ...
    sprintf('Experimental preferred-orthogonal OSI at %.2f cpd', ...
    stimSF_cpd), ...
    stats.stimSF_vs_prefOrthOSI_reliable);

exportgraphics(gcf,fullfile(outDir, ...
    'STA_StimSF_OSI_vs_experimental_prefOrth_OSI.pdf'), ...
    'ContentType','vector');

%% ---------------- Figure 3: distributions ----------------
valid = STA_reliableRing & ...
    isfinite(STA_OSI_stimSF) & ...
    isfinite(expOSI_vec);

figure('Color','w','Position',[100 100 700 520]);
hold on;

edges = linspace(0,1,21);

histogram(STA_OSI_stimSF(valid),edges, ...
    'DisplayStyle','stairs','LineWidth',1.5);

histogram(expOSI_vec(valid),edges, ...
    'DisplayStyle','stairs','LineWidth',1.5);

xlabel('OSI');
ylabel('Number of cells');

legend({ ...
    sprintf('STA Fourier OSI at %.2f cpd',stimSF_cpd), ...
    sprintf('Experimental vector OSI at %.2f cpd',stimSF_cpd)}, ...
    'Location','best');

title(sprintf('Matched-SF OSI distributions, n = %d',sum(valid)));

xlim([0 1]);
box off;

exportgraphics(gcf,fullfile(outDir, ...
    'STA_and_experimental_matchedSF_OSI_distributions.pdf'), ...
    'ContentType','vector');

%% ---------------- Figure 4: orientation error ----------------
validOri = STA_reliableRing & isfinite(oriErrorDeg);

figure('Color','w','Position',[100 100 700 520]);

histogram(oriErrorDeg(validOri),0:5:90);

xlabel('STA versus experimental orientation error (deg)');
ylabel('Number of cells');

title(sprintf( ...
    'Matched-SF orientation error: median = %.1f deg, n = %d', ...
    median(oriErrorDeg(validOri),'omitnan'),sum(validOri)));

xlim([0 90]);
box off;

exportgraphics(gcf,fullfile(outDir, ...
    'STA_vs_experimental_matchedSF_orientation_error.pdf'), ...
    'ContentType','vector');

%% ---------------- Figure 5: ring fraction diagnostic ----------------
figure('Color','w','Position',[100 100 700 520]);

histogram(STA_ringFraction(isfinite(STA_ringFraction)),30);

hold on;
xline(minRingFraction,'k--','LineWidth',1.5);

xlabel(sprintf( ...
    'Fraction of STA Fourier amplitude near %.2f cpd',stimSF_cpd));

ylabel('Number of cells');

title(sprintf( ...
    'Stimulus-SF Fourier energy, reliable = %d/%d', ...
    sum(STA_reliableRing),nCells));

box off;

exportgraphics(gcf,fullfile(outDir, ...
    'STA_StimSF_ring_fraction_diagnostic.pdf'), ...
    'ContentType','vector');

fprintf('\nSaved results to:\n%s\n',fullfile(pwd,outDir));

%% ============================================================
% Local functions
%% ============================================================

function w = localHann(n)

if n<=1
    w = ones(n,1);
else
    x = (0:n-1)';
    w = 0.5-0.5*cos(2*pi*x/(n-1));
end

end

function d = oriDiff180(a,b)

d = abs(mod(a-b+90,180)-90);

end

function x = setInvalid(x,idx)

x(idx) = nan;

end

function s = correlationStats(x,y)

valid = isfinite(x) & isfinite(y);

s.n = sum(valid);
s.pearsonR  = nan;
s.pearsonP  = nan;
s.spearmanR = nan;
s.spearmanP = nan;
s.slope     = nan;
s.intercept = nan;
s.R2        = nan;

if s.n<3
    return;
end

xv = x(valid);
yv = y(valid);

[s.pearsonR,s.pearsonP] = corr( ...
    xv,yv,'Type','Pearson','Rows','complete');

[s.spearmanR,s.spearmanP] = corr( ...
    xv,yv,'Type','Spearman','Rows','complete');

p = polyfit(xv,yv,1);

s.slope     = p(1);
s.intercept = p(2);

yhat = polyval(p,xv);

SSE = sum((yv-yhat).^2);
SST = sum((yv-mean(yv)).^2);

if SST>0
    s.R2 = 1-SSE/SST;
end

end

function printStats(s)

fprintf('  n          = %d\n',s.n);
fprintf('  Pearson r  = %.3f, p = %.3g\n', ...
    s.pearsonR,s.pearsonP);
fprintf('  Spearman r = %.3f, p = %.3g\n', ...
    s.spearmanR,s.spearmanP);
fprintf('  Linear R2  = %.3f\n',s.R2);

end

function plotComparison(x,y,reliable,xlab,ylab,s)

valid = reliable & isfinite(x) & isfinite(y);

xv = x(valid);
yv = y(valid);

figure('Color','w','Position',[100 100 700 580]);

scatter(xv,yv,32,'filled', ...
    'MarkerFaceAlpha',0.55);

hold on;

plot([0 1],[0 1],'k--','LineWidth',1);

if numel(xv)>=2 && isfinite(s.slope)

    xx = linspace(0,1,200);
    yy = s.intercept+s.slope*xx;

    plot(xx,yy,'k-','LineWidth',1.5);

end

xlabel(xlab);
ylabel(ylab);

xlim([0 1]);
ylim([0 1]);

axis square;
box off;

title(sprintf( ...
    'n = %d, Pearson r = %.2f, Spearman r = %.2f', ...
    s.n,s.pearsonR,s.spearmanR));

end