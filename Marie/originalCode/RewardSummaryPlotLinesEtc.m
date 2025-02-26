TrainBoo = 0;
SeparateFigures = 0;


if SeparateFigures == 0
figure
hold on
end
%JuiceAlone - unexpected reward
clear N
counter = 1;
for n = 1:length(SumSt)
    if SeparateFigures == 1
    figure
    hold on
    end
    %paired SS
if strcmp(SumSt(n).handID, 'SS_pause')
if SumSt(n).TrainBoo == TrainBoo
[N(counter,:), edges, L1] = OneUnitHistStructTimeLimLineINDEX(SumSt(n).JuiceAloneAdj, n, SumSt, -2, 3, .05, [0 inf], 4, 'b', NaN, 0);
N_SS_JuiceAloneIndex(counter,1) = n;
counter = counter +1;
end 
end
    %unpaired SS
%if strcmp(SumSt(n).handID, 'SS_noPair')
%if SumSt(n).TrainBoo == TrainBoo
%[N(counter,:), edges, L1] = OneUnitHistStructTimeLimLineINDEX(SumSt(n).JuiceAloneAdj, n, SumSt, -2, 3, .05, [0 inf], 4, 'b', NaN, 0);
%N_SS_JuiceAloneIndex(counter,1) = n;
%counter = counter +1;
%end 
end
%end
[N_SS_JuiceAlone, TF] = rmmissing(N);
N_SS_JuiceAloneIndex = N_SS_JuiceAloneIndex(~TF);


%all JuiceAfterTone- expected reward
clear N
counter = 1;
TrainBoo = 1;
SeparateFigures = 0;

    figure
    hold on

for n = 1:length(SumSt)
        %paired SS
if strcmp(SumSt(n).handID, 'CS_pause')
if SumSt(n).TrainBoo == TrainBoo
    if SeparateFigures == 1
    figure
    hold on
    end
[N(counter,:), edges, L1] = OneUnitHistStructTimeLimLineINDEX(SumSt(n).JuiceAfterToneAdj, n, SumSt, -1, 2, .05, [0 inf], 4, 'c', NaN, 0);
N_CS_JuiceAfterToneIndex(counter,1) = n;
counter = counter +1;
end 
end
    %unpaired SS
if strcmp(SumSt(n).handID, 'CS_noPair')
if SumSt(n).TrainBoo == TrainBoo
    if SeparateFigures == 1
    figure
    hold on
    end
[N(counter,:), edges, L1] = OneUnitHistStructTimeLimLineINDEX(SumSt(n).JuiceAfterToneAdj, n, SumSt, -1, 2, .05, [0 inf], 4, 'c', NaN, 0);
N_CS_JuiceAfterToneIndex(counter,1) = n;
counter = counter +1;
end 
end
end
[N_CS_JuiceAfterTone, TF] = rmmissing(N);
N_CS_JuiceAfterToneIndex = N_CS_JuiceAfterToneIndex(~TF);


%all ToneAlone- omission
clear N
counter = 1;
if SeparateFigures == 1
    figure
    hold on
end
for n = 1:length(SumSt)
        %paired SS
if strcmp(SumSt(n).handID, 'SS_pause')
if SumSt(n).TrainBoo == TrainBoo
[N(counter,:), edges, L1] = OneUnitHistStructTimeLimLineINDEX(SumSt(n).ToneAloneAdj, n, SumSt, -2, 3, .05, [0 inf], 4, 'g', NaN, 0);
N_SS_ToneAloneIndexIndex(counter,1) = n;
counter = counter +1;
end 
end
    %unpaired SS
if strcmp(SumSt(n).handID, 'SS_noPair')
if SumSt(n).TrainBoo == TrainBoo
[N(counter,:), edges, L1] = OneUnitHistStructTimeLimLineINDEX(SumSt(n).ToneAloneAdj, n, SumSt, -2, 3, .05, [0 inf], 4, 'g', NaN, 0);
N_SS_ToneAloneIndexIndex(counter,1) = n;
counter = counter +1;
end 
end
end
[N_SS_ToneAlone, TF] = rmmissing(N);
N_SS_ToneAloneIndexIndex(~TF);