addpath(genpath('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\marie\originalCode'));
addpath(genpath('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\marie\Kilosort\Kilosort2-noCAR'));
cd('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\marie\SummariesCellid\MLItypeSearch\FinalDataSet\QscFigs\FinalCellTypeDataSet\TypeB_8cells\MoreMLI1s\nonSyncDef\FixCCGissue\ForDocumentationCheck');
% 
% % this code runs slow and re-calculates ccgs
% load('RawWorkspace');
% % First precalculate MLI-PC and MLI-MLI ccgs. This is very slow, saved workspace after this step is 'Workspace_ccgs.mat'.
% [SumSt, MLI_PC] = MLI_PCmakerLines_TG_nullFR(SumSt, RecordingList, MEH_chanMap);        % these two scripts are located in originalCode
% [SumSt, MLI_MLI_tester] = MLI_MLImakerLines_TG_nullFR(SumSt, RecordingList, MEH_chanMap);
% %

% For speed, load this data with ccgs calculated from above code:
load('Workspace_ccgs.mat')
SumSt(809).MLIexpertID = 'layer';       % recreate a manual change I made examining expert layer info for this cell. It's already edited in the raw data.

SD = 4.0
% re-calculate synchrony for using the MLI_MLI_inh Ns - the sync binsize is too small and often dips at 0. Use mean of 1ms before and 1ms after 0.  record
% nearest MLI neighbor
for n = 1:length(SumSt)
    if ~isempty(SumSt(n).MLI_MLI_SyncSymmary)
        for k = 1:length(SumSt(n).MLI_MLI_InhSummary)
%                         N_syncCalc = SumSt(n).MLI_MLI_InhSummary(k).N;
%                         edges_syncCalc = SumSt(n).MLI_MLI_InhSummary(k).edges;
            N_syncCalc = SumSt(n).MLI_MLI_SyncSymmary(k).N;
            edges_syncCalc = SumSt(n).MLI_MLI_SyncSymmary(k).edges;
            index = [96:106];
            %index = find(edges_syncCalc == 0);
            Value0 = mean(N_syncCalc(index));
            [meanLine, stdevLine] = StDevLine(N_syncCalc, edges_syncCalc, -.005);
            if Value0 > (meanLine + SD*stdevLine)
                SumSt(n).MLI_MLI_SyncSymmary(k).syncBoo4SD = 1;
            else
                SumSt(n).MLI_MLI_SyncSymmary(k).syncBoo4SD = 0;
            end
        end
        if any([SumSt(n).MLI_MLI_SyncSymmary.syncBoo4SD] == 1)                      % synchronous with any MLI?
            SumSt(n).sync4SD = 1;
        else
            SumSt(n).sync4SD = 0;
        end
        SumSt(n).minMLIdist = min([SumSt(n).MLI_MLI_SyncSymmary.MLI_MLI_dist]);     % record distance of nearest MLI
        SumSt(n).NumMLIsASync = sum([SumSt(n).MLI_MLI_SyncSymmary.syncBoo4SD]);     % synchronous with how many MLI?
    end
end


% the list of MLIs I manually identified
MLIs_old = SumSt(strcmp({SumSt.CellType}, 'MLI'));

clear MLIs
    counter = 1;
    for n = 1:length(MLIs_old)
        if strcmp(MLIs_old(n).MLIexpertID, 'layer')
            if MLIs_old(n).FR > 4
                MLIs(counter) = MLIs_old(n);
                counter = counter + 1;
            end
        end
        if strcmp(MLIs_old(n).MLIexpertID, 'ccg')
            if MLIs_old(n).MLI_PC_4SDinh == 1
                if MLIs_old(n).FR > 4
                    MLIs(counter) = MLIs_old(n);
                    counter = counter + 1;
                end
            end
        end
    end

    clear MLIsA_put
counter = 1;
for n = 1:length(MLIs)
    if MLIs(n).MLI_PC_4SDinh
        MLIsA_put(counter) = MLIs(n);
    counter = counter + 1;
    end
end

clear MLIsA
counter = 1;
for n = 1:length(MLIsA_put)
    if MLIsA_put(n).sync4SD == 1
    MLIsA(counter) = MLIsA_put(n);
    counter = counter + 1;
    end
end




clear MLIsB_put
%find field for noPCinh
for n = 1:length(MLIs)
    if MLIs(n).MLI_PC_4SDinh == 0
        if sum([MLIs(n).MLI_PC_Summary.MLI_PC_dist] < 125) >= 3
             MLIs(n).noPCinh = 1;
        end
    end
end

clear MLIsB_put
counter = 1;
for n = 1:length(MLIs)
    if MLIs(n).noPCinh == 1
        MLIsB_put(counter) = MLIs(n);
    counter = counter + 1;
    elseif MLIs(n).MLI_MLI_4SDinh == 1
        if MLIs(n).MLI_PC_4SDinh == 0
             MLIsB_put(counter) = MLIs(n);
    counter = counter + 1;
        end
    end
end


clear MLIsB
counter = 1;
for n = 1:length(MLIsB_put)
    if isempty([MLIsB_put(n).sync4SD])
        MLIsB(counter) = MLIsB_put(n);
        counter = counter + 1;
    elseif MLIsB_put(n).sync4SD == 0
        MLIsB(counter) = MLIsB_put(n);
        counter = counter + 1;
    end
end

% label typed MLIs in various placesfor n = 1:length(MLIs)
% place MLIA & MLIB labels in MLIs
for n = 1:length(MLIs)
MLIs(n).Type = [];
end
for m = 1:length(MLIsA)
    for k = 1:length(MLIs)
        if MLIs(k).unitID == MLIsA(m).unitID
            if MLIs(k).RecorNum == MLIsA(m).RecorNum
    MLIs(k).Type = 'A';
            end
        end
    end
end
for m = 1:length(MLIsB)
    for k = 1:length(MLIs)
        if MLIs(k).unitID == MLIsB(m).unitID
            if MLIs(k).RecorNum == MLIsB(m).RecorNum
    MLIs(k).Type = 'B';
            end
        end
    end
end

%place labels MLIsB & MLIsA in MLIsA/B.MLI_MLI_InhSummary
reporter1 = 0;
reporter2 = 0;
for n = 1:length(MLIsB)
for k = 1:length(MLIsB(n).MLI_MLI_InhSummary)
searchIndex = MLIsB(n).MLI_MLI_InhSummary(k).indexFollow;
MLIsB(n).MLI_MLI_InhSummary(k).Type = [];
for m = 1:length(MLIsA)
    if ~isempty([MLIsA(m).MLI_MLI_InhSummary])
    if searchIndex == [MLIsA(m).MLI_MLI_InhSummary(1).indexDrive]
    MLIsB(n).MLI_MLI_InhSummary(k).Type = 'A';
    reporter1 = reporter1+1;
    end
    end
end
for m = 1:length(MLIsB)
     if ~isempty([MLIsB(m).MLI_MLI_InhSummary])
if searchIndex == MLIsB(m).MLI_MLI_InhSummary(1).indexDrive
MLIsB(n).MLI_MLI_InhSummary(k).Type = 'B';
reporter2 = reporter2 +1;
n
m
end
     end
end
end
end
reporter1 = 0;
reporter2 = 0;
for n = 1:length(MLIsA)
for k = 1:length(MLIsA(n).MLI_MLI_InhSummary)
searchIndex = MLIsA(n).MLI_MLI_InhSummary(k).indexFollow;
MLIsA(n).MLI_MLI_InhSummary(k).Type = [];
for m = 1:length(MLIsA)
         if ~isempty([MLIsA(m).MLI_MLI_InhSummary])
if searchIndex == [MLIsA(m).MLI_MLI_InhSummary(1).indexDrive]
MLIsA(n).MLI_MLI_InhSummary(k).Type = 'A';
reporter1 = reporter1+1;
end
end
end
for m = 1:length(MLIsB)
     if ~isempty([MLIsB(m).MLI_MLI_InhSummary])
if searchIndex == MLIsB(m).MLI_MLI_InhSummary(1).indexDrive
MLIsA(n).MLI_MLI_InhSummary(k).Type = 'B';
reporter2 = reporter2 +1;
end
     end
end
end
end

%place labels MLIsB & MLIsA in MLIsA/B_put.MLI_MLI_InhSummary
reporter1 = 0;
reporter2 = 0;
for n = 1:length(MLIsB_put)
for k = 1:length(MLIsB_put(n).MLI_MLI_InhSummary)
searchIndex = MLIsB_put(n).MLI_MLI_InhSummary(k).indexFollow;
MLIsB_put(n).MLI_MLI_InhSummary(k).Type = [];
for m = 1:length(MLIsA)
    if ~isempty([MLIsA(m).MLI_MLI_InhSummary])
    if searchIndex == [MLIsA(m).MLI_MLI_InhSummary(1).indexDrive]
    MLIsB_put(n).MLI_MLI_InhSummary(k).Type = 'A';
    reporter1 = reporter1+1;
    end
    end
end
for m = 1:length(MLIsB)
     if ~isempty([MLIsB(m).MLI_MLI_InhSummary])
if searchIndex == MLIsB(m).MLI_MLI_InhSummary(1).indexDrive
MLIsB_put(n).MLI_MLI_InhSummary(k).Type = 'B';
reporter2 = reporter2 +1;
n
m
end
     end
end
end
end
reporter1 = 0;
reporter2 = 0;
for n = 1:length(MLIsA_put)
for k = 1:length(MLIsA_put(n).MLI_MLI_InhSummary)
searchIndex = MLIsA_put(n).MLI_MLI_InhSummary(k).indexFollow;
MLIsA_put(n).MLI_MLI_InhSummary(k).Type = [];
for m = 1:length(MLIsA)
         if ~isempty([MLIsA(m).MLI_MLI_InhSummary])
if searchIndex == [MLIsA(m).MLI_MLI_InhSummary(1).indexDrive]
MLIsA_put(n).MLI_MLI_InhSummary(k).Type = 'A';
reporter1 = reporter1+1;
end
end
end
for m = 1:length(MLIsB)
     if ~isempty([MLIsB(m).MLI_MLI_InhSummary])
if searchIndex == MLIsB(m).MLI_MLI_InhSummary(1).indexDrive
MLIsA_put(n).MLI_MLI_InhSummary(k).Type = 'B';
reporter2 = reporter2 +1;
end
     end
end
end
end



%place labels MLIsB_put & MLIsA_put in MLIsA/B_put.MLI_MLI_InhSummary
reporter1 = 0;
reporter2 = 0;
for n = 1:length(MLIsB_put)
for k = 1:length(MLIsB_put(n).MLI_MLI_InhSummary)
searchIndex = MLIsB_put(n).MLI_MLI_InhSummary(k).indexFollow;
MLIsB_put(n).MLI_MLI_InhSummary(k).Type_put = [];
for m = 1:length(MLIsA_put)
    if ~isempty([MLIsA_put(m).MLI_MLI_InhSummary])
    if searchIndex == [MLIsA_put(m).MLI_MLI_InhSummary(1).indexDrive]
    MLIsB_put(n).MLI_MLI_InhSummary(k).Type_put = 'A';
    reporter1 = reporter1+1;
    end
    end
end
for m = 1:length(MLIsB)
     if ~isempty([MLIsB(m).MLI_MLI_InhSummary])
if searchIndex == MLIsB(m).MLI_MLI_InhSummary(1).indexDrive
MLIsB_put(n).MLI_MLI_InhSummary(k).Type_put = 'B';
reporter2 = reporter2 +1;
n
m
end
     end
end
end
end
reporter1 = 0;
reporter2 = 0;
for n = 1:length(MLIsA_put)
for k = 1:length(MLIsA_put(n).MLI_MLI_InhSummary)
searchIndex = MLIsA_put(n).MLI_MLI_InhSummary(k).indexFollow;
MLIsA_put(n).MLI_MLI_InhSummary(k).Type_put = [];
for m = 1:length(MLIsA_put)
         if ~isempty([MLIsA_put(m).MLI_MLI_InhSummary])
if searchIndex == [MLIsA_put(m).MLI_MLI_InhSummary(1).indexDrive]
MLIsA_put(n).MLI_MLI_InhSummary(k).Type_put = 'A';
reporter1 = reporter1+1;
end
end
end
for m = 1:length(MLIsB_put)
     if ~isempty([MLIsB_put(m).MLI_MLI_InhSummary])
if searchIndex == MLIsB_put(m).MLI_MLI_InhSummary(1).indexDrive
MLIsA_put(n).MLI_MLI_InhSummary(k).Type_put = 'B';
reporter2 = reporter2 +1;
end
     end
end
end
end