function [oriFitStruct] = getOrientationTuningCurveFit(avg_resp_dir)

    nCells = size(avg_resp_dir, 1);
    nStimDir = size(avg_resp_dir, 2);
    nOri = nStimDir / 2;

    stimOriDeg = 0:(180 / nOri):(180 - 180 / nOri);
    stimOriRad = deg2rad(stimOriDeg);

    fitOriDeg = 0:1:179;
    fitOriRad = deg2rad(fitOriDeg);

    oriFitStruct.prefOri = nan(nCells, 1);
    oriFitStruct.maxResp = nan(nCells, 1);
    oriFitStruct.yfit = nan(180, nCells);
    oriFitStruct.oriResp = nan(nCells, nOri);

    for iCell = 1:nCells

        resp = squeeze(avg_resp_dir(iCell, :, 1, 1, 1));
        resp(resp < 0) = 0;

        oriResp = (resp(1:nOri) + resp(nOri + 1:end)) / 2;
        oriFitStruct.oriResp(iCell, :) = oriResp;

        b0 = min(oriResp);
        R0 = max(oriResp) - min(oriResp);
        k0 = 1;

        [~, prefInd0] = max(oriResp);
        u0 = stimOriRad(prefInd0);

        x0 = [b0, k0, R0, u0];

        lb = [0, 0, 0, 0];
        ub = [Inf, 50, Inf, pi];

        opts = optimset('Display', 'off');

        modelFun = @(p, x) p(1) + p(3) .* exp( ...
            p(2) .* (cos(2 .* (x - p(4))) - 1));

        sseFun = @(p) sum((oriResp(:) - modelFun(p, stimOriRad(:))).^2);

        pHat = fminsearchbnd(sseFun, x0, lb, ub, opts);

        yfit = modelFun(pHat, fitOriRad(:));

        oriFitStruct.b(iCell, 1) = pHat(1);
        oriFitStruct.k(iCell, 1) = pHat(2);
        oriFitStruct.R(iCell, 1) = pHat(3);
        oriFitStruct.u(iCell, 1) = pHat(4);

        [oriFitStruct.maxResp(iCell), prefFitInd] = max(yfit);
        oriFitStruct.prefOri(iCell) = fitOriDeg(prefFitInd);
        oriFitStruct.yfit(:, iCell) = yfit;
    end
    oriFitStruct.oriSmooth = oriFitStruct.yfit;
    oriFitStruct.oriDegSmooth = fitOriDeg;
end