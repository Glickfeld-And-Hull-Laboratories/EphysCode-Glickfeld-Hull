%create boxplot from struct
function SummaryStruct = BoxFromStructChar(struct, excLatencyLim, inhLatencyLim, TimeGridSize, char, char2, color);
%color is a vector of colors (3 element)
%justdata is data from struct without labels or fields
%char is a character variable specifying cell type
%color is a vector of unique colors

ISIrange = [0 .3];


clear justdata 
clear onevector
m = 1;
k = 1;

for n = 1:length(struct)

    if ((strcmp(struct(n).CellType, char)) && (strcmp(struct(n).respType, char2)))
 
        if (((struct(n).EXClatency) < excLatencyLim) && (struct(n).INHlatency < inhLatencyLim))
        
            SummaryStruct(k).UnitID = struct(n).unitID;
            SummaryStruct(k).filename = struct(n).fileName;
            SummaryStruct(k).TimeLim = struct(n).TimeLim;
            %SummaryStruct(k).IDtype = struct(n).IDtype;
            trigger = [struct(n).Laser];
            unit = struct(n).unitID;

            TimeGridB = trigger;
            TimeGridA = trigger - TimeGridSize;

            TimeLim = struct(n).TimeLim;
            
            %figure
            SummaryStruct(k).BaselineFR = FRstructTimeGridTimeLimit(TimeGridA, TimeGridB, TimeLim, struct, unit);
            BaselineFR(k,1) = SummaryStruct(k).BaselineFR;
            
            
            [medianISI, ~] = ISIstructTimeGridTimeLim(TimeGridA, TimeGridB, struct, unit, ISIrange, TimeLim, .001);
            SummaryStruct(k).medianISI = medianISI;
            MedianISI(k,1) = medianISI;
            SummaryStruct(k).excLatency = struct(n).EXClatency;
            SummaryStruct(k).inhLatency = struct(n).INHlatency;
            excLatencyList(k,1) = struct(n).EXClatency
            inhLatencyList(k,1) = struct(n).INHlatency;
            k = k+1;
        end
    end
end

figure
boxplot(BaselineFR);
hold on
%onevector = justdata(:,1)./justdata(:,1);

for p = 1:length(BaselineFR)
    %if strcmp(SummaryStruct(n).IDtype, 'laser')
    %    marker = '*';
    %end
    %if strcmp(SummaryStruct(n).IDtype, 'hand')
    %    marker = 'o';
    %end
    scatter(1, BaselineFR(p,1), 'MarkerEdgeColor', [color(p,1:3)]);
end
title('FR combo <20ms');
ylabel('Hz');
xlabel('granular?');
%ylim([0 50]);
FormatFigure
hold off
saveas(gcf, 'granFRboxCombo')
saveas(gcf, 'granFRboxCombo', 'epsc')

%INHIBITORYLATENCY
figure
boxplot(inhLatencyList);
hold on
%onevector = justdata(:,1)./justdata(:,1);

for r = 1:length(inhLatencyList)
    scatter(1, inhLatencyList(r,1), 'MarkerEdgeColor', [color(r,1:3)]);
end
title('inhlatency combo <20mx');
ylabel('sec');
xlabel('put.gran');
%ylim([0 .02]);
FormatFigure
hold off
saveas(gcf, 'granINHLATboxCombo')
saveas(gcf, 'granINHLATboxCombo', 'epsc')


%EXCITATORYLATENCY
figure
boxplot(excLatencyList);
hold on

for r = 1:length(excLatencyList)
    scatter(1, excLatencyList(r,1), 'MarkerEdgeColor', [color(r,1:3)]);
end
title('exclatency combo <20mx');
ylabel('sec');
xlabel('put.gran');
%ylim([0 .02]);
FormatFigure
hold off
saveas(gcf, 'granEXCLATboxCombo')
saveas(gcf, 'granEXCLATboxCombo', 'epsc')


figure
hold on
boxplot(MedianISI);
for v = 1:length(MedianISI)
    %if strcmp(SummaryStruct(n).IDtype, 'laser')
    %    marker = '*';
    %end
    %if strcmp(SummaryStruct(n).IDtype, 'hand')
    %    marker = 'o';
    %end
    scatter(1, MedianISI(v,1), 'MarkerEdgeColor', [color(v,1:3)]);
end
title('Median ISI combo<20ms');
ylabel('seconds');
xlabel('granular?');
%ylim([0 .2]);
FormatFigure
saveas(gcf, 'granISIboxCombo')
saveas(gcf, 'granISIboxCombo', 'epsc')



end