function visualizeComparison(STA, results, modelRegistry, k, ic, ii)

nModels = numel(modelRegistry);
clim = max(abs(STA(:)));

figure('Color','w','Position',[100 200 300*(nModels+1) 300]);
movegui('center');

subplot(1,nModels+1,1)
imagesc(STA,[-clim clim]); axis image off; colormap gray
title(sprintf('STA\nCell %d (ii=%d)', ic, ii))

for m = 1:nModels

    RF = results.models{m}{k};
    R2 = results.R2{m}(k);
    AIC = results.AIC{m}(k);

    subplot(1,nModels+1,m+1)
    imagesc(RF,[-clim clim]); axis image off
    title(sprintf('%s\nR^2=%.2f | AICc=%.1f', ...
        modelRegistry(m).name, R2, AIC))

end

sgtitle(sprintf('RF Model Comparison - Cell %d', ic))

end