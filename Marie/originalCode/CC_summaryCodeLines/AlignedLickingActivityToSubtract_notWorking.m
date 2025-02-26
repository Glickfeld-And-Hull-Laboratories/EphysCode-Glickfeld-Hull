TrigMin = -.5;
TrigMax = 1.2;
bwidth = .01;
TrigNLength = (TrigMax - TrigMin)/ bwidth;
binvalue0_trig = abs(TrigMin/bwidth) + 1;
LickMin = -2.5;
LickMax = 3.5;
binvalue0_lick = abs(LickMin/bwidth) + 1;

 SummaryTemp = Summary_1694([Summary_1694.RecorNum] == k);
    ThisRecording = SummaryTemp(strcmp({SummaryTemp.c4_label}, 'PkC_ss'));


% for every neuron, find activity aligned to lick onset
clear addthis
clear N_lickKernel
for n = 1:length(ThisRecording)
    [addthis(1,:), edges] = OneUnitHistStructTimeLimLineINDEX([RecordingList(k).LickOnsetPred.RecordTime].', n, ThisRecording, LickMin, LickMax, bwidth, [0 inf], 4, 'k', NaN, 0, 0);
        [meanLine, stdevLine] = StDevLine(addthis, edges, -1);           % calc for z-score % -1 is time to stop using for mean/SD
        addthis = (addthis - meanLine)/stdevLine;                               % z-score
            addthis = abs(addthis);                                             % abs val
            addthis = smoothdata(addthis, 'sgolay', 11);
    ThisRecording(n,:).LickKernel.N_lick = addthis;
    ThisRecording(n,:).LickKernel.edges = edges;
    N_lickKernel(n,:) = addthis;
end
figure
hold on
shadedErrorBar2(edges(1:end-1), mean(N_lickKernel), std(N_lickKernel)/sqrt(size(N_lickKernel, 1)), 'lineProp', {C(1,:)});


% for every trial of the type you want, find shift to align lick onset neural activity according
% to reaction time

% For predict trials:
for k = 1:length(RecordingList)
    TrialStructTemp = RecordingList(k).TrialStructOutcomes(strcmp({RecordingList(k).TrialStructOutcomes.TrialOutcome}, 'p'));
    %SummaryTemp = Summary_1694([Summary_1694.RecorNum] == k);
    %SummaryTemp(strcmp({SummaryTemp.c4_label}, 'PkC_ss'));
%for every trial, find the latency and therefore the adjustments we will
%make to re-align the kernel for this particular recording
    for n = 1:length(TrialStructTemp)       
    %binLat = floor(TrialStructTemp(n).RTj/bwidth);
    binLat = floor(0/bwidth);          % set every latency to zero to check
    binsBeforeLick = binvalue0_trig + binLat;
    TrialStructTemp(n).binsRelignLickKernalToTrig = [(binvalue0_lick - binsBeforeLick) (binvalue0_lick - binsBeforeLick + TrigNLength)];
    end
%re-align and save the new kernel adjusted to latencies for this recording
clear addthis
clear N_lickKernelAdj
for q = 1:length(ThisRecording)
    for n = 1:length(TrialStructTemp)
    addthis(n,:) = ThisRecording(q,:).LickKernel.N_lick(TrialStructTemp(n).binsRelignLickKernalToTrig(1):TrialStructTemp(n).binsRelignLickKernalToTrig(2));
    %addthis(n,:) = ThisRecording(q,:).LickKernel.N_lick;
    end
    ThisRecording(q).LickKernelAlignedToTrigByTrial = mean(addthis);
    N_lickKernelAdj(q,:) = mean(addthis);
end
end




% visualize:
    figure
    hold on
    for q = 1:length(SummaryTemp)
        figure
    hold on
        plot([TrigMin:bwidth:TrigMax], ThisRecording(q).LickKernelAlignedToTrigByTrial)
         
        Rxmin= -.5; 
Rxmax = 1.2;
Lxmin = -.8;
Lxmax = .7;
Rbinwidth = .01;
Lbinwidth = .01;
Rxmin/Rbinwidth;
binvalue0 = 150;
colorRange = [-5 80]; 
C = colororder;


 clear N_trig
    clear addthis
for n = 1:length(ThisRecording)
    [addthis(1,:), edges] = OneUnitHistStructTimeLimLineINDEX([TrialStructTemp.ToneTime].', n, ThisRecording, TrigMin, TrigMax, bwidth, [0 inf], 4, 'k', NaN, 0, 0);
        [meanLine, stdevLine] = StDevLine(addthis, edges, 0);           % calc for z-score
        addthis = (addthis - meanLine)/stdevLine;                               % z-score
            addthis = abs(addthis);                                             % abs val
            addthis = smoothdata(addthis, 'sgolay', 11);
    N_trig(n,:) = addthis;
end
figure
shadedErrorBar2(edges(1:end-1), mean(N_trig), std(N_trig)/sqrt(size(N_trig, 1)), 'lineProp', {C(1,:)});
N = mean(N_trig) - mean(N_lickKernelAdj(1:end-1));
hold on
plot([TrigMin:bwidth:TrigMax-.01], N);
shadedErrorBar2(edges(1:end-1), mean(N_trig - N_lickKernelAdj), std(N_trig - N_lickKernelAdj)/sqrt(size(N_trig- N_lickKernelAdj, 1)), 'lineProp', {C(2,:)});
shadedErrorBar2([TrigMin:bwidth:TrigMax], mean(N_lickKernelAdj), std(N_lickKernelAdj)/sqrt(size(N_lickKernelAdj, 1)), 'lineProp', {C(2,:)});

       
    end
    
    


