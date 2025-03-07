figure
hold on
counter = 1;
counter2 = 1;
for n = 1:length(SumSt)
if strcmp(SumSt(n).handID, 'MLI')
if strcmp(SumSt(n).MLIexpertID, 'ccg')
if length(SumSt(n).BiggestWFstruct.NormBiggestAligned) == 71
    x = [SumSt(n).BiggestWFstruct.NormBiggestAligned];
    x = x/-min(x);
    %plot(x/-min(x), 'Color', ParulaColors(round([SumSt(n).PC_dist])+1,:), 'LineWidth', 1);
    plot(x, 'Color', 'm', 'LineWidth', 1);
    %if x(33)/-min(x)<=.5
    MLIs(counter).height = max(x(26:50));
    %end
    MLIs(counter).index=n;
    if isfield(SumSt(n).BiggestWFstruct, 'flipped')
        MLIs(counter).flipped = 1;
    end
    if MLIs(counter).height<=.336
    plot(x/-min(x), 'Color', 'c', 'LineWidth', 1);
    MLIs(counter).flat = 1;
    end
    counter = counter + 1;
else
    x = [SumSt(n).BiggestWFstruct.NormBiggestAligned];
    x = x/-min(x);
    %plot(x(30:end-30)/-min(x(33:end-30)), 'Color', ParulaColors(round([SumSt(n).PC_dist])+1,:), 'LineWidth', 1);
    plot(x(30:end-30), 'Color', 'm', 'LineWidth', 1);
    %if x(63)/-min(x)<=.5
    MLIs(counter).height = max(x(56:80));
    %end
    MLIs(counter).index=n;
    if isfield(SumSt(n).BiggestWFstruct, 'flipped')
        MLIs(counter).flipped = 1;
    end
    if MLIs(counter).height<=.336
    plot(x(30:end-30), 'Color', 'c', 'LineWidth', 1);
    MLIs(counter).flat = 1;
    end
    counter = counter + 1;
end
end
end
end
title('MLI ccg')
FormatFigure
ylim([-1 1]);
%saveas(gca, 'MLI ccg')
%print('MLI ccg', '-dpsc', '-painters');
            
%figure
hold on
for n = 1:length(SumSt)
if strcmp(SumSt(n).handID, 'MLI')
if strcmp(SumSt(n).MLIexpertID, 'layer')
if length(SumSt(n).BiggestWFstruct.NormBiggestAligned) == 71
    x = [SumSt(n).BiggestWFstruct.NormBiggestAligned];
    x = x/-min(x);
    plot(x, 'Color', 'k', 'LineWidth', 1);
    %if x(63)/-min(x)<=.5
    MLIs(counter).height = max(x(26:50));
    %end
    MLIs(counter).index=n;
    if isfield(SumSt(n).BiggestWFstruct, 'flipped')
        MLIs(counter).flipped = 1;
    end
    if MLIs(counter).height<=.336
    plot(x/-min(x), 'Color', 'y', 'LineWidth', 1);
    MLIs(counter).flat = 1;
    end
    counter = counter + 1;
else
    x = [SumSt(n).BiggestWFstruct.NormBiggestAligned];
    x = x/-min(x);
    plot(x(30:end-30), 'Color','k', 'LineWidth', 1);
   %if x(63)/-min(x)<=.5    
    MLIs(counter).height = max(x(56:80));
    %end
    MLIs(counter).index=n;
    if isfield(SumSt(n).BiggestWFstruct, 'flipped')
        MLIs(counter).flipped = 1;
    end
    if MLIs(counter).height<=.336
    plot(x(30:end-30)/-min(x(33:end-30)), 'Color','y', 'LineWidth', 1);
    MLIs(counter).flat = 1;
    end
    counter = counter + 1;
end
end
end
end
title('MLI layer')
FormatFigure
ylim([-1 1]);
%saveas(gca, 'MLI layer')
%print('layer', '-dpsc', '-painters');
            