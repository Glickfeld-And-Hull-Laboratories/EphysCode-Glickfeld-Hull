 
range= [-1 2]; 
bwidth = .01;
binvalue0 = 40;

figure
hold on
    clear N
    clear addthis
for n = 1:length(ThisRecording)
    [addthis(1,:), edges] =  LickHist(RecordingList(n).LickOnsets, RecordingList(n).AllLicks, range, bwidth, 'k', 0);
        %[meanLine, stdevLine] = StDevLine(addthis, edges, -.7);           % calc for z-score
        %addthis = (addthis - meanLine)/stdevLine;                               % z-score
            %addthis = abs(addthis);                                             % abs val
            %addthis = smoothdata(addthis, 'sgolay', 11);
    N(n,:) = addthis;
end
shadedErrorBar2(edges(1:end-1), mean(N), std(N)/sqrt(size(N, 1)), 'lineProp', 'k');


clear N
    clear addthis
for n = 1:length(ThisRecording)
    [addthis(1,:), edges] =  LickHist(RecordingList(n).EpochOnsets, RecordingList(n).AllLicks, range, bwidth, 'k', 0);
        %[meanLine, stdevLine] = StDevLine(addthis, edges, -.7);           % calc for z-score
        %addthis = (addthis - meanLine)/stdevLine;                               % z-score
            %addthis = abs(addthis);                                             % abs val
            %addthis = smoothdata(addthis, 'sgolay', 11);
    N(n,:) = addthis;
end
shadedErrorBar2(edges(1:end-1), mean(N), std(N)/sqrt(size(N, 1)), 'lineProp', 'r');

clear N
    clear addthis
for n = 1:length(ThisRecording)
    [addthis(1,:), edges] =  LickHist(RecordingList(n).RewardLickOnset, RecordingList(n).AllLicks, range, bwidth, 'k', 0);
        %[meanLine, stdevLine] = StDevLine(addthis, edges, -.7);           % calc for z-score
        %addthis = (addthis - meanLine)/stdevLine;                               % z-score
            %addthis = abs(addthis);                                             % abs val
            %addthis = smoothdata(addthis, 'sgolay', 11);
    N(n,:) = addthis;
end
shadedErrorBar2(edges(1:end-1), mean(N), std(N)/sqrt(size(N, 1)), 'lineProp', 'b');

clear N
    clear addthis
for n = 1:length(ThisRecording)
    [addthis(1,:), edges] =  LickHist(RecordingList(n).RewardEpochOnset, RecordingList(n).AllLicks, range, bwidth, 'k', 0);
        %[meanLine, stdevLine] = StDevLine(addthis, edges, -.7);           % calc for z-score
        %addthis = (addthis - meanLine)/stdevLine;                               % z-score
            %addthis = abs(addthis);                                             % abs val
            %addthis = smoothdata(addthis, 'sgolay', 11);
    N(n,:) = addthis;
end
shadedErrorBar2(edges(1:end-1), mean(N), std(N)/sqrt(size(N, 1)), 'lineProp', 'g');


legend({'Lick Onsets'; 'epochOnsets'; 'RewardLickOnset'; 'RewardEpochOnset'}, 'Location', 'northeast');
legend('boxoff')

FigureWrap(NaN, 'lick_prob_by_detect_type', 'time from lick type detection', 'prob of lick detection', NaN, NaN, NaN, NaN);
