%% STA_static_FT_OSI_predict_measured_metrics.m
clear;
close all;
clc;

% ============================================================
% Goal
% ============================================================
% Use a SINGLE static V1 STA only to estimate orientation selectivity.
% Test whether this scalar STA-derived OSI is associated with measured:
%   1. grating OSI;
%   2. STA aspect ratio;
%   3. Zp and Zc from actual four-phase plaid responses;
%   4. masking index and plaid phase sensitivity.
%
% This wrapper does NOT generate a 0-360 direction-tuning curve from the
% STA and does NOT synthesize plaid responses. A static STA contains no
% temporal direction information, so PDS/CDS remain measured outcomes.

%% ---------------- Settings ----------------
rfFile = "RF_ML_dataset.mat";
responseFile = "CrossOri_randDirFourPhase_summary.mat";
outDir = "STA_static_FT_OSI_measured_metrics";

degPerPixel = 2;
experimentalSF = 0.05;
fftOriDeg = 0:1:179;
dirDeg = 0:30:330;
phaseDeg = [0 90 180 270];

smoothSigmaPix = 1;
maskThresholdSigma = 2.5;
minSTAenergy = 1e-10;
minValidPoints = 8;
nEqualBins = 5;
rng(1);

staCandidates = {'STA_images','STA','staImages'};
respCandidates = {'avg_resp_dir_all','avg_resp_dir', ...
    'avg_resp_dir_all_selected','avgRespDir'};
staIDCandidates = {'fittedCellIDs','cellIDs','cellID'};
respIDCandidates = {'cellIDs','allCellIDs','cellID','totCellIDs'};
measuredOSICandidates = {'OSI_all','OSI_prefdir','peakF1OSI_all', ...
    'peakF1OSI'};
globalOSICandidates = {'globalOSI_all','global_OSI_all','gOSI_all', ...
    'globalOSI'};

if ~exist(outDir,'dir'), mkdir(outDir); end
assert(isfile(rfFile),'RF file not found: %s',rfFile);
% assert(isfile(responseFile),'Response file not found: %s',responseFile);

%% ---------------- Load and align cells ----------------
R = load(rfFile);
analysisDir=('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\sara\Analysis\Neuropixel\CrossOri\randDirFourPhase');
P = load([analysisDir '\CrossOri_randDirFourPhase_summary.mat']);
[staRaw,staName] = findField(R,staCandidates);
[respRaw,respName] = findField(P,respCandidates);
if strlength(staName)==0, [staRaw,staName] = autoFindSTA(R); end
if strlength(respName)==0
    [respRaw,respName] = autoFindResponseTensor(P,numel(dirDeg),numel(phaseDeg));
end
assert(strlength(staName)>0,'No three-dimensional STA array found.');
assert(strlength(respName)>0,'No compatible response tensor found.');

[staID,~] = findField(R,staIDCandidates);
[respID,~] = findField(P,respIDCandidates);
STA = arrangeSTA(double(staRaw),staID);
respRaw = double(respRaw);
if ndims(respRaw)==4, respRaw = reshape(respRaw,[size(respRaw) 1]); end
assert(size(respRaw,2)==12 && size(respRaw,3)==4 && size(respRaw,4)>=2, ...
    'Expected cells x 12 directions x 4 phases x grating/plaid x mean/std.');

[staIdx,respIdx,cellID,alignmentMethod] = alignCells( ...
    R,P,STA,staID,respID,size(STA,1),size(respRaw,1));
STA = STA(staIdx,:,:);
responseTensor = respRaw(respIdx,:,:,:,:);
nCells = numel(staIdx);

measuredGrating = squeeze(mean(responseTensor(:,:,:,1,1),3,'omitnan'));
measuredPlaid = squeeze(responseTensor(:,:,:,2,1));
if nCells==1
    measuredGrating = reshape(measuredGrating,1,[]);
    measuredPlaid = reshape(measuredPlaid,1,numel(dirDeg),numel(phaseDeg));
end

[storedOSI,storedOSIName] = findField(P,measuredOSICandidates);
if strlength(storedOSIName)>0 && numel(storedOSI)==size(respRaw,1)
    measuredGratingOSI = double(storedOSI(respIdx));
    measuredGratingOSI = measuredGratingOSI(:);
    measuredOSISource = storedOSIName;
else
    measuredGratingOSI = peakOSI360(measuredGrating);
    measuredOSISource = "computed peak-versus-orthogonal OSI";
end

[storedGlobalOSI,storedGlobalOSIName] = findField(P,globalOSICandidates);
if strlength(storedGlobalOSIName)>0 && numel(storedGlobalOSI)==size(respRaw,1)
    measuredGlobalOSI = double(storedGlobalOSI(respIdx));
    measuredGlobalOSI = measuredGlobalOSI(:);
    measuredGlobalOSISource = storedGlobalOSIName;
else
    measuredGlobalOSI = globalOSI360(measuredGrating,dirDeg);
    measuredGlobalOSISource = "computed 360-degree orientation vector OSI";
end

fprintf('Aligned %d cells using %s.\n',nCells,alignmentMethod);
fprintf('Measured grating OSI source: %s.\n',measuredOSISource);
fprintf('Measured global OSI source: %s.\n',measuredGlobalOSISource);

%% ---------------- Static STA metrics ----------------
ny = size(STA,2);
nx = size(STA,3);
xDeg = ((1:nx)-(nx+1)/2)*degPerPixel;
yDeg = ((1:ny)-(ny+1)/2)*degPerPixel;

STAdenoised = nan(size(STA));
fftOriTuning = nan(nCells,numel(fftOriDeg));
staOSIvector = nan(nCells,1);
staOSIpeak = nan(nCells,1);
staPrefOriDeg = nan(nCells,1);
staAR = nan(nCells,1);

for ic = 1:nCells
    rf = denoiseSTA(squeeze(STA(ic,:,:)),smoothSigmaPix,maskThresholdSigma);
    STAdenoised(ic,:,:) = rf;
    if sum(rf(:).^2)<=minSTAenergy, continue; end

    tuning = fftRingTuning(rf,degPerPixel,experimentalSF,fftOriDeg);
    fftOriTuning(ic,:) = tuning;
    staOSIvector(ic) = orientationVectorOSI(tuning,fftOriDeg);
    [staOSIpeak(ic),staPrefOriDeg(ic)] = orientationPeakOSI(tuning,fftOriDeg);
    staAR(ic) = covarianceAR(rf,xDeg,yDeg);
end

%% ---------------- Measured plaid metrics ----------------
ZpZcMeasured = [];
measuredZp = nan(nCells,numel(phaseDeg));
measuredZc = nan(nCells,numel(phaseDeg));
if exist('getZpZcStruct','file')==2
    try
        ZpZcMeasured = getZpZcStruct(responseTensor,'whole_cell');
        measuredZp = arrangeCellPhase(ZpZcMeasured.Zp,nCells,numel(phaseDeg));
        measuredZc = arrangeCellPhase(ZpZcMeasured.Zc,nCells,numel(phaseDeg));
    catch ME
        warning('getZpZcStruct could not run: %s','',ME.message);
    end
else
    warning('getZpZcStruct not found; Zp/Zc analyses will be skipped.');
end

meanMeasuredZp = mean(measuredZp,2,'omitnan');
meanMeasuredZc = mean(measuredZc,2,'omitnan');
measuredPhaseSensitivity = nan(nCells,1);
meanMaskingIndex = nan(nCells,1);
for ic = 1:nCells
    measuredPhaseSensitivity(ic) = meanPhaseModulation( ...
        squeeze(measuredPlaid(ic,:,:)),phaseDeg);
    meanMaskingIndex(ic) = measuredMaskingIndex(measuredGrating(ic,:), ...
        squeeze(measuredPlaid(ic,:,:)));
end

%% ---------------- Continuous association tests ----------------
targetNames = {'Measured peak grating OSI','Measured global grating OSI', ...
    'STA aspect ratio','Mean measured Zp','Mean measured Zc', ...
    'Mean masking index','Plaid phase sensitivity'};
targetFields = {'measuredGratingOSI','measuredGlobalOSI','staAR', ...
    'meanMeasuredZp','meanMeasuredZc','meanMaskingIndex', ...
    'measuredPhaseSensitivity'};
targetData = {measuredGratingOSI,measuredGlobalOSI,staAR,meanMeasuredZp, ...
    meanMeasuredZc,meanMaskingIndex,measuredPhaseSensitivity};

nTargets = numel(targetNames);
pearsonR = nan(nTargets,1);
spearmanRho = nan(nTargets,1);
cvR2 = nan(nTargets,1);
nValid = zeros(nTargets,1);
for it = 1:nTargets
    [pearsonR(it),spearmanRho(it),cvR2(it),nValid(it)] = ...
        associationStats(staOSIvector,targetData{it},minValidPoints,5);
end

associationSummary = table(string(targetNames(:)),string(targetFields(:)), ...
    nValid,pearsonR,spearmanRho,cvR2, ...
    'VariableNames',{'target','field','n','pearsonR','spearmanRho','cvR2'});

cellSummary = table(cellID(:),staIdx(:),respIdx(:),staOSIvector,staOSIpeak, ...
    staPrefOriDeg,staAR,measuredGratingOSI,measuredGlobalOSI, ...
    meanMeasuredZp,meanMeasuredZc, ...
    meanMaskingIndex,measuredPhaseSensitivity, ...
    'VariableNames',{'cellID','staIndex','responseIndex','staFFTOSIvector', ...
    'staFFTOSIpeak','staPreferredOrientationDeg','staAspectRatio', ...
    'measuredPeakGratingOSI','measuredGlobalGratingOSI', ...
    'meanMeasuredZp','meanMeasuredZc', ...
    'meanMaskingIndex','measuredPlaidPhaseSensitivity'});

phaseSummary = table(repmat(cellID(:),numel(phaseDeg),1), ...
    repelem(phaseDeg(:),nCells),repmat(staOSIvector,numel(phaseDeg),1), ...
    measuredZp(:),measuredZc(:), ...
    'VariableNames',{'cellID','phaseDeg','staFFTOSIvector','measuredZp', ...
    'measuredZc'});

phaseAssociation = table();
if any(isfinite(measuredZp(:)))
    metric = strings(2*numel(phaseDeg),1);
    phase = nan(2*numel(phaseDeg),1);
    n = zeros(2*numel(phaseDeg),1);
    r = nan(2*numel(phaseDeg),1);
    rho = nan(2*numel(phaseDeg),1);
    r2 = nan(2*numel(phaseDeg),1);
    row = 0;
    for im = 1:2
        if im==1, Y = measuredZp; label = "Zp"; else, Y = measuredZc; label = "Zc"; end
        for ip = 1:numel(phaseDeg)
            row = row+1;
            metric(row) = label; phase(row) = phaseDeg(ip);
            [r(row),rho(row),r2(row),n(row)] = associationStats( ...
                staOSIvector,Y(:,ip),minValidPoints,5);
        end
    end
    phaseAssociation = table(metric,phase,n,r,rho,r2, ...
        'VariableNames',{'metric','phaseDeg','n','pearsonR', ...
        'spearmanRho','cvR2'});
end

measuredOSIPhaseAssociation = table();
if any(isfinite(measuredZp(:)))
    nRows = 2*2*numel(phaseDeg);
    osiType = strings(nRows,1); metric = strings(nRows,1);
    phase = nan(nRows,1); n = zeros(nRows,1);
    r = nan(nRows,1); rho = nan(nRows,1); r2 = nan(nRows,1);
    row = 0;
    for io = 1:2
        if io==1
            X = measuredGratingOSI; osiLabel = "Peak OSI";
        else
            X = measuredGlobalOSI; osiLabel = "Global OSI";
        end
        for im = 1:2
            if im==1, Y = measuredZp; metricLabel = "Zp";
            else, Y = measuredZc; metricLabel = "Zc"; end
            for ip = 1:numel(phaseDeg)
                row = row+1;
                osiType(row) = osiLabel; metric(row) = metricLabel;
                phase(row) = phaseDeg(ip);
                [r(row),rho(row),r2(row),n(row)] = associationStats( ...
                    X,Y(:,ip),minValidPoints,5);
            end
        end
    end
    measuredOSIPhaseAssociation = table(osiType,metric,phase,n,r,rho,r2, ...
        'VariableNames',{'osiType','metric','phaseDeg','n','pearsonR', ...
        'spearmanRho','cvR2'});
end

writetable(cellSummary,fullfile(outDir,'STA_FT_OSI_cell_metrics.csv'));
writetable(phaseSummary,fullfile(outDir,'STA_FT_OSI_phase_ZpZc.csv'));
writetable(associationSummary,fullfile(outDir,'STA_FT_OSI_associations.csv'));
if ~isempty(phaseAssociation)
    writetable(phaseAssociation,fullfile(outDir, ...
        'STA_FT_OSI_phase_ZpZc_associations.csv'));
end
if ~isempty(measuredOSIPhaseAssociation)
    writetable(measuredOSIPhaseAssociation,fullfile(outDir, ...
        'measured_peak_global_OSI_phase_ZpZc_associations.csv'));
end

%% ---------------- Figure 1: what one static STA provides ----------------
validOSI = find(isfinite(staOSIvector));
[~,order] = sort(staOSIvector(validOSI));
if numel(order)>=3
    exampleIdx = validOSI(order(round(linspace(1,numel(order),3))));
else
    exampleIdx = validOSI;
end

figure('Color','w','Position',[40 40 1400 330*numel(exampleIdx)]);
tiledlayout(numel(exampleIdx),4,'TileSpacing','compact','Padding','compact');
for ii = 1:numel(exampleIdx)
    ic = exampleIdx(ii);
    rf = squeeze(STAdenoised(ic,:,:));

    nexttile;
    imagesc(xDeg,yDeg,rf); axis image; set(gca,'YDir','normal');
    colormap(gca,blueWhiteRed(256));
    lim = max(abs(rf(:))); if lim>0, caxis(lim*[-1 1]); end
    xlabel('Azimuth (deg)'); ylabel('Elevation (deg)');
    title(sprintf('Cell %s: static STA',string(cellID(ic))));

    nexttile;
    [F,fx,fy] = fftMagnitude(rf,degPerPixel);
    imagesc(fx,fy,log1p(F)); axis image; set(gca,'YDir','normal'); hold on;
    plot(experimentalSF*cosd(fftOriDeg), ...
        experimentalSF*sind(fftOriDeg),'w--','LineWidth',1.2);
    plot(-experimentalSF*cosd(fftOriDeg), ...
        -experimentalSF*sind(fftOriDeg),'w--','LineWidth',1.2);
    xlabel('f_x (cpd)'); ylabel('f_y (cpd)');
    title(sprintf('2-D FT; sampled ring %.2f cpd',experimentalSF));

    nexttile;
    t = fftOriTuning(ic,:);
    plot([fftOriDeg 180],[t t(1)],'k-','LineWidth',1.7);
    xlabel('Orientation (deg)'); ylabel('FT magnitude'); xlim([0 180]);
    title(sprintf('STA OSI = %.2f; AR = %.2f', ...
        staOSIvector(ic),staAR(ic))); box off;

    nexttile;
    g = measuredGrating(ic,:);
    plot([dirDeg 360],[g g(1)],'o-','Color',[.2 .45 .8], ...
        'LineWidth',1.5);
    xlabel('Measured direction (deg)'); ylabel('Trial-mean response');
    xlim([0 360]);
    title(sprintf('Measured grating OSI = %.2f',measuredGratingOSI(ic)));
    box off;
end
sgtitle(['A single-frame STA yields 0-180 deg orientation selectivity, ' ...
    'not 0-360 deg direction tuning']);
exportgraphics(gcf,fullfile(outDir,'STA_static_FT_OSI_examples.pdf'), ...
    'ContentType','vector');

%% ---------------- Figure 2: scalar prediction tests ----------------
figure('Color','w','Position',[40 40 1450 1050]);
tiledlayout(3,3,'TileSpacing','compact','Padding','compact');
for it = 1:nTargets
    nexttile;
    plotAssociation(staOSIvector,targetData{it},targetNames{it}, ...
        pearsonR(it),spearmanRho(it),cvR2(it));
end
sgtitle(['Can orientation selectivity from a static STA predict measured ' ...
    'grating and plaid metrics?']);
exportgraphics(gcf,fullfile(outDir,'STA_FT_OSI_scalar_associations.pdf'), ...
    'ContentType','vector');

%% ---------------- Figure 3: retain four-phase Zp/Zc ----------------
if any(isfinite(measuredZp(:)))
    phaseColor = lines(numel(phaseDeg));
    figure('Color','w','Position',[100 100 1150 480]);
    tiledlayout(1,2,'TileSpacing','compact','Padding','compact');
    nexttile;
    plotPhaseMetric(staOSIvector,measuredZp,phaseDeg,phaseColor,'Measured Z_p');
    nexttile;
    plotPhaseMetric(staOSIvector,measuredZc,phaseDeg,phaseColor,'Measured Z_c');
    sgtitle('STA-derived OSI versus measured pattern/component selectivity');
    exportgraphics(gcf,fullfile(outDir,'STA_FT_OSI_fourPhase_ZpZc.pdf'), ...
        'ContentType','vector');
end

%% ---------------- Figure 4: measured peak/global OSI controls ----------------
if any(isfinite(measuredZp(:)))
    phaseColor = lines(numel(phaseDeg));
    figure('Color','w','Position',[80 60 1150 900]);
    tiledlayout(2,2,'TileSpacing','compact','Padding','compact');
    nexttile;
    plotPhaseMetricWithStats(measuredGratingOSI,measuredZp,phaseDeg, ...
        phaseColor,'Measured Z_p','Measured peak OSI');
    nexttile;
    plotPhaseMetricWithStats(measuredGratingOSI,measuredZc,phaseDeg, ...
        phaseColor,'Measured Z_c','Measured peak OSI');
    nexttile;
    plotPhaseMetricWithStats(measuredGlobalOSI,measuredZp,phaseDeg, ...
        phaseColor,'Measured Z_p','Measured global OSI');
    nexttile;
    plotPhaseMetricWithStats(measuredGlobalOSI,measuredZc,phaseDeg, ...
        phaseColor,'Measured Z_c','Measured global OSI');
    sgtitle(['Measured pattern/component selectivity versus measured ' ...
        'peak and global grating OSI']);
    exportgraphics(gcf,fullfile(outDir, ...
        'measured_peak_global_OSI_fourPhase_ZpZc.pdf'), ...
        'ContentType','vector');
end

%% ---------------- Figure 5: equal-count trend summaries ----------------
[binID,binCenter] = equalCountBins(staOSIvector,nEqualBins);
figure('Color','w','Position',[100 100 1150 800]);
tiledlayout(2,2,'TileSpacing','compact','Padding','compact');
nexttile; plotBinned(binID,binCenter,measuredGratingOSI,'Measured grating OSI');
nexttile; plotBinned(binID,binCenter,staAR,'STA aspect ratio');
nexttile; plotBinned(binID,binCenter,meanMeasuredZp,'Mean measured Z_p');
nexttile; plotBinned(binID,binCenter,meanMeasuredZc,'Mean measured Z_c');
sgtitle('Equal-count bins of static-STA FT OSI');
exportgraphics(gcf,fullfile(outDir,'STA_FT_OSI_equalCount_trends.pdf'), ...
    'ContentType','vector');

save(fullfile(outDir,'STA_FT_OSI_measured_metrics_results.mat'), ...
    'cellSummary','phaseSummary','associationSummary','cellID','STAdenoised', ...
    'fftOriTuning','fftOriDeg','experimentalSF','measuredGrating', ...
    'measuredPlaid','measuredZp','measuredZc','ZpZcMeasured', ...
    'alignmentMethod','staName','respName','measuredOSISource', ...
    'measuredGlobalOSISource','phaseAssociation', ...
    'measuredOSIPhaseAssociation');

disp(associationSummary);
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
idx = [];
for i = 1:numel(f)
    v = S.(f{i});
    if isnumeric(v) && ndims(v)>=4 && size(v,2)==nDir && ...
            size(v,3)==nPhase && size(v,4)>=2
        idx(end+1) = i; %#ok<AGROW>
    end
end
if numel(idx)==1
    value = S.(f{idx}); name = string(f{idx});
elseif numel(idx)>1
    error('Multiple response tensors found; add the intended name to respCandidates.');
end
end

function STA = arrangeSTA(A,cellID)
if ~isempty(cellID)
    n = numel(cellID);
    if size(A,1)==n, STA = A;
    elseif size(A,3)==n, STA = permute(A,[3 1 2]);
    else, error('STA dimensions do not match STA IDs.'); end
elseif size(A,1)>size(A,3)
    STA = A;
else
    STA = permute(A,[3 1 2]);
end
end

function [staIdx,respIdx,cellID,method] = ...
    alignCells(R,P,STA,staID,respID,nSTA,nResp)
if ~isempty(staID) && ~isempty(respID)
    [tf,loc] = ismember(string(staID(:)),string(respID(:)));
    staIdx = find(tf); respIdx = loc(tf); cellID = staID(staIdx);
    method = "cell IDs";
elseif isfield(P,'cellsSelected') && numel(P.cellsSelected)==nSTA
    staIdx = (1:nSTA)'; respIdx = P.cellsSelected(:); cellID = respIdx;
    method = "saved cellsSelected";
elseif canRebuildCellsSelected(P)
    cellsSelected = rebuildCellsSelected(P);
    assert(numel(cellsSelected)==nSTA, ...
        'Reconstructed cellsSelected has %d cells; STA has %d.', ...
        numel(cellsSelected),nSTA);
    staIdx = (1:nSTA)'; respIdx = cellsSelected(:); cellID = respIdx;
    method = "reconstructed cellsSelected";
elseif isfield(R,'fittedIdx') && (numel(R.fittedIdx)==nSTA || ...
        sum(logical(R.fittedIdx(:)))==nSTA)
    staIdx = (1:nSTA)';
    if islogical(R.fittedIdx) || all(ismember(R.fittedIdx(:),[0 1]))
        respIdx = find(R.fittedIdx(:));
    else
        respIdx = R.fittedIdx(:);
    end
    cellID = respIdx;
    method = "fittedIdx";
elseif nSTA==nResp
    staIdx = (1:nSTA)'; respIdx = staIdx; cellID = staIdx;
    method = "matching array order";
else
    error('Cannot align %d STAs with %d response cells.',nSTA,nResp);
end
assert(all(respIdx>=1 & respIdx<=nResp),'Response indices exceed tensor size.');
end

function tf = canRebuildCellsSelected(S)
required = {'depth_all','cells_sigRFbyTime_On_all', ...
    'cells_sigRFbyTime_Off_all','bestTimePoint_all','resp_ind_dir_all'};
tf = all(isfield(S,required));
end

function cellsSelected = rebuildCellsSelected(S)
indCortex = find(S.depth_all>-1300);
indSigRF = sum(S.cells_sigRFbyTime_On_all,2)+ ...
    sum(S.cells_sigRFbyTime_Off_all,2);
listnc = (1:size(S.cells_sigRFbyTime_On_all,1))';
indRFpix = intersect(listnc(indSigRF>0),indCortex);
indRFcon = intersect(find(S.bestTimePoint_all(:,2)>1),indCortex);
cellsSelected = intersect(intersect(indRFpix,indRFcon),S.resp_ind_dir_all(:));
end

function rfOut = denoiseSTA(rf,sigmaPix,thresholdSigma)
rf(~isfinite(rf)) = 0;
rf = rf-mean(rf(:));
rad = max(1,ceil(3*sigmaPix));
g = exp(-((-rad:rad).^2)/(2*sigmaPix^2)); g = g/sum(g);
rfSmooth = conv2(g',g,rf,'same');
[ny,nx] = size(rf);
bw = max(2,round(min(nx,ny)*0.15));
border = false(ny,nx);
border(1:bw,:) = true; border(end-bw+1:end,:) = true;
border(:,1:bw) = true; border(:,end-bw+1:end) = true;
b = rfSmooth(border);
noiseSigma = 1.4826*median(abs(b-median(b)));
if ~isfinite(noiseSigma) || noiseSigma<=eps, noiseSigma = std(b); end
mask = abs(rfSmooth)>=thresholdSigma*max(noiseSigma,eps);
mask = conv2(double(mask),ones(3),'same')>=2;
if sum(mask(:))<5, rfOut = rfSmooth; else, rfOut = rfSmooth.*mask; end
rfOut = rfOut-mean(rfOut(:));
end

function tuning = fftRingTuning(rf,degPerPixel,SF,oriDeg)
[F,fx,fy] = fftMagnitude(rf,degPerPixel);
qx = SF*cosd(oriDeg); qy = SF*sind(oriDeg);
tuning = interp2(fx,fy,F,qx,qy,'linear',0);
end

function [F,fx,fy] = fftMagnitude(rf,degPerPixel)
[ny,nx] = size(rf);
if nx>1, wx = 0.5-0.5*cos(2*pi*(0:nx-1)/(nx-1)); else, wx = 1; end
if ny>1, wy = 0.5-0.5*cos(2*pi*(0:ny-1)/(ny-1)); else, wy = 1; end
F = abs(fftshift(fft2(rf.*(wy(:)*wx(:)'))));
fx = (-floor(nx/2):ceil(nx/2)-1)/(nx*degPerPixel);
fy = (-floor(ny/2):ceil(ny/2)-1)/(ny*degPerPixel);
end

function osi = orientationVectorOSI(tuning,oriDeg)
tuning = max(0,double(tuning(:))');
v = isfinite(tuning);
if sum(v)<3 || sum(tuning(v))<=eps, osi = nan; return; end
osi = abs(sum(tuning(v).*exp(1i*2*deg2rad(oriDeg(v)))))/sum(tuning(v));
osi = min(max(real(osi),0),1);
end

function [osi,pref] = orientationPeakOSI(tuning,oriDeg)
tuning = double(tuning(:))';
[rPref,idx] = max(tuning,[],'omitnan');
pref = oriDeg(idx);
[~,orthIdx] = min(abs(circularOrientationDifference(oriDeg,pref+90)));
rOrth = tuning(orthIdx);
osi = (rPref-rOrth)/max(rPref+rOrth,eps);
osi = min(max(osi,0),1);
end

function d = circularOrientationDifference(a,b)
d = mod(a-b+90,180)-90;
end

function ar = covarianceAR(rf,xDeg,yDeg)
[xx,yy] = meshgrid(xDeg,yDeg);
w = abs(rf).^2;
w(~isfinite(w)) = 0;
if sum(w(:))<=eps, ar = nan; return; end
w = w/sum(w(:));
mx = sum(w(:).*xx(:)); my = sum(w(:).*yy(:));
dx = xx-mx; dy = yy-my;
C = [sum(w(:).*dx(:).^2),sum(w(:).*dx(:).*dy(:)); ...
    sum(w(:).*dx(:).*dy(:)),sum(w(:).*dy(:).^2)];
e = sort(eig(C),'descend');
if numel(e)<2 || e(2)<=eps, ar = nan; else, ar = sqrt(e(1)/e(2)); end
end

function osi = peakOSI360(resp)
nCells = size(resp,1); nDir = size(resp,2);
osi = nan(nCells,1); orthShift = round(nDir/4);
for ic = 1:nCells
    r = resp(ic,:);
    [rPref,idx] = max(r,[],'omitnan');
    rOrth = r(mod(idx-1+orthShift,nDir)+1);
    osi(ic) = (rPref-rOrth)/max(abs(rPref)+abs(rOrth),eps);
end
osi = min(max(osi,0),1);
end

function osi = globalOSI360(resp,dirDeg)
% Global orientation-vector OSI from the complete measured 0-360 curve.
% Negative trial-mean values are set to zero so the vector denominator is
% well-defined; use a stored lab global OSI when one is available.
nCells = size(resp,1);
osi = nan(nCells,1);
for ic = 1:nCells
    r = max(0,double(resp(ic,:)));
    v = isfinite(r);
    if sum(v)>=3 && sum(r(v))>eps
        osi(ic) = abs(sum(r(v).*exp(1i*2*deg2rad(dirDeg(v)))))/sum(r(v));
    end
end
osi = min(max(real(osi),0),1);
end

function A = arrangeCellPhase(A,nCells,nPhase)
A = squeeze(double(A));
if size(A,1)==nCells && size(A,2)==nPhase
elseif size(A,2)==nCells && size(A,1)==nPhase, A = A';
elseif numel(A)==nCells*nPhase, A = reshape(A,nCells,nPhase);
else, error('Unexpected Zp/Zc size: %s',mat2str(size(A))); end
end

function mi = measuredMaskingIndex(grating,plaid)
nDir = numel(grating);
componentShift = round((120/2)/(360/nDir));
miAll = nan(nDir,size(plaid,2));
for id = 1:nDir
    i1 = mod(id-1-componentShift,nDir)+1;
    i2 = mod(id-1+componentShift,nDir)+1;
    expected = grating(i1)+grating(i2);
    den = plaid(id,:)+expected;
    valid = abs(den)>eps;
    miAll(id,valid) = (plaid(id,valid)-expected)./den(valid);
end
mi = mean(miAll(:),'omitnan');
end

function a = meanPhaseModulation(resp,phaseDeg)
X = [ones(numel(phaseDeg),1) cosd(phaseDeg(:)) sind(phaseDeg(:))];
aDir = nan(size(resp,1),1);
for id = 1:size(resp,1)
    y = resp(id,:)'; v = isfinite(y);
    if sum(v)>=3
        b = X(v,:)\y(v);
        amp = hypot(b(2),b(3)); scale = mean(abs(y(v)));
        aDir(id) = amp/max(amp+scale,eps);
    end
end
a = mean(aDir,'omitnan');
end

function [r,rho,cvR2,n] = associationStats(x,y,minPoints,nFold)
x = x(:); y = y(:); v = isfinite(x) & isfinite(y);
x = x(v); y = y(v); n = numel(x);
if n<minPoints || std(x)<=eps || std(y)<=eps
    r = nan; rho = nan; cvR2 = nan; return;
end
C = corrcoef(x,y); r = C(1,2);
rx = tiedRankLocal(x); ry = tiedRankLocal(y);
C = corrcoef(rx,ry); rho = C(1,2);

foldID = mod(randperm(n)-1,nFold)+1;
yHat = nan(n,1);
for k = 1:nFold
    test = foldID==k; train = ~test;
    b = [ones(sum(train),1) x(train)]\y(train);
    yHat(test) = [ones(sum(test),1) x(test)]*b;
end
cvR2 = 1-sum((y-yHat).^2)/max(sum((y-mean(y)).^2),eps);
end

function r = tiedRankLocal(x)
[s,order] = sort(x);
r = zeros(size(x));
i = 1;
while i<=numel(s)
    j = i;
    while j<numel(s) && s(j+1)==s(i), j = j+1; end
    r(order(i:j)) = mean(i:j);
    i = j+1;
end
end

function plotAssociation(x,y,yLabel,r,rho,cvR2)
x = x(:); y = y(:); v = isfinite(x) & isfinite(y);
scatter(x(v),y(v),30,'filled','MarkerFaceAlpha',0.55); hold on;
if sum(v)>=2 && std(x(v))>eps
    b = [ones(sum(v),1) x(v)]\y(v);
    xx = linspace(min(x(v)),max(x(v)),100);
    plot(xx,b(1)+b(2)*xx,'k-','LineWidth',1.5);
end
xlabel('Static-STA FT OSI'); ylabel(yLabel);
title(sprintf('r %.2f; rho %.2f; CV R^2 %.2f',r,rho,cvR2));
xlim([0 1]); box off;
end

function plotPhaseMetric(x,Y,phaseDeg,phaseColor,yLabel)
hold on;
for ip = 1:numel(phaseDeg)
    scatter(x,Y(:,ip),30,phaseColor(ip,:),'filled', ...
        'MarkerFaceAlpha',0.55,'DisplayName',sprintf('%d deg',phaseDeg(ip)));
end
xlabel('Static-STA FT OSI'); ylabel(yLabel); xlim([0 1]);
legend('Location','best'); box off;
end

function plotPhaseMetricWithStats(x,Y,phaseDeg,phaseColor,yLabel,xLabel)
hold on;
legendText = strings(numel(phaseDeg),1);
for ip = 1:numel(phaseDeg)
    [~,rho,~,~] = associationStats(x,Y(:,ip),5,5);
    scatter(x,Y(:,ip),30,phaseColor(ip,:),'filled', ...
        'MarkerFaceAlpha',0.55);
    legendText(ip) = sprintf('%d deg: rho %.2f',phaseDeg(ip),rho);
end
xlabel(xLabel); ylabel(yLabel); xlim([0 1]);
legend(legendText,'Location','best'); box off;
end

function [binID,binCenter] = equalCountBins(x,nBins)
binID = nan(size(x)); binCenter = nan(nBins,1);
v = find(isfinite(x)); [~,ord] = sort(x(v));
for ib = 1:nBins
    lo = floor((ib-1)*numel(v)/nBins)+1;
    hi = floor(ib*numel(v)/nBins);
    if hi>=lo
        idx = v(ord(lo:hi)); binID(idx) = ib;
        binCenter(ib) = mean(x(idx),'omitnan');
    end
end
end

function plotBinned(binID,binCenter,y,yLabel)
nBins = numel(binCenter); m = nan(nBins,1); se = nan(nBins,1);
for ib = 1:nBins
    v = binID==ib & isfinite(y);
    m(ib) = mean(y(v),'omitnan');
    se(ib) = std(y(v),'omitnan')/sqrt(max(sum(v),1));
end
errorbar(binCenter,m,se,'o-','LineWidth',1.5,'MarkerFaceColor',[.2 .5 .8]);
xlabel('Static-STA FT OSI (equal-count bin mean)'); ylabel(yLabel);
xlim([0 1]); box off;
end

function cmap = blueWhiteRed(n)
if nargin<1, n = 256; end
n1 = floor(n/2); n2 = n-n1;
cmap = [linspace(0.1,1,n1)' linspace(0.3,1,n1)' ones(n1,1); ...
    ones(n2,1) linspace(1,0.2,n2)' linspace(1,0.1,n2)'];
end
