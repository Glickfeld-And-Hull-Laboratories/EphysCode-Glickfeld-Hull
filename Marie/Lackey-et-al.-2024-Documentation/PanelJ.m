for n = 1:length(MLIs)
[MAX, maxi] = max(MLIs(n).BiggestWFstruct.NormBiggestAligned(20:end));
maxi = maxi + 20;
[MIN, mini] = min(MLIs(n).BiggestWFstruct.NormBiggestAligned);
MLIs(n).WFh = MAX-MIN;
MLIs(n).WFhalfH = MAX - mean(MLIs(n).BiggestWFstruct.NormBiggestAligned(1:5));
MLIs(n).WFbottomhalfH = mean(MLIs(n).BiggestWFstruct.NormBiggestAligned(1:5))-MIN;

MLIs(n).WFw = maxi-mini;
end

%figure
%for n = 1:length(MLIs)
%scatter(MLIs(n).WFw/33.33333, MLIs(n).WFhalfH/MLIs(n).WFbottomhalfH, 200, [.8 .8 .8])
%hold on
%end
%for n = 1:length(MLIsTyped)
%if strcmp({MLIsTyped(n).MLItype}, 'A')
%scatter(MLIsTyped(n).WFw/33.33333, MLIsTyped(n).WFhalfH/MLIsTyped(n).WFbottomhalfH, 200, 'm')
%hold on
%end
%if strcmp({MLIsTyped(n).MLItype}, 'B')
%scatter(MLIsTyped(n).WFw/33.33333, MLIsTyped(n).WFhalfH/MLIsTyped(n).WFbottomhalfH, 200, 'g')
%end
%end

%scatter(mean([MLIsTyped(strcmp({MLIsTyped.MLItype}, 'A')).WFw])/33.3333, mean([MLIsTyped(strcmp({MLIsTyped.MLItype}, 'A')).WFhalfH]/[MLIsTyped(strcmp({MLIsTyped.MLItype}, 'A')).WFbottomhalfH]), 200, 'm', 'filled')
%scatter(mean([MLIsTyped(strcmp({MLIsTyped.MLItype}, 'B')).WFw])/33.3333, mean([MLIsTyped(strcmp({MLIsTyped.MLItype}, 'B')).WFhalfH]/[MLIsTyped(strcmp({MLIsTyped.MLItype}, 'B')).WFbottomhalfH]), 200, 'g', 'filled')
%FigureWrap('WF_ratio_w', 'WF_ratio_w', 'width', 'peak:trough', NaN, NaN);

figure
for n = 1:length(MLIs)
    if isempty([MLIs(n).Type])
scatter(MLIs(n).WFhalfH, MLIs(n).WFbottomhalfH, 200, 'k', 'filled')
hold on
    end
end
for n = 1:length(MLIs)
if strcmp({MLIs(n).Type}, 'A')
scatter(MLIs(n).WFhalfH, MLIs(n).WFbottomhalfH, 200, 'm', 'filled')
hold on
end
if strcmp({MLIs(n).Type}, 'B')
scatter(MLIs(n).WFhalfH, MLIs(n).WFbottomhalfH, 200, 'g', 'filled')
end
end
%scatter((mean([MLIsTyped(strcmp({MLIsTyped.MLItype}, 'A')).WFhalfH])), mean([MLIsTyped(strcmp({MLIsTyped.MLItype}, 'A')).WFbottomhalfH]), 200, 'm', 'filled')
%scatter((mean([MLIsTyped(strcmp({MLIsTyped.MLItype}, 'B')).WFhalfH])), mean([MLIsTyped(strcmp({MLIsTyped.MLItype}, 'B')).WFbottomhalfH]), 200, 'g', 'filled')
% FigureWrap('WF_ratio', 'WF_ratio', 'peak', 'trough', NaN, NaN);


figure
hold on
WFs_B = [];
WFs_A = [];
WFs_ = [];

for n = 1:length(MLIs)
    if (length(MLIs(n).BiggestWFstruct.NormBiggestAligned)) < 100
    WFs(n).N = MLIs(n).BiggestWFstruct.NormBiggestAligned;
    %plot(WFs(n).N, 'k')
    else
        WFs(n).N = MLIs(n).BiggestWFstruct.NormBiggestAligned(31:101);
        %plot(WFs(n).N, 'k')
    end
end
shadedErrorBar2([1:71], mean(struct2mat(WFs, 'N')), std(struct2mat(WFs, 'N'))/sqrt(size((struct2mat(WFs, 'N')),1)), 'lineProp', 'k')


for n = 1:length(MLIsA)
    if (length(MLIsA(n).BiggestWFstruct.NormBiggestAligned)) < 100
    WFs_A(n).N = MLIsA(n).BiggestWFstruct.NormBiggestAligned;
    %plot(WFs_A(n).N, 'm')
    else
        WFs_A(n).N = MLIsA(n).BiggestWFstruct.NormBiggestAligned(31:101);
        %plot(WFs_A(n).N, 'm')
    end
end
shadedErrorBar2([1:71], mean(struct2mat(WFs_A, 'N')), std(struct2mat(WFs_A, 'N'))/sqrt(size((struct2mat(WFs_A, 'N')),1)), 'lineProp', 'm')

for n = 1:length(MLIsB)
    WFs_B(n).N = MLIsB(n).BiggestWFstruct.NormBiggestAligned;
    %plot(WFs_B(n).N, 'g')
end
shadedErrorBar2([1:71], mean(struct2mat(WFs_B, 'N')), std(struct2mat(WFs_B, 'N'))/sqrt(size((struct2mat(WFs_B, 'N')),1)), 'lineProp', 'g')
plot([30 63.33333], [-4 -4], 'k');