function [AlignMode, I, m] = AlignPrep(WVFmatrix)
figure
hold on
Baseline = mean(WVFmatrix(:,1:10), 'all');
AvgWvFcheck = avgeWaveforms(WVFmatrix);
checkPeak = max(AvgWvFcheck) - Baseline;
checkTrough = Baseline - min(AvgWvFcheck);
if checkPeak > checkTrough
    AlignMode = 1 %peak
    AvgWvFcheck = -(AvgWvFcheck);
elseif checkPeak <= checkTrough
    AlignMode = 0 %trough
else
    fprintf('error at line 36')
end
[m, I] = min(AvgWvFcheck);

plot(AvgWvFcheck);
hold on
yline(Baseline);
scatter(I, m);
hold off
figure
end