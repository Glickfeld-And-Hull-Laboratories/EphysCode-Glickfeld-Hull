% Locations/Code for Examples:

% Panel C:
figure
hold on
for n = 12:length(MLIsA(59).MLI_PC_Summary)
    if MLIsA(59).MLI_PC_Summary(n).inhBoo4SD == 1
        plot(MLIsA(59).MLI_PC_Summary(n).edges, MLIsA(59).MLI_PC_Summary(n).N)
    end
end

% Panel D:
% There is a mistake in the legend, the schematic is correct- it is 1 MLI synchronous with 5 other MLIs (6 synchronous total)
figure
hold on
for n = 1:length(MLIsA(40).MLI_MLI_SyncSymmary)
    if MLIsA(40).MLI_MLI_SyncSymmary(n).syncBoo4SD == 1
        plot(MLIsA(40).MLI_MLI_SyncSymmary(n).edges, MLIsA(40).MLI_MLI_SyncSymmary(n).N)
    end
end

% Panel E:
figure
hold on
for n = 1:length(MLIsB(7).MLI_MLI_InhSummary)
    if MLIsB(7).MLI_MLI_InhSummary(n).inhBoo4SD == 1    
       plot(MLIsB(7).MLI_MLI_InhSummary(n).edges, MLIsB(7).MLI_MLI_InhSummary(n).N)
    end
end


% Sup. Panel a:
% located at \\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\marie\Histology and Surgery Pics\1677

% Sup. Panel b: 
figure
[N, edges, Values1] = XcorrFastINDEX_TG(SumSt, -.05, .05, .001, 429, 455, RecordingList(10).RunningData.qsc_TGA, RecordingList(10).RunningData.qsc_TGB,0, inf, 'k', 1, 4, 0);

% Sup. Panel c & d:
% from recording \\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\marie\NeuropixelsAnalysis\AuditoryDay1\1677\1677_230405_g1\BW
% RecordingList(7)



