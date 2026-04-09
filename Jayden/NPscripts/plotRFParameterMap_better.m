function plotRFParameterMap_better(STA_cropped, results)

paramsCell = results.params{1};
nCells = length(paramsCell);

S = nan(nCells,1);   % surround prominence
C = nan(nCells,1);   % carrier prominence

for k = 1:nCells
    params = paramsCell{k};

    if isempty(params) || any(isnan(params))
        continue
    end

    Ac = params(1);
    As = params(2);
    sc = params(3);
    ss = sc + params(4);
    f  = params(9);

    S(k) = abs(As) * ss^2 / (abs(Ac) * sc^2 + eps);
    C(k) = f * sc;
end

figure('Position',[200 200 900 700]);
scatter(S, C, 25, 'k', 'filled');
xlabel('Surround prominence  |As| \cdot \sigma_s^2 / (|Ac| \cdot \sigma_c^2)');
ylabel('Carrier prominence  f \cdot \sigma_c');
title('DoG-like to Gabor-like parameter map');
grid on; box off;

hold on;
text(max(S)*0.75, max(C)*0.1, 'DoG-like', 'FontSize', 12);
text(max(S)*0.1,  max(C)*0.75, 'Gabor-like', 'FontSize', 12);
text(max(S)*0.75, max(C)*0.75, 'Hybrid', 'FontSize', 12);
text(max(S)*0.1,  max(C)*0.1, 'Weak / ambiguous', 'FontSize', 12);