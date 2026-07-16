close all; clearvars; clc;

%% debug mode one cell test
debugMode = false;
debugCell = 1080;   % check indRFint
%rng(0,'twister');   % randomness fully reproducible

%% Load data 
% load file with data concatenated across experiments

analysisDir=('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\sara\Analysis\Neuropixel\CrossOri\randDirFourPhase');
load([analysisDir '\CrossOri_randDirFourPhase_summary.mat'])

% totalCells = totCells;   % cell number

fprintf('Loaded %d cells.\n', totalCells);

%%
vars = whos('-file', fullfile(analysisDir, ...
    'CrossOri_randDirFourPhase_summary.mat'));

for i = 1:numel(vars)
    fprintf('%-35s %s\n', vars(i).name, mat2str(vars(i).size));
end

%% Decide what index of cells you're going to use

indCortex   = find(depth_all>-1300);
ind_sigRF   = sum(cells_sigRFbyTime_On_all,2)+sum(cells_sigRFbyTime_Off_all,2);
listnc      = 1:size(cells_sigRFbyTime_On_all,1);
indRF_pix   = listnc(ind_sigRF>0)';
indRF_con   = find(bestTimePoint_all(:,2)>1);

indRF_pix   = intersect(indRF_pix,indCortex);
indRF_con   = intersect(indRF_con,indCortex);
indRFint    = unique([indRF_pix; indRF_con]);
idxInt      = intersect(indRF_pix, indRF_con);  % both mask and contrast method

idxMask     = setdiff(indRF_pix, indRF_con); % mask method only
idxCon      = setdiff(indRF_con,indRF_pix); % contrast method only

ind         = intersect(resp_ind_dir_all, find(DSI_all>.5));
ind_DS      = intersect(idxInt,ind); % visually responsive and direction-selective
% Use visually responsive cells with reliable RFs.
cellsSelected = intersect(idxInt, resp_ind_dir_all);

if debugMode
    assert(ismember(debugCell, cellsSelected), ...
        'debugCell is not in cellsSelected.');
    cellsSelected = debugCell;
end

cellIDs = cellsSelected(:);

fprintf('Selected %d cells for fitting.\n', numel(cellIDs));

%%

rfvisresp = intersect(resp_ind_dir_all, idxInt);
figure; 
    histogram(DSI_all(rfvisresp),100)

 xxx = find(DSI_all(rfvisresp)<.3);




%% Calculate time point of STA
% The first dimension of bestTimePoint_all is the one computed by the local contrast method

cellsToRun = unique(cellIDs(:))';

% Calculate best it by taking max zscore 
for ic = cellsToRun
    for it = 2:4
        avgImgZscore(it,:,:) = squeeze(avgImgZscore_all(ic,it,:,:));     % Grab avg zscore STA images for time points 0.04 0.07 and 0.1
    end 
    [m, it_best]            = max(sum(sum(abs(avgImgZscore(:,:,:)),2),3),[],1);      % which of the three has the max cumulative zscore?
    bestTimePoint_all(ic,3) = it_best;
    bestTimePoint_all(ic,4) = m;
end

% Calculate best it by taking zscore threshold mask and taking highest cumulative CI value
for ic = cellsToRun
    for it = 2:4
        pixMask             = imgaussfilt(abs(squeeze(avgImgZscoreThresh_all(ic,it,:,:))),3);
        conMap              = squeeze(localConMap_map_all(ic, it, :,:));
        maskMap             = pixMask.*conMap;
        maskMap_sum(ic,it)  = mean(maskMap(:));
    end
    [m, it_best]            = max(maskMap_sum(ic,:),[],2);
    bestTimePoint_all(ic,5) = it_best;
    bestTimePoint_all(ic,6) = m;   
end


%% Find center of RF and crop
%% Crop STA around RF center

sideLength = 29;
nSelected = numel(cellIDs);

rotateSTA = false; % change this
rotationK = 1;   % 1 = 90 deg CCW, -1 = 90 deg CW

STA_cropped = nan(sideLength, sideLength, nSelected);

for k = 1:nSelected

    ic = cellIDs(k);

    fprintf('k = %d maps to original cell index ic = %d\n', k, ic);

    avgImgZscore = squeeze(avgImgZscore_all(ic, :, :, :));
    bestTP = bestTimePoint_all(ic, 1);

    data = squeeze(avgImgZscore(bestTP, :, :));
    data = medfilt2(imgaussfilt(data, 1));

    [el, az] = getRFcenter(data);

    STA_crop = cropRFtoCenter(az, el, data, sideLength);

    if rotateSTA
        STA_crop = rot90(STA_crop, rotationK);
    end

    STA_cropped(:, :, k) = STA_crop;
end

options.visualize = 0;
options.parallel  = 1;
options.shape     = 'elliptical';
options.runs      = 48;
% options.getAllFits = false;

% copy format from the first example
modelRegistry = [
    struct( ...
        'name','Noncon DoG', ...
        'type','standard', ...
        'fitFcn', @(STA) fitNonConcentricEllipticalDoG(STA,'unnormalized',20), ...
        'k',10)

    struct( ...
        'name','Gabor', ...
        'type','sg', ...
        'fitFcn', @(STA) fit2dGabor_JM(STA,options), ...
        'k',10)

    struct( ...
        'name','Gaussian', ...
        'type','standard', ...
        'fitFcn', @(STA) fitEllipticalGaussian(STA,options), ...
        'k',7)
];

%% Global STA contrast scale

allPeak = nan(nSelected, 1);

for k = 1:nSelected
    sta = STA_cropped(:, :, k);
    allPeak(k) = max(abs(sta(:)));
end

globalClim = prctile(allPeak, 95);
%%
%% Run model fit

omitCells = [114, 634, 879, 1413, 1441, 1508, 1535, 1558, 1849];

fitIdx = 1:nSelected;

results = runRFModelComparison( ...
    fitIdx, ...
    cellIDs, ...
    STA_cropped, ...
    modelRegistry, ...
    omitCells, ...
    'pdf', ...
    'test_all_fit.pdf');

%%
modelNames = {results.modelRegistry.name};
nModels = numel(modelNames);

R2mat = nan(numel(results.cellIDs), nModels);

for m = 1:nModels
    R2mat(:, m) = results.R2{m};
end

R2table = array2table(R2mat, ...
    'VariableNames', matlab.lang.makeValidName(modelNames));

R2table.cellID = results.cellIDs;
R2table = movevars(R2table, 'cellID', 'Before', 1);

disp(R2table)

%%
%% Export AR based on actual MATLAB fitting functions

dogModelIdx   = 1;   % Noncon DoG
gaborModelIdx = 2;   % Gabor

outMat = 'effective_AR_MATLAB_DoG_Gabor_better.mat';

R2_dog   = results.R2{dogModelIdx};
R2_gabor = results.R2{gaborModelIdx};

cellsDoGBetter   = results.cellIDs(R2_dog > R2_gabor);
cellsGaborBetter = results.cellIDs(R2_gabor >= R2_dog);

fprintf('DoG better cells: %d\n', numel(cellsDoGBetter));
fprintf('Gabor better cells: %d\n', numel(cellsGaborBetter));

FORMULA_EDGE_K = 1.5;
AMP_FRAC_THRESH = 0.31;
VISIBLE_FIELD_SIZE = 25.0;

dog_envelope_axis = nan(numel(cellsDoGBetter), 3);
dog_offset_axis   = nan(numel(cellsDoGBetter), 3);
dog_longer_pick   = nan(numel(cellsDoGBetter), 3);

gabor_tau_AR      = nan(numel(cellsGaborBetter), 2);

%% DoG-better cells: formula AR

dogCounter = 0;

for ii = 1:numel(results.cellIDs)

    cellID = results.cellIDs(ii);

    if ~ismember(cellID, cellsDoGBetter)
        continue
    end

    dogCounter = dogCounter + 1;

    p = results.params{dogModelIdx}{ii};
    p = p(:)';

    geom = dogFormulaGeometry_fromActualParams( ...
        p, FORMULA_EDGE_K, AMP_FRAC_THRESH, VISIBLE_FIELD_SIZE);

    dog_envelope_axis(dogCounter,:) = ...
        [cellID, geom.envelope_major, geom.envelope_minor];

    dog_offset_axis(dogCounter,:) = ...
        [cellID, geom.offset_major, geom.offset_minor];

    dog_longer_pick(dogCounter,:) = ...
        [cellID, geom.chosen_major, geom.chosen_minor];
end

%% Gabor-better cells: AR from sigmax/sigmay

gaborCounter = 0;

for ii = 1:numel(results.cellIDs)

    cellID = results.cellIDs(ii);

    if ~ismember(cellID, cellsGaborBetter)
        continue
    end

    gaborCounter = gaborCounter + 1;

    gfit = results.params{gaborModelIdx}{ii};

    if isstruct(gfit) && isfield(gfit, 'sigmax') && isfield(gfit, 'sigmay')
        sigmax = gfit.sigmax;
        sigmay = gfit.sigmay;
    elseif isnumeric(gfit)
        % fallback if runRFModelComparison converted Gabor params to vector:
        % [a b x0 y0 sigmax sigmay theta phi lambda phase]
        sigmax = gfit(5);
        sigmay = gfit(6);
    else
        error('Cannot read Gabor params for cell %d', cellID);
    end

    tauAR = max(abs(sigmax), abs(sigmay)) / ...
            max(min(abs(sigmax), abs(sigmay)), eps);

    gabor_tau_AR(gaborCounter,:) = [cellID, tauAR];
end

%% Save

save(outMat, ...
    'cellsDoGBetter', ...
    'cellsGaborBetter', ...
    'dog_envelope_axis', ...
    'dog_offset_axis', ...
    'dog_longer_pick', ...
    'gabor_tau_AR');

fprintf('Saved AR output to %s\n', outMat);

function geom = dogFormulaGeometry_fromActualParams(p, k, ampThresh, visibleFieldSize)

% Actual fitNonConcentricEllipticalDoG order:
% p = [Ac As sigmaC sigmaS tau theta x0 y0 dx dy]

Ac    = p(1);
As    = p(2);
sc    = p(3);
ss    = p(4);
tau   = p(5);
theta = p(6);
x0    = p(7);
y0    = p(8);
dx    = p(9);
dy    = p(10);

% In model:
% exp(-(X'^2 + (tau*Y')^2)/(2*sigma^2))
% so sigma_x = sigma, sigma_y = sigma/tau
sigx1 = sc;
sigy1 = sc / max(abs(tau), eps);

sigx2 = ss;
sigy2 = ss / max(abs(tau), eps);

x01 = x0;
y01 = y0;
x02 = x0 + dx;
y02 = y0 + dy;

offset = sqrt(dx^2 + dy^2);
offset_axis = atan2(dy, dx);

if sigx1 >= sigy1
    phi_gaussian = theta;
else
    phi_gaussian = theta + pi/2;
end

if offset > 1e-9
    phi_offset = offset_axis;
else
    phi_offset = phi_gaussian;
end

g.x01 = x01; g.y01 = y01;
g.x02 = x02; g.y02 = y02;
g.sigx1 = sigx1; g.sigy1 = sigy1; g.theta1 = theta;
g.sigx2 = sigx2; g.sigy2 = sigy2; g.theta2 = theta;

maxAmp = max([abs(Ac), abs(As), eps]);

useG1 = abs(Ac) >= ampThresh * maxAmp;
useG2 = abs(As) >= ampThresh * maxAmp;

offsetCand   = buildFormulaCandidate_MATLAB(g, phi_offset, k);
envelopeCand = buildFormulaCandidate_MATLAB(g, phi_gaussian, k);

if useG1 && ~useG2
    chosen = singleGaussianCandidate_MATLAB(g, 1, phi_gaussian, k);

elseif useG2 && ~useG1
    chosen = singleGaussianCandidate_MATLAB(g, 2, phi_gaussian, k);

elseif ~useG1 && ~useG2
    chosen = singleGaussianCandidate_MATLAB(g, 1, phi_gaussian, k);

else
    if offsetCand.formula_major >= envelopeCand.formula_major
        chosen = offsetCand;
    else
        chosen = envelopeCand;
    end

    if chosen.formula_major > visibleFieldSize || chosen.formula_minor > visibleFieldSize
        g1single = singleGaussianCandidate_MATLAB(g, 1, phi_gaussian, k);
        g2single = singleGaussianCandidate_MATLAB(g, 2, phi_gaussian, k);

        if g1single.formula_major <= g2single.formula_major
            chosen = g1single;
        else
            chosen = g2single;
        end
    end
end

geom.envelope_major = envelopeCand.formula_major;
geom.envelope_minor = envelopeCand.formula_minor;

geom.offset_major = offsetCand.formula_major;
geom.offset_minor = offsetCand.formula_minor;

geom.chosen_major = chosen.formula_major;
geom.chosen_minor = chosen.formula_minor;
geom.chosen_AR    = chosen.formula_major / max(chosen.formula_minor, eps);

end


function cand = buildFormulaCandidate_MATLAB(g, phi_axis, k)

phi_perp = phi_axis + pi/2;

u_axis = [cos(phi_axis), sin(phi_axis)];
u_perp = [cos(phi_perp), sin(phi_perp)];

c1 = [g.x01, g.y01];
c2 = [g.x02, g.y02];

r1_axis = ellipseRadius_MATLAB(g.sigx1, g.sigy1, g.theta1, phi_axis, k);
r1_perp = ellipseRadius_MATLAB(g.sigx1, g.sigy1, g.theta1, phi_perp, k);

r2_axis = ellipseRadius_MATLAB(g.sigx2, g.sigy2, g.theta2, phi_axis, k);
r2_perp = ellipseRadius_MATLAB(g.sigx2, g.sigy2, g.theta2, phi_perp, k);

c1_axis = dot(c1, u_axis);
c2_axis = dot(c2, u_axis);

c1_perp = dot(c1, u_perp);
c2_perp = dot(c2, u_perp);

axis_low  = min(c1_axis - r1_axis, c2_axis - r2_axis);
axis_high = max(c1_axis + r1_axis, c2_axis + r2_axis);

perp_low  = min(c1_perp - r1_perp, c2_perp - r2_perp);
perp_high = max(c1_perp + r1_perp, c2_perp + r2_perp);

axis_len = axis_high - axis_low;
perp_len = perp_high - perp_low;

cand.formula_major = max(axis_len, perp_len);
cand.formula_minor = min(axis_len, perp_len);

end


function cand = singleGaussianCandidate_MATLAB(g, whichGaussian, phi_axis, k)

phi_perp = phi_axis + pi/2;

if whichGaussian == 1
    sigx = g.sigx1;
    sigy = g.sigy1;
    theta = g.theta1;
else
    sigx = g.sigx2;
    sigy = g.sigy2;
    theta = g.theta2;
end

r_axis = ellipseRadius_MATLAB(sigx, sigy, theta, phi_axis, k);
r_perp = ellipseRadius_MATLAB(sigx, sigy, theta, phi_perp, k);

axis_len = 2 * r_axis;
perp_len = 2 * r_perp;

cand.formula_major = max(axis_len, perp_len);
cand.formula_minor = min(axis_len, perp_len);

end


function r = ellipseRadius_MATLAB(sigx, sigy, theta, phi, k)

a = phi - theta;

denom = cos(a)^2 / sigx^2 + sin(a)^2 / sigy^2;

r = k / sqrt(denom + eps);

end

