%all ToneAlone- expected reward
clear N
counter = 1;
TrainBoo = 1;
SeparateFigures = 0;

    figure
    hold on

for n = 1:length(SumSt)
        %paired SS
if strcmp(SumSt(n).handID, 'MF')
if SumSt(n).TrainBoo == TrainBoo
    if SeparateFigures == 1
    figure
    hold on
    end
[N(counter,:), edges, L1] = OneUnitHistStructTimeLimLineINDEX(SumSt(n).ToneAloneAdj+.682, n, SumSt, -1, 2, .05, [0 inf], 4, 'g', NaN, 0);
N_MF_JuiceAfterToneIndex(counter,1) = n;
counter = counter +1;
end 
end
    %unpaired MF
%if strcmp(SumSt(n).handID, 'MF_noPair')
%if SumSt(n).TrainBoo == TrainBoo
%    if SeparateFigures == 1
%    figure
%    hold on
%    end
%[N(counter,:), edges, L1] = OneUnitHistStructTimeLimLineINDEX(SumSt(n).ToneAloneAdj+.682, n, SumSt, -1, 2, .05, [0 inf], 4, 'g', NaN, 0);
%N_MF_ToneAloneAdjIndex(counter,1) = n;
%counter = counter +1;
%end 
%end
end
[N_MF_ToneAlone, TF] = rmmissing(N);
%N_MF_ToneAloneAdjIndex = N_MF_ToneAloneAdjIndex(~TF);
