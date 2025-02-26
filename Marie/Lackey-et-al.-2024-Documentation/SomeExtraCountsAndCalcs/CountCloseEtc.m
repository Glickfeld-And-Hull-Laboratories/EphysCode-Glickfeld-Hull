%MLI_PC

for n = 1:length(MLIsA_put)
    MLIsA_put(n).ClosePCnum = sum([MLIsA_put(n).MLI_PC_Summary.MLI_PC_dist] <=125);
    MLIsA_put(n).InhPCnum = sum([MLIsA_put(n).MLI_PC_Summary.inhBoo4SD] == 1);
    if MLIsA_put(n).ClosePCnum > 0
    MLIsA_put(n).meanPCconn = nanmean([MLIsA_put(n).MLI_PC_Summary.Int_0_5]);
    end
end
mean([MLIsA_put.ClosePCnum])
mean([MLIsA_put.InhPCnum])

%MLI_MLI_Inh
for n = 1:length(MLIsA_put)
    if ~isempty(MLIsA_put(n).MLI_MLI_InhSummary)
    MLIsA_put(n).CloseMLInum = sum([MLIsA_put(n).MLI_MLI_InhSummary.MLI_MLI_dist] <= 125);
    MLIsA_put(n).InhMLInum = sum([MLIsA_put(n).MLI_MLI_InhSummary.inhBoo4SD] == 1);
    end
end
% mean([MLIsA_put.CloseMLInum])
% mean([MLIsA_put.InhMLInum])

% MLIA_MLI_Sync
for n = 1:length(MLIsA_put)
    if ~isempty(MLIsA_put(n).MLI_MLI_SyncSymmary)
    MLIsA_put(n).CloseMLInum = sum([MLIsA_put(n).MLI_MLI_SyncSymmary.MLI_MLI_dist] <= 125);
    MLIsA_put(n).InhMLInum = sum([MLIsA_put(n).MLI_MLI_SyncSymmary.syncBoo4SD] == 1);
    end
end
mean([MLIsA_put.CloseMLInum])
mean([MLIsA_put.InhMLInum])

%MLI_MLI_Inh
for n = 1:length(MLIsB_put)
    if ~isempty(MLIsB_put(n).MLI_MLI_InhSummary)
    MLIsB_put(n).CloseMLInum = sum([MLIsB_put(n).MLI_MLI_InhSummary.MLI_MLI_dist] <= 125);
    MLIsB_put(n).InhMLInum = sum([MLIsB_put(n).MLI_MLI_InhSummary.inhBoo4SD] == 1);
    end
end
sum([MLIsB_put.CloseMLInum])
sum([MLIsB_put.InhMLInum])
