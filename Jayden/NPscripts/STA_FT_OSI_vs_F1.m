%% STA_denoised_predict_measured_fourPhase_plaid.m
clear;
close all;
clc;

% ============================================================
% Goal
% ============================================================
% Test whether each denoised V1 STA predicts that same cell's measured
% responses to 120-deg plaids at four spatial phases.
%
% The model is calibrated using measured GRATING responses only:
%   1. choose direction-axis convention from grating tuning;
%   2. fit one gain and offset from predicted to measured grating responses;
%   3. hold those parameters fixed and predict all 48 plaid responses.
%
% No measured plaid response is used in the primary prediction. A separate
% best-phase-aligned result is reported only as a coordinate-reference
% diagnostic and must not be interpreted as an out-of-sample prediction.
%
% FFT controls:
%   - full complex FFT projection: must match the spatial dot product;
%   - Hann-windowed FFT ring at the experimental SF: grating-only,
%     phase-free orientation diagnostic (not a four-phase plaid predictor).

%% ---------------- Settings ----------------
rfFile = "RF_ML_dataset.mat";
plaidFile = "CrossOri_randDirFourPhase_summary.mat";
outDir = "STA_denoised_vs_measured_fourPhase_plaid";

degPerPixel = 2;
SF = 0.05;
contrast = 0.5;
nTime = 48;

dirDeg = 0:30:330;
phaseDeg = [0 90 180 270];
plaidAngleDeg = 120;

smoothSigmaPix = 1;
maskThresholdSigma = 2.5;
minSTAenergy = 1e-10;
minValidPoints = 6;

% Grating-only output-nonlinearity grid for predicting mean/DC responses.
thresholdFractionGrid = -0.5:0.1:0.8;
exponentGrid = [1 1.5 2];

% Candidate variable names. Add the exact lab variable here if needed.
staCandidates = {'STA_images','STA','staImages'};
respCandidates = {'avg_resp_dir_all','avg_resp_dir', ...
    'avg_resp_dir_all_selected','avgRespDir'};
f1RespCandidates = {'F1_resp_dir_all','f1_resp_dir_all', ...
    'avg_F1_dir_all','F1_dir_all','f1Dir_all'};
staIDCandidates = {'fittedCellIDs','cellIDs','cellID'};
respIDCandidates = {'cellIDs','allCellIDs','cellID','totCellIDs'};

if ~exist(outDir,'dir'), mkdir(outDir); end
assert(isfile(rfFile),'RF file not found: %s',rfFile);
% assert(isfile(plaidFile),['Plaid-response file not found: %s\nEdit ' ...
%     'plaidFile at the top of the wrapper. If both datasets are stored in ' ...
%     'one MAT file, explicitly set plaidFile = rfFile.'],plaidFile);

%% ---------------- Load and identify variables ----------------
R = load(rfFile);

analysisDir=('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\sara\Analysis\Neuropixel\CrossOri\randDirFourPhase');
P = load([analysisDir '\CrossOri_randDirFourPhase_summary.mat']);


[staRaw,staName] = findField(R,staCandidates);
[respRaw,respName] = findField(P,respCandidates);
[f1RespRaw,f1RespName] = findField(P,f1RespCandidates);

if strlength(staName)==0
    [staRaw,staName] = autoFindSTA(R);
end

if strlength(respName)==0
    [respRaw,respName] = autoFindResponseTensor(P, ...
        numel(dirDeg),numel(phaseDeg));
end

assert(strlength(staName)>0,'No three-dimensional STA array found in %s.', ...
    rfFile);

if strlength(respName)==0
    error(['No compatible response tensor found in %s. Expected cells x ' ...
        '%d directions x %d phases x grating/plaid x mean/std.\n' ...
        'Variables in the selected file:\n%s'],plaidFile,numel(dirDeg), ...
        numel(phaseDeg),variableInventory(P));
end

respRaw = double(respRaw);
assert(ndims(respRaw)>=4,['Measured response tensor must be cells x ' ...
    'directions x phases x grating/plaid x mean/std. Size: %s'], ...
    mat2str(size(respRaw)));

if ndims(respRaw)==4
    respRaw = reshape(respRaw,[size(respRaw) 1]);
end

assert(size(respRaw,2)==numel(dirDeg),'Expected %d directions; found %d.', ...
    numel(dirDeg),size(respRaw,2));
assert(size(respRaw,3)==numel(phaseDeg),'Expected %d phases; found %d.', ...
    numel(phaseDeg),size(respRaw,3));
assert(size(respRaw,4)>=2,'Dimension 4 must contain grating and plaid.');

[staID,staIDName] = findField(R,staIDCandidates);
[respID,respIDName] = findField(P,respIDCandidates);
STA = arrangeSTA(double(staRaw),staID);
nSTA = size(STA,1);
nResp = size(respRaw,1);

%% ---------------- Align cells ----------------
[staIdx,respIdx,cellID,alignmentMethod] = alignCells( ...
    R,P,STA,staID,respID,nSTA,nResp);

STA = STA(staIdx,:,:);
measuredTensor = respRaw(respIdx,:,:,:,:);
nCells = numel(staIdx);

fprintf('STA variable: %s; response variable: %s\n',staName,respName);
fprintf('STA IDs: %s; response IDs: %s\n',staIDName,respIDName);
fprintf('Aligned %d cells using %s.\n',nCells,alignmentMethod);

% Mean response is index 1 of the final dimension.
measuredGrating = squeeze(mean(measuredTensor(:,:,:,1,1),3,'omitnan'));
measuredPlaid = squeeze(measuredTensor(:,:,:,2,1));

hasMeasuredF1 = strlength(f1RespName)>0;
measuredF1Grating = [];
measuredF1Plaid = [];

if hasMeasuredF1
    f1RespRaw = double(f1RespRaw);
    if ndims(f1RespRaw)==4
        f1RespRaw = reshape(f1RespRaw,[size(f1RespRaw) 1]);
    end

    if ndims(f1RespRaw)>=5 && size(f1RespRaw,1)==nResp && ...
            size(f1RespRaw,2)==numel(dirDeg) && ...
            size(f1RespRaw,3)==numel(phaseDeg) && size(f1RespRaw,4)>=2
        f1Tensor = f1RespRaw(respIdx,:,:,:,:);
        measuredF1Grating = squeeze(mean(f1Tensor(:,:,:,1,1),3,'omitnan'));
        measuredF1Plaid = squeeze(f1Tensor(:,:,:,2,1));
    else
        warning(['Found %s, but its size %s is not compatible with the ' ...
            'five-dimensional response format. F1 validation is skipped.'], ...
            f1RespName,mat2str(size(f1RespRaw)));
        hasMeasuredF1 = false;
    end
end

if nCells==1
    measuredGrating = reshape(measuredGrating,1,[]);
    measuredPlaid = reshape(measuredPlaid,1,numel(dirDeg),numel(phaseDeg));
    if hasMeasuredF1
        measuredF1Grating = reshape(measuredF1Grating,1,[]);
        measuredF1Plaid = reshape(measuredF1Plaid,1,numel(dirDeg), ...
            numel(phaseDeg));
    end
end

%% ---------------- Coordinates and denoising ----------------
ny = size(STA,2);
nx = size(STA,3);
x = ((1:nx)-(nx+1)/2)*degPerPixel;
y = ((1:ny)-(ny+1)/2)*degPerPixel;
[xx,yy] = meshgrid(x,y);

STAdenoised = nan(size(STA));
for ic = 1:nCells
    STAdenoised(ic,:,:) = denoiseSTA(squeeze(STA(ic,:,:)), ...
        smoothSigmaPix,maskThresholdSigma);
end


%% ---------------- Predict responses from each STA ----------------
predGratingBase = nan(nCells,numel(dirDeg));
predPlaidBase = nan(nCells,numel(dirDeg),numel(phaseDeg));
gratingDriveBase = nan(nCells,numel(dirDeg),nTime);
plaidDriveBase = nan(nCells,numel(dirDeg),numel(phaseDeg),nTime);
fftGratingDriveBase = nan(nCells,numel(dirDeg),nTime);
fftPlaidDriveBase = nan(nCells,numel(dirDeg),numel(phaseDeg),nTime);
fftRingGratingBase = nan(nCells,numel(dirDeg));

for ic = 1:nCells
    rf = squeeze(STAdenoised(ic,:,:));
    rf(~isfinite(rf)) = 0;
    rf = rf-mean(rf(:));

    if sum(rf(:).^2)<=minSTAenergy, continue; end
    rf = rf/max(sum(abs(rf(:))),eps);
    rfFFT = fft2(rf);
    fftRingGratingBase(ic,:) = fftRingTuning(rf,degPerPixel,SF,dirDeg);

    for id = 1:numel(dirDeg)
        patternDir = dirDeg(id);
        comp1Dir = mod(patternDir-plaidAngleDeg/2,360);
        comp2Dir = mod(patternDir+plaidAngleDeg/2,360);

        grating = makeGrating(xx,yy,SF,patternDir,0,contrast,nTime);
        gratingDrive = runLinearSTA(rf,grating);
        gratingDriveBase(ic,id,:) = gratingDrive;
        fftGratingDriveBase(ic,id,:) = runFFTSTA(rfFFT,grating);
        predGratingBase(ic,id) = getF1(gratingDrive);

        for ip = 1:numel(phaseDeg)
            comp1 = makeGrating(xx,yy,SF,comp1Dir,0,contrast,nTime);
            comp2 = makeGrating(xx,yy,SF,comp2Dir,phaseDeg(ip), ...
                contrast,nTime);
            plaidDrive = runLinearSTA(rf,comp1+comp2);
            plaidDriveBase(ic,id,ip,:) = plaidDrive;
            fftPlaidDriveBase(ic,id,ip,:) = runFFTSTA(rfFFT,comp1+comp2);
            predPlaidBase(ic,id,ip) = getF1(plaidDrive);
        end
    end
end

%% ---------------- Grating-only calibration ----------------
[predGratingMapped,predPlaidMapped,globalDirectionShift, ...
    globalDirectionReversed] = alignGlobalDirectionFromGrating( ...
    predGratingBase,predPlaidBase,measuredGrating,minValidPoints);
initialMeanGrating = squeeze(mean(max(0,gratingDriveBase),3,'omitnan'));
initialMeanPlaid = squeeze(mean(max(0,plaidDriveBase),4,'omitnan'));
[~,~,meanGlobalDirectionShift,meanGlobalDirectionReversed] = ...
    alignGlobalDirectionFromGrating(initialMeanGrating,initialMeanPlaid, ...
    measuredGrating,minValidPoints);
gratingDriveMapped = applyDirectionMapping(gratingDriveBase, ...
    meanGlobalDirectionShift,meanGlobalDirectionReversed);
plaidDriveMapped = applyDirectionMapping(plaidDriveBase, ...
    meanGlobalDirectionShift,meanGlobalDirectionReversed);

predGrating = nan(size(predGratingBase));
predPlaidStrict = nan(size(predPlaidBase));
predPlaidPhaseAligned = nan(size(predPlaidBase));

directionShift = nan(nCells,1);
directionReversed = false(nCells,1);
gain = nan(nCells,1);
offset = nan(nCells,1);
gratingR = nan(nCells,1);
plaidRStrict = nan(nCells,1);
plaidRPhaseAligned = nan(nCells,1);
plaidNRMSEStrict = nan(nCells,1);
plaidNRMSEPhaseAligned = nan(nCells,1);
bestPhaseShift = nan(nCells,1);
bestPhaseReversed = false(nCells,1);
measuredPhaseAmp = nan(nCells,1);
predictedPhaseAmp = nan(nCells,1);

for ic = 1:nCells
    baseG = predGratingMapped(ic,:);
    baseP = squeeze(predPlaidMapped(ic,:,:));
    measG = measuredGrating(ic,:);
    measP = squeeze(measuredPlaid(ic,:,:));

    mappedG = baseG;
    mappedP = baseP;
    directionShift(ic) = globalDirectionShift;
    directionReversed(ic) = globalDirectionReversed;

    [gain(ic),offset(ic)] = fitGainOffset(mappedG,measG);
    predGrating(ic,:) = offset(ic)+gain(ic)*mappedG;
    predPlaidStrict(ic,:,:) = offset(ic)+gain(ic)*mappedP;

    gratingR(ic) = pairCorr(predGrating(ic,:),measG,minValidPoints);
    plaidRStrict(ic) = pairCorr(predPlaidStrict(ic,:,:),measP, ...
        minValidPoints);
    plaidNRMSEStrict(ic) = normalizedRMSE(predPlaidStrict(ic,:,:),measP);

    [alignedP,phaseShift,isPhaseReversed] = diagnosticPhaseAlignment( ...
        squeeze(predPlaidStrict(ic,:,:)),measP,minValidPoints);
    predPlaidPhaseAligned(ic,:,:) = alignedP;
    bestPhaseShift(ic) = phaseShift;
    bestPhaseReversed(ic) = isPhaseReversed;
    plaidRPhaseAligned(ic) = pairCorr(alignedP,measP,minValidPoints);
    plaidNRMSEPhaseAligned(ic) = normalizedRMSE(alignedP,measP);

    predictedPhaseAmp(ic) = meanPhaseModulation( ...
        squeeze(predPlaidStrict(ic,:,:)),phaseDeg);
    measuredPhaseAmp(ic) = meanPhaseModulation(measP,phaseDeg);
end

%% ---------------- Matched mean/DC prediction ----------------
% The response tensor contains cycle-mean/DC responses. The legacy branch
% above compares temporal F1 with those means, so it is retained only as a
% mismatch control. Here the output nonlinearity is fitted using measured
% GRATING means only and then frozen for all plaid predictions.
predMeanGrating = nan(size(measuredGrating));
predMeanPlaid = nan(size(measuredPlaid));
predMeanPlaidPhaseAligned = nan(size(measuredPlaid));
meanThreshold = nan(nCells,1);
meanExponent = nan(nCells,1);
meanGain = nan(nCells,1);
meanOffset = nan(nCells,1);
meanGratingR = nan(nCells,1);
meanPlaidRStrict = nan(nCells,1);
meanPlaidRPhaseAligned = nan(nCells,1);
meanPlaidNRMSEStrict = nan(nCells,1);
meanPredictedPhaseAmp = nan(nCells,1);
meanMeasuredPhaseAmp = nan(nCells,1);

for ic = 1:nCells
    [gHat,pHat,meanThreshold(ic),meanExponent(ic),meanGain(ic), ...
        meanOffset(ic)] = fitRectifiedMeanModel( ...
        squeeze(gratingDriveMapped(ic,:,:)), ...
        squeeze(plaidDriveMapped(ic,:,:,:)),measuredGrating(ic,:), ...
        thresholdFractionGrid,exponentGrid);
    predMeanGrating(ic,:) = gHat;
    predMeanPlaid(ic,:,:) = pHat;
    meanGratingR(ic) = pairCorr(gHat,measuredGrating(ic,:),minValidPoints);
    meanPlaidRStrict(ic) = pairCorr(pHat,squeeze(measuredPlaid(ic,:,:)), ...
        minValidPoints);
    meanPlaidNRMSEStrict(ic) = normalizedRMSE(pHat, ...
        squeeze(measuredPlaid(ic,:,:)));
    [pAligned,~,~] = diagnosticPhaseAlignment(pHat, ...
        squeeze(measuredPlaid(ic,:,:)),minValidPoints);
    predMeanPlaidPhaseAligned(ic,:,:) = pAligned;
    meanPlaidRPhaseAligned(ic) = pairCorr(pAligned, ...
        squeeze(measuredPlaid(ic,:,:)),minValidPoints);
    meanPredictedPhaseAmp(ic) = meanPhaseModulation(pHat,phaseDeg);
    meanMeasuredPhaseAmp(ic) = meanPhaseModulation( ...
        squeeze(measuredPlaid(ic,:,:)),phaseDeg);
end

%% ---------------- FFT comparisons ----------------
% Full complex FFT projection is Parseval-equivalent to the spatial dot
% product and therefore should reproduce the same temporal drive. This is
% an implementation check, not a different biological model.
fftInitialMeanG = squeeze(mean(max(0,fftGratingDriveBase),3,'omitnan'));
fftInitialMeanP = squeeze(mean(max(0,fftPlaidDriveBase),4,'omitnan'));
[~,~,fftGlobalDirectionShift,fftGlobalDirectionReversed] = ...
    alignGlobalDirectionFromGrating(fftInitialMeanG,fftInitialMeanP, ...
    measuredGrating,minValidPoints);
fftGratingDriveMapped = applyDirectionMapping(fftGratingDriveBase, ...
    fftGlobalDirectionShift,fftGlobalDirectionReversed);
fftPlaidDriveMapped = applyDirectionMapping(fftPlaidDriveBase, ...
    fftGlobalDirectionShift,fftGlobalDirectionReversed);

predFFTMeanGrating = nan(size(measuredGrating));
predFFTMeanPlaid = nan(size(measuredPlaid));
fftMeanGratingR = nan(nCells,1);
fftMeanPlaidRStrict = nan(nCells,1);
fftMeanPlaidNRMSEStrict = nan(nCells,1);

for ic = 1:nCells
    [gHat,pHat] = fitRectifiedMeanModel( ...
        squeeze(fftGratingDriveMapped(ic,:,:)), ...
        squeeze(fftPlaidDriveMapped(ic,:,:,:)),measuredGrating(ic,:), ...
        thresholdFractionGrid,exponentGrid);
    predFFTMeanGrating(ic,:) = gHat;
    predFFTMeanPlaid(ic,:,:) = pHat;
    fftMeanGratingR(ic) = pairCorr(gHat,measuredGrating(ic,:),minValidPoints);
    fftMeanPlaidRStrict(ic) = pairCorr(pHat, ...
        squeeze(measuredPlaid(ic,:,:)),minValidPoints);
    fftMeanPlaidNRMSEStrict(ic) = normalizedRMSE(pHat, ...
        squeeze(measuredPlaid(ic,:,:)));
end

spatialFFTDriveMaxError = max(abs(gratingDriveBase(:)- ...
    fftGratingDriveBase(:)),[],'omitnan');
spatialFFTPlaidDriveMaxError = max(abs(plaidDriveBase(:)- ...
    fftPlaidDriveBase(:)),[],'omitnan');

% Hann-windowed FFT-ring magnitude is retained as an orientation-tuning
% diagnostic. Because it discards complex phase, it cannot distinguish the
% four plaid spatial phases and is intentionally not used for plaid prediction.
[fftRingMapped,~,fftRingDirectionShift,fftRingDirectionReversed] = ...
    alignGlobalDirectionFromGrating(fftRingGratingBase, ...
    repmat(fftRingGratingBase,1,1,numel(phaseDeg)), ...
    measuredGrating,minValidPoints);
predFFTRingGrating = nan(size(measuredGrating));
fftRingGratingR = nan(nCells,1);
for ic = 1:nCells
    [g,o] = fitGainOffset(fftRingMapped(ic,:),measuredGrating(ic,:));
    predFFTRingGrating(ic,:) = o+g*fftRingMapped(ic,:);
    fftRingGratingR(ic) = pairCorr(predFFTRingGrating(ic,:), ...
        measuredGrating(ic,:),minValidPoints);
end

%% ---------------- Optional matched F1 prediction ----------------
f1GratingR = nan(nCells,1);
f1PlaidRStrict = nan(nCells,1);
f1PlaidNRMSEStrict = nan(nCells,1);
predF1Grating = nan(size(measuredGrating));
predF1Plaid = nan(size(measuredPlaid));
f1GlobalDirectionShift = nan;
f1GlobalDirectionReversed = false;

if hasMeasuredF1
    [f1BaseG,f1BaseP,f1GlobalDirectionShift, ...
        f1GlobalDirectionReversed] = alignGlobalDirectionFromGrating( ...
        predGratingBase,predPlaidBase,measuredF1Grating,minValidPoints);
    for ic = 1:nCells
        [g,o] = fitGainOffset(f1BaseG(ic,:),measuredF1Grating(ic,:));
        predF1Grating(ic,:) = o+g*f1BaseG(ic,:);
        predF1Plaid(ic,:,:) = o+g*squeeze(f1BaseP(ic,:,:));
        f1GratingR(ic) = pairCorr(predF1Grating(ic,:), ...
            measuredF1Grating(ic,:),minValidPoints);
        f1PlaidRStrict(ic) = pairCorr(squeeze(predF1Plaid(ic,:,:)), ...
            squeeze(measuredF1Plaid(ic,:,:)),minValidPoints);
        f1PlaidNRMSEStrict(ic) = normalizedRMSE( ...
            squeeze(predF1Plaid(ic,:,:)),squeeze(measuredF1Plaid(ic,:,:)));
    end
end

%% ---------------- Optional Zp/Zc comparison ----------------
predTensorStrict = nan(nCells,numel(dirDeg),numel(phaseDeg),2,2);
predTensorStrict(:,:,:,1,1) = repmat(reshape(predMeanGrating, ...
    nCells,numel(dirDeg),1),1,1,numel(phaseDeg));
predTensorStrict(:,:,:,2,1) = predMeanPlaid;

predTensorFFT = nan(nCells,numel(dirDeg),numel(phaseDeg),2,2);
predTensorFFT(:,:,:,1,1) = repmat(reshape(predFFTMeanGrating, ...
    nCells,numel(dirDeg),1),1,1,numel(phaseDeg));
predTensorFFT(:,:,:,2,1) = predFFTMeanPlaid;

measuredTensorAligned = nan(size(predTensorStrict));
measuredTensorAligned(:,:,:,1,1) = repmat(reshape(measuredGrating, ...
    nCells,numel(dirDeg),1),1,1,numel(phaseDeg));
measuredTensorAligned(:,:,:,2,1) = measuredPlaid;

ZpZcPred = [];
ZpZcPredFFT = [];
ZpZcMeasured = [];

if exist('getZpZcStruct','file')==2
    try
        ZpZcPred = getZpZcStruct(predTensorStrict,'whole_cell');
        ZpZcPredFFT = getZpZcStruct(predTensorFFT,'whole_cell');
        ZpZcMeasured = getZpZcStruct(measuredTensorAligned,'whole_cell');
    catch ME
        warning('getZpZcStruct could not run: %s','',ME.message);
    end
end

ZpZcLong = table();
if ~isempty(ZpZcPred) && ~isempty(ZpZcPredFFT) && ...
        ~isempty(ZpZcMeasured) && isfield(ZpZcPred,'Zp') && ...
        isfield(ZpZcPred,'Zc') && isfield(ZpZcPredFFT,'Zp') && ...
        isfield(ZpZcPredFFT,'Zc') && isfield(ZpZcMeasured,'Zp') && ...
        isfield(ZpZcMeasured,'Zc')
    measuredZp = arrangeCellPhase(ZpZcMeasured.Zp,nCells,numel(phaseDeg));
    measuredZc = arrangeCellPhase(ZpZcMeasured.Zc,nCells,numel(phaseDeg));
    spatialZp = arrangeCellPhase(ZpZcPred.Zp,nCells,numel(phaseDeg));
    spatialZc = arrangeCellPhase(ZpZcPred.Zc,nCells,numel(phaseDeg));
    fftZp = arrangeCellPhase(ZpZcPredFFT.Zp,nCells,numel(phaseDeg));
    fftZc = arrangeCellPhase(ZpZcPredFFT.Zc,nCells,numel(phaseDeg));
    ZpZcLong = table(repmat(cellID(:),numel(phaseDeg),1), ...
        repelem(phaseDeg(:),nCells),measuredZp(:),measuredZc(:), ...
        spatialZp(:),spatialZc(:),fftZp(:),fftZc(:), ...
        'VariableNames',{'cellID','phaseDeg','measuredZp','measuredZc', ...
        'spatialPredictedZp','spatialPredictedZc','fftPredictedZp', ...
        'fftPredictedZc'});
end

%% ---------------- Save results ----------------
results = table(cellID(:),staIdx(:),respIdx(:),directionShift, ...
    directionReversed,gain,offset,gratingR,plaidRStrict, ...
    plaidRPhaseAligned,plaidNRMSEStrict,plaidNRMSEPhaseAligned, ...
    bestPhaseShift,bestPhaseReversed,predictedPhaseAmp,measuredPhaseAmp, ...
    meanThreshold,meanExponent,meanGain,meanOffset,meanGratingR, ...
    meanPlaidRStrict,meanPlaidRPhaseAligned,meanPlaidNRMSEStrict, ...
    meanPredictedPhaseAmp,meanMeasuredPhaseAmp,f1GratingR, ...
    f1PlaidRStrict,f1PlaidNRMSEStrict,fftMeanGratingR, ...
    fftMeanPlaidRStrict,fftMeanPlaidNRMSEStrict,fftRingGratingR, ...
    'VariableNames',{'cellID','staIndex','responseIndex', ...
    'directionShiftBins','directionReversed','gain','offset','gratingR', ...
    'plaidRStrict','plaidRPhaseAligned','plaidNRMSEStrict', ...
    'plaidNRMSEPhaseAligned','diagnosticPhaseShiftBins', ...
    'diagnosticPhaseReversed','predictedPhaseAmplitude', ...
    'measuredPhaseAmplitude','meanThreshold','meanExponent','meanGain', ...
    'meanOffset','meanGratingR','meanPlaidRStrict', ...
    'meanPlaidRPhaseAligned','meanPlaidNRMSEStrict', ...
    'meanPredictedPhaseAmplitude','meanMeasuredPhaseAmplitude', ...
    'f1GratingR','f1PlaidRStrict','f1PlaidNRMSEStrict', ...
    'fftMeanGratingR','fftMeanPlaidRStrict','fftMeanPlaidNRMSEStrict', ...
    'fftRingGratingR'});

writetable(results,fullfile(outDir, ...
    'STA_denoised_measured_plaid_prediction_summary.csv'));
if ~isempty(ZpZcLong)
    writetable(ZpZcLong,fullfile(outDir, ...
        'STA_spatial_FFT_measured_ZpZc_comparison.csv'));
end

save(fullfile(outDir,'STA_denoised_measured_plaid_prediction_results.mat'), ...
    'results','cellID','STAdenoised','measuredGrating','measuredPlaid', ...
    'predGratingBase','predPlaidBase','predGrating','predPlaidStrict', ...
    'predPlaidPhaseAligned','predTensorStrict','predTensorFFT', ...
    'measuredTensorAligned', ...
    'predMeanGrating','predMeanPlaid','predMeanPlaidPhaseAligned', ...
    'predFFTMeanGrating','predFFTMeanPlaid','predFFTRingGrating', ...
    'fftGratingDriveBase','fftPlaidDriveBase','fftRingGratingBase', ...
    'predF1Grating','predF1Plaid','measuredF1Grating','measuredF1Plaid', ...
    'ZpZcPred','ZpZcPredFFT','ZpZcMeasured','dirDeg','phaseDeg','SF', ...
    'degPerPixel', ...
    'plaidAngleDeg','alignmentMethod','globalDirectionShift', ...
    'globalDirectionReversed','meanGlobalDirectionShift', ...
    'meanGlobalDirectionReversed','f1GlobalDirectionShift', ...
    'f1GlobalDirectionReversed','staName','respName','f1RespName', ...
    'hasMeasuredF1','thresholdFractionGrid','exponentGrid','ZpZcLong');

%% ---------------- Figure 1: example cells ----------------
valid = isfinite(meanPlaidRStrict);
validIdx = find(valid);
[~,ord] = sort(meanPlaidRStrict(validIdx));

if numel(ord)>=3
    exampleIdx = validIdx(ord(round(linspace(1,numel(ord),3))));
else
    exampleIdx = validIdx;
end

figure('Color','w','Position',[40 40 1500 380*numel(exampleIdx)]);
tiledlayout(numel(exampleIdx),4,'TileSpacing','compact','Padding','compact');
phaseColor = lines(numel(phaseDeg));

for ii = 1:numel(exampleIdx)
    ic = exampleIdx(ii);

    nexttile;
    rf = squeeze(STAdenoised(ic,:,:));
    imagesc(x,y,rf);
    axis image;
    set(gca,'YDir','normal');
    colormap(gca,blueWhiteRed(256));
    lim = max(abs(rf(:)));
    if lim>0, caxis(lim*[-1 1]); end
    xlabel('Azimuth (deg)');
    ylabel('Elevation (deg)');
    title(sprintf('Cell %s: denoised STA',string(cellID(ic))));

    nexttile;
    plot([dirDeg 360],[measuredGrating(ic,:) measuredGrating(ic,1)], ...
        'ko-','LineWidth',1.5,'DisplayName','Measured');
    hold on;
    plot([dirDeg 360],[predMeanGrating(ic,:) predMeanGrating(ic,1)], ...
        'o-','Color',[.2 .5 .9],'LineWidth',1.4,'DisplayName','Predicted');
    xlabel('Direction (deg)');
    ylabel('Response');
    xlim([0 360]);
    title(sprintf('Grating mean fit, r = %.2f',meanGratingR(ic)));
    legend('Location','best');
    box off;

    nexttile;
    hold on;
    for ip = 1:numel(phaseDeg)
        mPhase = reshape(measuredPlaid(ic,:,ip),1,[]);
        pPhase = reshape(predMeanPlaid(ic,:,ip),1,[]);
        plot([dirDeg 360],[mPhase mPhase(1)],'-', ...
            'Color',phaseColor(ip,:), ...
            'LineWidth',2,'DisplayName',sprintf('Measured %d',phaseDeg(ip)));
        plot([dirDeg 360],[pPhase pPhase(1)],'--', ...
            'Color',phaseColor(ip,:), ...
            'LineWidth',1.3,'HandleVisibility','off');
    end
    xlabel('Pattern direction (deg)');
    ylabel('Plaid response');
    xlim([0 360]);
    title(sprintf('Solid measured; dashed predicted, r = %.2f', ...
        meanPlaidRStrict(ic)));
    legend('Location','best');
    box off;

    nexttile;
    meas = squeeze(measuredPlaid(ic,:,:));
    pred = squeeze(predMeanPlaid(ic,:,:));
    scatter(pred(:),meas(:),32,repelem(phaseColor,numel(dirDeg),1), ...
        'filled','MarkerFaceAlpha',0.65);
    hold on;
    mn = min([pred(:);meas(:)],[],'omitnan');
    mx = max([pred(:);meas(:)],[],'omitnan');
    plot([mn mx],[mn mx],'k--');
    xlabel('Predicted plaid response');
    ylabel('Measured plaid response');
    axis square;
    title(sprintf('Strict r %.2f; phase-aligned r %.2f', ...
        meanPlaidRStrict(ic),meanPlaidRPhaseAligned(ic)));
    box off;
end

sgtitle(['Denoised STA rectified-mean predictions versus measured ' ...
    'four-phase plaid means']);
exportgraphics(gcf,fullfile(outDir, ...
    'STA_denoised_measured_plaid_prediction_examples.pdf'), ...
    'ContentType','vector');

%% ---------------- Figure 2: FFT prediction examples ----------------
figure('Color','w','Position',[50 50 1450 360*numel(exampleIdx)]);
tiledlayout(numel(exampleIdx),4,'TileSpacing','compact','Padding','compact');

for ii = 1:numel(exampleIdx)
    ic = exampleIdx(ii);

    nexttile;
    rf = squeeze(STAdenoised(ic,:,:));
    imagesc(x,y,rf);
    axis image;
    set(gca,'YDir','normal');
    colormap(gca,blueWhiteRed(256));
    lim = max(abs(rf(:)));
    if lim>0, caxis(lim*[-1 1]); end
    xlabel('Azimuth (deg)'); ylabel('Elevation (deg)');
    title(sprintf('Cell %s: denoised STA',string(cellID(ic))));

    nexttile;
    plot([dirDeg 360],[measuredGrating(ic,:) measuredGrating(ic,1)], ...
        'ko-','LineWidth',1.6,'DisplayName','Measured');
    hold on;
    plot([dirDeg 360],[predFFTMeanGrating(ic,:) ...
        predFFTMeanGrating(ic,1)],'o-','Color',[.15 .48 .88], ...
        'LineWidth',1.5,'DisplayName','Full-complex FFT');
    xlabel('Direction (deg)'); ylabel('Mean response'); xlim([0 360]);
    title(sprintf('FFT grating prediction, r = %.2f',fftMeanGratingR(ic)));
    legend('Location','best'); box off;

    nexttile;
    hold on;
    for ip = 1:numel(phaseDeg)
        mPhase = reshape(measuredPlaid(ic,:,ip),1,[]);
        pPhase = reshape(predFFTMeanPlaid(ic,:,ip),1,[]);
        plot([dirDeg 360],[mPhase mPhase(1)],'-', ...
            'Color',phaseColor(ip,:),'LineWidth',2, ...
            'DisplayName',sprintf('Measured %d deg',phaseDeg(ip)));
        plot([dirDeg 360],[pPhase pPhase(1)],'--', ...
            'Color',phaseColor(ip,:),'LineWidth',1.4, ...
            'HandleVisibility','off');
    end
    xlabel('Pattern direction (deg)'); ylabel('Mean plaid response');
    xlim([0 360]);
    title(sprintf('Solid measured; dashed FFT, r = %.2f', ...
        fftMeanPlaidRStrict(ic)));
    legend('Location','best'); box off;

    nexttile;
    meas = squeeze(measuredPlaid(ic,:,:));
    pred = squeeze(predFFTMeanPlaid(ic,:,:));
    hold on;
    for ip = 1:numel(phaseDeg)
        scatter(pred(:,ip),meas(:,ip),30,phaseColor(ip,:), ...
            'filled','MarkerFaceAlpha',0.65, ...
            'DisplayName',sprintf('%d deg',phaseDeg(ip)));
    end
    mn = min([pred(:);meas(:)],[],'omitnan');
    mx = max([pred(:);meas(:)],[],'omitnan');
    plot([mn mx],[mn mx],'k--','HandleVisibility','off');
    xlabel('FFT-predicted plaid response');
    ylabel('Measured plaid response'); axis square;
    title(sprintf('All 48 conditions, r = %.2f',fftMeanPlaidRStrict(ic)));
    legend('Location','best'); box off;
end

sgtitle('Full-complex FFT predictions versus measured responses');
exportgraphics(gcf,fullfile(outDir, ...
    'STA_FFT_measured_prediction_examples.pdf'),'ContentType','vector');

%% ---------------- Figure 2: population validation ----------------
figure('Color','w','Position',[100 100 1250 430]);
tiledlayout(1,3,'TileSpacing','compact','Padding','compact');

nexttile;
histogram(plaidRStrict(isfinite(plaidRStrict)),-1:0.1:1,'FaceAlpha',0.45);
hold on;
histogram(meanPlaidRStrict(valid),-1:0.1:1,'FaceAlpha',0.65);
xline(0,'k--');
xlabel('Predicted versus measured plaid r');
ylabel('Number of cells');
legend({'F1-to-mean mismatch','Rectified mean-to-mean'},'Location','best');
title(sprintf('Median matched r = %.2f', ...
    median(meanPlaidRStrict(valid),'omitnan')));
box off;

nexttile;
scatter(meanGratingR(valid),meanPlaidRStrict(valid),34, ...
    meanMeasuredPhaseAmp(valid), ...
    'filled','MarkerFaceAlpha',0.65);
xlabel('Grating calibration r');
ylabel('Out-of-sample plaid r');
xline(0,'k:');
yline(0,'k:');
cb = colorbar;
cb.Label.String = 'Measured phase amplitude';
title('Does grating prediction generalize to plaids?');
box off;

nexttile;
scatter(meanPredictedPhaseAmp(valid),meanMeasuredPhaseAmp(valid),34, ...
    meanPlaidRStrict(valid),'filled','MarkerFaceAlpha',0.65);
hold on;
mx = max([meanPredictedPhaseAmp(valid);meanMeasuredPhaseAmp(valid)], ...
    [],'omitnan');
plot([0 mx],[0 mx],'k--');
xlabel('Predicted phase-modulation amplitude');
ylabel('Measured phase-modulation amplitude');
axis square;
cb = colorbar;
cb.Label.String = 'Strict plaid r';
title('Can STA predict phase sensitivity?');
box off;

exportgraphics(gcf,fullfile(outDir, ...
    'STA_denoised_measured_plaid_prediction_population.pdf'), ...
    'ContentType','vector');

%% ---------------- Figure 3: spatial versus FFT ----------------
figure('Color','w','Position',[120 120 1250 400]);
tiledlayout(1,3,'TileSpacing','compact','Padding','compact');

nexttile;
xv = predMeanPlaid(:);
yv = predFFTMeanPlaid(:);
v = isfinite(xv) & isfinite(yv);
scatter(xv(v),yv(v),10,'filled','MarkerFaceAlpha',0.25);
hold on;
mn = min([xv(v);yv(v)],[],'omitnan');
mx = max([xv(v);yv(v)],[],'omitnan');
plot([mn mx],[mn mx],'k--');
xlabel('Spatial-domain plaid prediction');
ylabel('Full-complex-FFT plaid prediction');
axis square;
title('Parseval-equivalent predictions');
box off;

nexttile;
v = isfinite(meanPlaidRStrict) & isfinite(fftMeanPlaidRStrict);
scatter(meanPlaidRStrict(v),fftMeanPlaidRStrict(v),28,'filled', ...
    'MarkerFaceAlpha',0.6);
hold on;
plot([-1 1],[-1 1],'k--');
xlabel('Spatial-domain plaid r');
ylabel('Full-complex-FFT plaid r');
xlim([-1 1]); ylim([-1 1]); axis square;
title('Cell-wise plaid performance');
box off;

nexttile;
v = isfinite(meanGratingR) & isfinite(fftRingGratingR);
scatter(meanGratingR(v),fftRingGratingR(v),28,'filled', ...
    'MarkerFaceAlpha',0.6);
hold on;
plot([-1 1],[-1 1],'k--');
xlabel('Spatial rectified-mean grating r');
ylabel('FFT-ring magnitude grating r');
xlim([-1 1]); ylim([-1 1]); axis square;
title('Phase-free FFT ring: grating only');
box off;

sgtitle(sprintf(['Spatial vs FFT checks: max drive error grating %.3g, ' ...
    'plaid %.3g'],spatialFFTDriveMaxError,spatialFFTPlaidDriveMaxError));
exportgraphics(gcf,fullfile(outDir, ...
    'STA_spatial_vs_FFT_comparison.pdf'),'ContentType','vector');

%% ---------------- Figure 5: predicted versus measured Zp/Zc ----------------
if ~isempty(ZpZcLong)
    figure('Color','w','Position',[100 70 1050 850]);
    tiledlayout(2,2,'TileSpacing','compact','Padding','compact');
    zpzcPairs = {spatialZp,measuredZp,'Spatial-domain Z_p'; ...
        spatialZc,measuredZc,'Spatial-domain Z_c'; ...
        fftZp,measuredZp,'Full-complex FFT Z_p'; ...
        fftZc,measuredZc,'Full-complex FFT Z_c'};
    for k = 1:4
        nexttile;
        predMetric = zpzcPairs{k,1};
        measMetric = zpzcPairs{k,2};
        hold on;
        for ip = 1:numel(phaseDeg)
            scatter(predMetric(:,ip),measMetric(:,ip),28, ...
                phaseColor(ip,:),'filled','MarkerFaceAlpha',0.55, ...
                'DisplayName',sprintf('%d deg',phaseDeg(ip)));
        end
        rAll = pairCorr(predMetric,measMetric,minValidPoints);
        lim = max(abs([predMetric(:);measMetric(:)]),[],'omitnan');
        lim = max(lim,1);
        plot([-lim lim],[-lim lim],'k--','HandleVisibility','off');
        xline(0,'k:','HandleVisibility','off');
        yline(0,'k:','HandleVisibility','off');
        xlim([-lim lim]); ylim([-lim lim]); axis square;
        xlabel('Predicted'); ylabel('Measured');
        title(sprintf('%s: r = %.2f',zpzcPairs{k,3},rAll));
        if k==1, legend('Location','best'); end
        box off;
    end
    sgtitle(['Do STA-derived spatial and FFT predictions recover measured ' ...
        'pattern/component selectivity?']);
    exportgraphics(gcf,fullfile(outDir, ...
        'STA_spatial_FFT_predicted_vs_measured_ZpZc.pdf'), ...
        'ContentType','vector');
end

if hasMeasuredF1
    figure('Color','w','Position',[180 180 900 400]);
    tiledlayout(1,2,'TileSpacing','compact','Padding','compact');
    nexttile;
    histogram(f1PlaidRStrict(isfinite(f1PlaidRStrict)),-1:0.1:1);
    xline(0,'k--');
    xlabel('Predicted versus measured F1 plaid r');
    ylabel('Number of cells');
    title(sprintf('Matched F1 median r = %.2f', ...
        median(f1PlaidRStrict,'omitnan')));
    box off;
    nexttile;
    vF1 = isfinite(f1GratingR) & isfinite(f1PlaidRStrict);
    scatter(f1GratingR(vF1),f1PlaidRStrict(vF1),30,'filled', ...
        'MarkerFaceAlpha',0.65);
    xline(0,'k:'); yline(0,'k:');
    xlabel('Measured F1 grating calibration r');
    ylabel('Out-of-sample measured F1 plaid r');
    title(sprintf('F1 tensor: %s',f1RespName),'Interpreter','none');
    box off;
    exportgraphics(gcf,fullfile(outDir, ...
        'STA_denoised_measured_F1_validation.pdf'),'ContentType','vector');
end

fprintf('\nLegacy F1-to-mean median plaid r: %.3f\n', ...
    median(plaidRStrict,'omitnan'));
fprintf('Matched mean-to-mean median grating r: %.3f\n', ...
    median(meanGratingR,'omitnan'));
fprintf('Matched mean-to-mean median strict plaid r: %.3f\n', ...
    median(meanPlaidRStrict,'omitnan'));
fprintf('Matched mean phase-aligned diagnostic r: %.3f\n', ...
    median(meanPlaidRPhaseAligned,'omitnan'));
fprintf('Full-complex FFT median strict plaid r: %.3f\n', ...
    median(fftMeanPlaidRStrict,'omitnan'));
fprintf('Spatial/FFT maximum drive error: grating %.3g; plaid %.3g\n', ...
    spatialFFTDriveMaxError,spatialFFTPlaidDriveMaxError);
fprintf('FFT-ring median grating r (phase-free diagnostic): %.3f\n', ...
    median(fftRingGratingR,'omitnan'));
if ~isempty(ZpZcLong)
    fprintf('Spatial predicted vs measured Zp r: %.3f\n', ...
        pairCorr(spatialZp,measuredZp,minValidPoints));
    fprintf('Spatial predicted vs measured Zc r: %.3f\n', ...
        pairCorr(spatialZc,measuredZc,minValidPoints));
    fprintf('FFT predicted vs measured Zp r: %.3f\n', ...
        pairCorr(fftZp,measuredZp,minValidPoints));
    fprintf('FFT predicted vs measured Zc r: %.3f\n', ...
        pairCorr(fftZc,measuredZc,minValidPoints));
else
    fprintf('Zp/Zc comparison skipped: getZpZcStruct output unavailable.\n');
end
if hasMeasuredF1
    fprintf('Matched F1-to-F1 median strict plaid r: %.3f\n', ...
        median(f1PlaidRStrict,'omitnan'));
else
    fprintf('Matched F1-to-F1 test skipped: no compatible F1 tensor found.\n');
end
fprintf('Saved results to:\n%s\n',fullfile(pwd,outDir));

%% ============================================================
% Local functions
%% ============================================================

function [value,name] = findField(S,candidates)
value = [];
name = "";
for i = 1:numel(candidates)
    if isfield(S,candidates{i})
        value = S.(candidates{i});
        name = string(candidates{i});
        return;
    end
end
end

function [value,name] = autoFindSTA(S)
value = [];
name = "";
f = fieldnames(S);
for i = 1:numel(f)
    v = S.(f{i});
    if isnumeric(v) && ndims(v)==3
        value = v;
        name = string(f{i});
        return;
    end
end
end

function [value,name] = autoFindResponseTensor(S,nDir,nPhase)
value = [];
name = "";
f = fieldnames(S);
match = false(numel(f),1);
for i = 1:numel(f)
    v = S.(f{i});
    sz = size(v);
    match(i) = isnumeric(v) && ndims(v)>=4 && ...
        numel(sz)>=4 && sz(2)==nDir && sz(3)==nPhase && sz(4)>=2;
end
idx = find(match);
if numel(idx)==1
    name = string(f{idx});
    value = S.(f{idx});
elseif numel(idx)>1
    names = strjoin(f(idx),', ');
    error(['Multiple compatible response tensors were found: %s. ' ...
        'Add the intended variable name to respCandidates.'],names);
end
end

function txt = variableInventory(S)
f = fieldnames(S);
lines = strings(numel(f),1);
for i = 1:numel(f)
    v = S.(f{i});
    lines(i) = sprintf('  %s: %s %s',f{i},class(v),mat2str(size(v)));
end
txt = strjoin(lines,newline);
end

function STA = arrangeSTA(A,cellID)
if ~isempty(cellID)
    n = numel(cellID);
    if size(A,1)==n
        STA = A;
    elseif size(A,3)==n
        STA = permute(A,[3 1 2]);
    else
        error('STA dimensions do not match the STA cell IDs.');
    end
else
    [~,cellDim] = max(size(A));
    if cellDim==1
        STA = A;
    elseif cellDim==3
        STA = permute(A,[3 1 2]);
    else
        error('Cannot infer the STA cell dimension.');
    end
end
end

function [staIdx,respIdx,cellID,method] = ...
    alignCells(R,P,STA,staID,respID,nSTA,nResp)
if ~isempty(staID) && ~isempty(respID)
    [tf,loc] = ismember(string(staID(:)),string(respID(:)));
    staIdx = find(tf);
    respIdx = loc(tf);
    cellID = staID(staIdx);
    method = "cell IDs";
elseif isfield(P,'cellsSelected') && numel(P.cellsSelected)==nSTA
    staIdx = (1:nSTA)';
    respIdx = P.cellsSelected(:);
    cellID = respIdx;
    method = "saved cellsSelected";
elseif canRebuildCellsSelected(P)
    cellsSelected = rebuildCellsSelected(P);
    assert(numel(cellsSelected)==nSTA,['Reconstructed cellsSelected has ' ...
        '%d cells, but STA_images has %d rows. Confirm that the STA export ' ...
        'used the same selection criteria.'],numel(cellsSelected),nSTA);
    staIdx = (1:nSTA)';
    respIdx = cellsSelected(:);
    cellID = respIdx;
    method = "reconstructed cellsSelected";
elseif isfield(R,'fittedIdx') && ...
        (numel(R.fittedIdx)==nSTA || sum(logical(R.fittedIdx(:)))==nSTA)
    staIdx = (1:nSTA)';
    if islogical(R.fittedIdx) || all(ismember(R.fittedIdx(:),[0 1]))
        respIdx = find(R.fittedIdx(:));
    else
        respIdx = R.fittedIdx(:);
    end
    assert(all(respIdx>=1 & respIdx<=nResp), ...
        'fittedIdx contains response indices outside the measured array.');
    cellID = staIdx;
    method = "fittedIdx";
elseif nSTA==nResp
    staIdx = (1:nSTA)';
    respIdx = staIdx;
    cellID = staIdx;
    method = "matching array order";
    warning('No cell IDs found; assuming STA and response order match.');
else
    error('Cannot align %d STAs with %d response cells.',nSTA,nResp);
end
assert(~isempty(staIdx),'No matching cells were found.');
assert(all(respIdx>=1 & respIdx<=nResp), ...
    'The selected response indices exceed the %d-cell response tensor.',nResp);
end

function tf = canRebuildCellsSelected(S)
required = {'depth_all','cells_sigRFbyTime_On_all', ...
    'cells_sigRFbyTime_Off_all','bestTimePoint_all','resp_ind_dir_all'};
tf = all(isfield(S,required));
end

function cellsSelected = rebuildCellsSelected(S)

% This reproduces the selection used before exporting the 252 STAs.
indCortex = find(S.depth_all>-1300);
indSigRF = sum(S.cells_sigRFbyTime_On_all,2)+ ...
    sum(S.cells_sigRFbyTime_Off_all,2);
listnc = (1:size(S.cells_sigRFbyTime_On_all,1))';
indRFpix = listnc(indSigRF>0);
indRFcon = find(S.bestTimePoint_all(:,2)>1);

indRFpix = intersect(indRFpix,indCortex);
indRFcon = intersect(indRFcon,indCortex);
idxInt = intersect(indRFpix,indRFcon);
cellsSelected = intersect(idxInt,S.resp_ind_dir_all(:));

end

function rfOut = denoiseSTA(rf,sigmaPix,thresholdSigma)
rf(~isfinite(rf)) = 0;
rf = rf-mean(rf(:));
rad = max(1,ceil(3*sigmaPix));
g = exp(-((-rad:rad).^2)/(2*sigmaPix^2));
g = g/sum(g);
rfSmooth = conv2(g',g,rf,'same');
ny = size(rf,1);
nx = size(rf,2);
bw = max(2,round(min(nx,ny)*0.15));
border = false(ny,nx);
border(1:bw,:) = true;
border(end-bw+1:end,:) = true;
border(:,1:bw) = true;
border(:,end-bw+1:end) = true;
b = rfSmooth(border);
noiseSigma = 1.4826*median(abs(b-median(b)));
if ~isfinite(noiseSigma) || noiseSigma<=eps, noiseSigma = std(b); end
mask = abs(rfSmooth)>=thresholdSigma*max(noiseSigma,eps);
mask = conv2(double(mask),ones(3),'same')>=2;
if sum(mask(:))<5, rfOut = rfSmooth; else, rfOut = rfSmooth.*mask; end
rfOut = rfOut-mean(rfOut(:));
end

function stim = makeGrating(x,y,SF,dirDeg,spatialPhaseDeg,contrast,nTime)
spacePhase = 2*pi*SF*(x*cosd(dirDeg)+y*sind(dirDeg));
tp = linspace(0,2*pi,nTime+1);
tp(end) = [];
stim = contrast*cos(spacePhase-reshape(tp,1,1,[])+ ...
    deg2rad(spatialPhaseDeg));
end

function drive = runLinearSTA(rf,stim)
drive = squeeze(sum(sum(rf.*stim,1),2));
end

function drive = runFFTSTA(rfFFT,stim)
% Parseval form of sum(rf .* stimulus) using the full complex spectrum.
nTime = size(stim,3);
nPix = size(stim,1)*size(stim,2);
drive = zeros(1,nTime);
for it = 1:nTime
    stimFFT = fft2(stim(:,:,it));
    drive(it) = real(sum(conj(rfFFT).*stimFFT,'all')/nPix);
end
end

function tuning = fftRingTuning(rf,degPerPixel,SF,dirDeg)
% Hann-windowed magnitude sampled at the experimental spatial frequency.
% This is phase-free and therefore valid only as a grating-tuning diagnostic.
[ny,nx] = size(rf);
if nx>1, wx = 0.5-0.5*cos(2*pi*(0:nx-1)/(nx-1)); else, wx = 1; end
if ny>1, wy = 0.5-0.5*cos(2*pi*(0:ny-1)/(ny-1)); else, wy = 1; end
F = abs(fftshift(fft2(rf.*(wy(:)*wx(:)'))));
fx = (-floor(nx/2):ceil(nx/2)-1)/(nx*degPerPixel);
fy = (-floor(ny/2):ceil(ny/2)-1)/(ny*degPerPixel);
qx = SF*cosd(dirDeg);
qy = SF*sind(dirDeg);
tuning = interp2(fx,fy,F,qx,qy,'linear',0);
end

function f1 = getF1(r)
r = r(:)';
n = numel(r);
f1 = 2*abs(mean(r.*exp(-1i*2*pi*(0:n-1)/n)));
end

function [mappedG,mappedP,bestShift,bestReverse] = ...
    alignGlobalDirectionFromGrating(baseG,baseP,measG,minPoints)
bestScore = -inf;
mappedG = baseG;
mappedP = baseP;
bestShift = 0;
bestReverse = false;
reverseIdx = [1 size(baseG,2):-1:2];
for rev = 0:1
    if rev
        g = baseG(:,reverseIdx);
        p = baseP(:,reverseIdx,:);
    else
        g = baseG;
        p = baseP;
    end
    for sh = 0:size(baseG,2)-1
        gs = circshift(g,[0 sh]);
        score = nan(size(baseG,1),1);
        for ic = 1:size(baseG,1)
            score(ic) = pairCorr(gs(ic,:),measG(ic,:),minPoints);
        end
        score = median(score,'omitnan');
        if isfinite(score) && score>bestScore
            bestScore = score;
            mappedG = gs;
            mappedP = circshift(p,[0 sh 0]);
            bestShift = sh;
            bestReverse = logical(rev);
        end
    end
end
end

function mapped = applyDirectionMapping(data,shiftBins,isReversed)
mapped = data;
if isReversed
    reverseIdx = [1 size(data,2):-1:2];
    subs = repmat({':'},1,ndims(data));
    subs{2} = reverseIdx;
    mapped = mapped(subs{:});
end
shiftVector = zeros(1,ndims(mapped));
shiftVector(2) = shiftBins;
mapped = circshift(mapped,shiftVector);
end

function [predG,predP,bestThreshold,bestExponent,bestGain,bestOffset] = ...
    fitRectifiedMeanModel(gDrive,pDrive,measG,thresholdFractions,exponents)
% Fit only grating cycle means. pDrive is never used for parameter fitting.
if isvector(gDrive), gDrive = reshape(gDrive,1,[]); end
if ndims(pDrive)==2
    pDrive = reshape(pDrive,size(pDrive,1),1,size(pDrive,2));
end

predG = nan(1,size(gDrive,1));
predP = nan(size(pDrive,1),size(pDrive,2));
bestThreshold = nan;
bestExponent = nan;
bestGain = nan;
bestOffset = nan;
scale = max(abs(gDrive(:)),[],'omitnan');
if ~isfinite(scale) || scale<=eps, return; end

bestSSE = inf;
for ipow = 1:numel(exponents)
    pow = exponents(ipow);
    for ithr = 1:numel(thresholdFractions)
        threshold = thresholdFractions(ithr)*scale;
        featureG = mean(max(0,gDrive-threshold).^pow,2,'omitnan')';
        [gain,offset] = fitGainOffset(featureG,measG);
        candidate = offset+gain*featureG;
        v = isfinite(candidate) & isfinite(measG);
        if any(v)
            sse = sum((candidate(v)-measG(v)).^2);
            if sse<bestSSE
                bestSSE = sse;
                predG = candidate;
                bestThreshold = threshold;
                bestExponent = pow;
                bestGain = gain;
                bestOffset = offset;
            end
        end
    end
end

if ~isfinite(bestSSE), return; end
featureP = mean(max(0,pDrive-bestThreshold).^bestExponent,3,'omitnan');
predP = bestOffset+bestGain*featureP;
end

function [gain,offset] = fitGainOffset(x,y)
x = x(:);
y = y(:);
v = isfinite(x) & isfinite(y);
if sum(v)<2 || var(x(v))<=eps
    gain = 0;
    offset = mean(y(v),'omitnan');
    return;
end
b = [ones(sum(v),1) x(v)]\y(v);
gain = max(0,b(2));
offset = mean(y(v)-gain*x(v));
end

function [bestP,bestShift,bestReverse] = ...
    diagnosticPhaseAlignment(pred,meas,minPoints)
bestR = pairCorr(pred,meas,minPoints);
bestP = pred;
bestShift = 0;
bestReverse = false;
reverseIdx = [1 size(pred,2):-1:2];
for rev = 0:1
    if rev, p = pred(:,reverseIdx); else, p = pred; end
    for sh = 0:size(pred,2)-1
        ps = circshift(p,[0 sh]);
        r = pairCorr(ps,meas,minPoints);
        if isfinite(r) && (~isfinite(bestR) || r>bestR)
            bestR = r;
            bestP = ps;
            bestShift = sh;
            bestReverse = logical(rev);
        end
    end
end
end

function r = pairCorr(x,y,minPoints)
x = x(:);
y = y(:);
v = isfinite(x) & isfinite(y);
if sum(v)<minPoints || std(x(v))<=eps || std(y(v))<=eps
    r = nan;
else
    C = corrcoef(x(v),y(v));
    r = C(1,2);
end
end

function e = normalizedRMSE(x,y)
x = x(:);
y = y(:);
v = isfinite(x) & isfinite(y);
if ~any(v)
    e = nan;
else
    e = sqrt(mean((x(v)-y(v)).^2))/max(max(y(v))-min(y(v)),eps);
end
end

function A = arrangeCellPhase(A,nCells,nPhase)
A = squeeze(double(A));
if isvector(A)
    if numel(A)==nCells*nPhase
        A = reshape(A,nCells,nPhase);
    elseif numel(A)==nCells && nPhase==1
        A = A(:);
    else
        error('Cannot arrange Zp/Zc vector of length %d as %d cells x %d phases.', ...
            numel(A),nCells,nPhase);
    end
elseif size(A,1)==nCells && size(A,2)==nPhase
    % already cells x phases
elseif size(A,2)==nCells && size(A,1)==nPhase
    A = A';
else
    error('Unexpected Zp/Zc size %s; expected %d cells x %d phases.', ...
        mat2str(size(A)),nCells,nPhase);
end
end

function a = meanPhaseModulation(resp,phaseDeg)
aDir = nan(size(resp,1),1);
X = [ones(numel(phaseDeg),1) cosd(phaseDeg(:)) sind(phaseDeg(:))];
for id = 1:size(resp,1)
    y = resp(id,:)';
    v = isfinite(y);
    if sum(v)>=3
        b = X(v,:)\y(v);
        amp = hypot(b(2),b(3));
        responseScale = mean(abs(y(v)));
        aDir(id) = amp/max(amp+responseScale,eps);
    end
end
a = mean(aDir,'omitnan');
end

function cmap = blueWhiteRed(n)
if nargin<1, n = 256; end
n1 = floor(n/2);
n2 = n-n1;
cmap = [linspace(0.1,1,n1)' linspace(0.3,1,n1)' ones(n1,1); ...
    ones(n2,1) linspace(1,0.2,n2)' linspace(1,0.1,n2)'];
end
