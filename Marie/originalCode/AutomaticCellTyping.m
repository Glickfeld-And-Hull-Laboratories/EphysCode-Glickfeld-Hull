binwidth = .001;
SD = 4;

%use data from phylum or code below to fine SS_CS
close all
for k = 1:length([GoodUnitStructSorted.unitID])
    if GoodUnitStructSorted(k).FR > 20 & ~strcmp({GoodUnitStructSorted(k).c4_label}, 'MF')
unit = GoodUnitStructSorted(k).unitID;
index = find([GoodUnitStructSorted.unitID] == unit);
m = index;
     
for n = 1:length(GoodUnitStructSorted)
    if abs(GoodUnitStructSorted(n).depth - GoodUnitStructSorted(index).depth) < 1000
        if strcmp(GoodUnitStructSorted(n).layer, 'GrC_layer')
        else
        if GoodUnitStructSorted(n).FR<4
        [N, edges] = XcorrFastINDEX_TG(GoodUnitStructSorted, -.05, .05, .001, n, m, NaN, NaN, 0, inf, 'k', 0, 4, 0);        
        %xCorrStructNewLimitsLine(AllUnitStruct, -.02, .02, .001, GoodUnitStructSorted(n).unitID, unit, 0, inf, 'k', 3, 1);
        if min(N) < 10
            figure
            plot(edges, N);
           title([num2str(GoodUnitStructSorted(n).unitID) ' & ' num2str(GoodUnitStructSorted(m).unitID)])
        end
        end
        %end
    end
    end
end
    end
end

%AND/OR

close all
%SS_pairs_from_phyllum = phyllum guess of SS_CS
for n = 1:length(SS_pairs_from_phyllum)
index = find([GoodUnitStructSorted.unitID] == SS_pairs_from_phyllum(n,1))
if ~isempty(index)
if ~isempty(find([GoodUnitStructSorted.unitID] == SS_pairs_from_phyllum(n,2)))
xCorrStructNewLimits(AllUnitStruct, -.02, .02, .001, SS_pairs_from_phyllum(n,2), SS_pairs_from_phyllum(n,1), 0, 1000, 'k');
end
end
end

%double check
for n = 1:length(SS_CS)
    figure
    xCorrStructNewLimits(AllUnitStruct, -.02, .02, .001, SS_CS(n).CS, SS_CS(n).SS, 0, inf, 'k');
end


for n = 1:length(SS_CS)
    GoodUnitStructSorted([GoodUnitStructSorted.unitID] == SS_CS(n).CS).CellType1 = 'CS_paired';
    GoodUnitStructSorted([GoodUnitStructSorted.unitID] == SS_CS(n).CS).PCpair = SS_CS(n).SS;
    GoodUnitStructSorted([GoodUnitStructSorted.unitID] == SS_CS(n).SS).CellType1 = 'SS_paired';
    GoodUnitStructSorted([GoodUnitStructSorted.unitID] == SS_CS(n).SS).PCpair = SS_CS(n).CS;
end

for n = 1:length(GoodUnitStructSorted)
    if strcmp({GoodUnitStructSorted(n).layer}, 'ML')
        if GoodUnitStructSorted(n).PC_dist >= 40
            if GoodUnitStructSorted(n).FR > 4
            GoodUnitStructSorted(n).CellType1 = 'MLI';
                end
            end
        end
    end


binwidth = .001;
SD = 4;
for n = 1:length(GoodUnitStructSorted)
    if ~strcmp({GoodUnitStructSorted(n).layer}, 'GrC_layer') & ~strcmp({GoodUnitStructSorted(n).layer}, 'PC_GrC_interface')
        if GoodUnitStructSorted(n).FR > 4
            GoodUnitStructSorted(n).inhBoo4SD = [];
            for k = 1:length([SS_CS.SS])
             GoodUnitStructSorted(n).CellX_PC(k).inhLat = [];
             GoodUnitStructSorted(n).CellX_PC(k).inhEnd = [];
             GoodUnitStructSorted(n).CellX_PC(k).inhBoo4SD = [];
%              GoodUnitStructSorted(n).CellType2 = [];
                SSindex = find([GoodUnitStructSorted.unitID] == SS_CS(k).SS);
                [GoodUnitStructSorted(n).CellX_PC(k).N, GoodUnitStructSorted(n).CellX_PC(k).edges] = XcorrFastINDEX(GoodUnitStructSorted, -.02, .02, binwidth, n, SSindex, 0, 1200, 'k', 0, SD, 0);
                GoodUnitStructSorted(n).CellX_PC(k).MLIunitID = GoodUnitStructSorted(n).unitID;
                GoodUnitStructSorted(n).CellX_PC(k).SSunitID = SS_CS(k).SS;
                %GoodUnitStructSorted(n).CellX_PC(k).CellX_PC_dist = Cell2CellDistINDEX(GoodUnitStructSorted, n, SSindex, MEH_chanMap);
                
                [meanLine, stdevLine] = StDevLine(GoodUnitStructSorted(n).CellX_PC(k).N, GoodUnitStructSorted(n).CellX_PC(k).edges, 0);
                crossings = GoodUnitStructSorted(n).CellX_PC(k).edges(GoodUnitStructSorted(n).CellX_PC(k).N<(meanLine - SD*stdevLine));
                if ~isempty(crossings)
                    GoodUnitStructSorted(n).CellX_PC(k).inhLat = crossings(1);
                    GoodUnitStructSorted(n).CellX_PC(k).inhEnd = crossings(end);
                    if GoodUnitStructSorted(n).CellX_PC(k).inhLat ~= GoodUnitStructSorted(n).CellX_PC(k).inhEnd
                    if crossings(1) < .005
                        crossings2 = GoodUnitStructSorted(n).CellX_PC(k).edges(GoodUnitStructSorted(n).CellX_PC(k).N>(meanLine + SD*stdevLine));
                        if ~isempty(crossings2) %check for PC-PC connection
                            if crossings2(1) < .002
                            else
                        GoodUnitStructSorted(n).CellX_PC(k).inhBoo4SD = 1;
                        GoodUnitStructSorted(n).CellType2 = 'MLIA';
                        GoodUnitStructSorted(n).inhBoo4SD = 1;
                            end
                          GoodUnitStructSorted(n).CellX_PC(k).excLat = crossings2(1);
                        else
                        GoodUnitStructSorted(n).CellX_PC(k).inhBoo4SD = 1;
                        GoodUnitStructSorted(n).CellType2 = 'MLIA';
                        GoodUnitStructSorted(n).inhBoo4SD = 1; 
                        end
                    end
                    end
                end  
            end
        end
    end
end
%visualize
for n = 1:length(GoodUnitStructSorted)
if GoodUnitStructSorted(n).inhBoo4SD ==1
for k = 1:length([GoodUnitStructSorted(n).CellX_PC])
if GoodUnitStructSorted(n).CellX_PC(k).inhBoo4SD
figure
plot(GoodUnitStructSorted(n).CellX_PC(k).edges, GoodUnitStructSorted(n).CellX_PC(k).N)
title([num2str(n) ' ' num2str(k)]);
end
end
end
end

%I think this is fixed now
% for n = 1:length(SS_CS) %SS labels got deleted as putative MLIs
%     GoodUnitStructSorted([GoodUnitStructSorted.unitID] == SS_CS(n).CS).CellType1 = 'CS_paired';
%     GoodUnitStructSorted([GoodUnitStructSorted.unitID] == SS_CS(n).SS).CellType1 = 'SS_paired';
% end


%find putative PCs through PC layer & FR > 100 or synchrony.
binwidth = .001;
SD = 4;
SS = [];
counter = 1;
for n = 1:length(GoodUnitStructSorted)
    if ~strcmp({GoodUnitStructSorted(n).layer}, 'GrC_layer') & ~strcmp({GoodUnitStructSorted(n).layer}, 'PC_GrC_interface')
        if ~strcmp({GoodUnitStructSorted(n).CellType1}, 'SS_paired')
            if strcmp({GoodUnitStructSorted(n).layer}, 'PC_layer')
                if GoodUnitStructSorted(n).FR > 100
                    GoodUnitStructSorted(n).CellType2 = 'SS_unpaired';
                    SS(counter, 1) = GoodUnitStructSorted(n).unitID;
                    counter = counter + 1;
                end
            end
        end
    end
end
SS = [SS; [SS_CS.SS].'];
for n = 1:length(GoodUnitStructSorted)
    if ~strcmp({GoodUnitStructSorted(n).layer}, 'GrC_layer') & ~strcmp({GoodUnitStructSorted(n).layer}, 'PC_GrC_interface')
        if GoodUnitStructSorted(n).FR > 20
            GoodUnitStructSorted(n).inhBoo4SD = [];
            for k = 1:length([SS_CS.SS])
                [meanLine, stdevLine] = StDevLine(GoodUnitStructSorted(n).CellX_PC(k).N, GoodUnitStructSorted(n).CellX_PC(k).edges, 0);
                crossings2 = GoodUnitStructSorted(n).CellX_PC(k).edges(GoodUnitStructSorted(n).CellX_PC(k).N>(meanLine + SD*stdevLine));
                if GoodUnitStructSorted(n).CellX_PC(k).N(GoodUnitStructSorted(n).CellX_PC(k).edges == 0) >(meanLine + SD*stdevLine)
                    GoodUnitStructSorted(n).CellX_PC(k).excCross0_8SD = 1;
                    GoodUnitStructSorted(n).PC_syncBoo = 1;
                    if ~strcmp({GoodUnitStructSorted(n).CellType1}, 'SS_paired')
                        GoodUnitStructSorted(n).CellType2 = 'SS_unpaired';
                    end
                end
            end
            
        end
    end
end

%list of putSS
counter = 1;
for n = 1:length(GoodUnitStructSorted)
    if strcmp({GoodUnitStructSorted(n).CellType2}, 'SS_unpaired')
        putSS(counter) = GoodUnitStructSorted(n).unitID;
        counter = counter + 1;
    end
end
SS = [SS; putSS.'];

%find MLIs that inhibit (only) putative SS
binwidth = .001;
SD = 4;
for n = 1:length(GoodUnitStructSorted)
    if ~strcmp({GoodUnitStructSorted(n).layer}, 'GrC_layer') & ~strcmp({GoodUnitStructSorted(n).layer}, 'PC_GrC_interface')
        if GoodUnitStructSorted(n).FR > 4
            GoodUnitStructSorted(n).inhBoo4SD = [];
            GoodUnitStructSorted(n).CellType3 = [];
            for k = 1:length(putSS)
             GoodUnitStructSorted(n).CellX_pPC(k).inhLat = [];
             GoodUnitStructSorted(n).CellX_pPC(k).inhEnd = [];
             GoodUnitStructSorted(n).CellX_pPC(k).inhBoo4SD = [];
%              GoodUnitStructSorted(n).CellType2 = [];
                SSindex = find([GoodUnitStructSorted.unitID] == putSS(k));
                [GoodUnitStructSorted(n).CellX_pPC(k).N, GoodUnitStructSorted(n).CellX_pPC(k).edges] = XcorrFastINDEX(GoodUnitStructSorted, -.02, .02, binwidth, n, SSindex, 0, 1200, 'k', 0, SD, 0);
                GoodUnitStructSorted(n).CellX_pPC(k).MLIunitID = GoodUnitStructSorted(n).unitID;
                GoodUnitStructSorted(n).CellX_pPC(k).SSunitID = putSS(k);
                %GoodUnitStructSorted(n).CellX_pPC(k).CellX_pPC_dist = Cell2CellDistINDEX(GoodUnitStructSorted, n, SSindex, MEH_chanMap);
                [meanLine, stdevLine] = StDevLine(GoodUnitStructSorted(n).CellX_pPC(k).N, GoodUnitStructSorted(n).CellX_pPC(k).edges, 0);
                crossings = GoodUnitStructSorted(n).CellX_pPC(k).edges(GoodUnitStructSorted(n).CellX_pPC(k).N<(meanLine - SD*stdevLine));
                if ~isempty(crossings)
                    GoodUnitStructSorted(n).CellX_pPC(k).inhLat = crossings(1);
                    GoodUnitStructSorted(n).CellX_pPC(k).inhEnd = crossings(end);
                    if GoodUnitStructSorted(n).CellX_pPC(k).inhLat ~= GoodUnitStructSorted(n).CellX_pPC(k).inhEnd
                    if crossings(1) < .005
                        crossings2 = GoodUnitStructSorted(n).CellX_pPC(k).edges(GoodUnitStructSorted(n).CellX_pPC(k).N>(meanLine + SD*stdevLine));
                        if ~isempty(crossings2) %check for PC-PC connection
                            if crossings2(1) < .002
                            else
                        GoodUnitStructSorted(n).CellX_pPC(k).inhBoo4SD = 1;
                        GoodUnitStructSorted(n).CellType3 = 'MLIA';
                        GoodUnitStructSorted(n).inhBoo4SD_2 = 1;
                            end
                          GoodUnitStructSorted(n).CellX_pPC(k).excLat = crossings2(1);
                        else
                        GoodUnitStructSorted(n).CellX_pPC(k).inhBoo4SD = 1;
                        GoodUnitStructSorted(n).CellType3 = 'MLIA';
                        GoodUnitStructSorted(n).inhBoo4SD_2 = 1; 
                        end
                    end
                    end
                end  
            end
        end
    end
end
close all

%not sure what is happening here this code doesn't run
for n = 1:length(GoodUnitStructSorted)
if GoodUnitStructSorted(n).inhBoo4SD_2 ==1
for k = 1:length([GoodUnitStructSorted(n).CellX_pPC])
if GoodUnitStructSorted(n).CellX_pPC(k).inhBoo4SD == 1
figure
plot(GoodUnitStructSorted(n).CellX_pPC(k).edges, GoodUnitStructSorted(n).CellX_pPC(k).N)
title([num2str(n) ' ' num2str(k)]);
end
end
end
end

%list of put MLIAs
counter = 1;
for n = 1:length(GoodUnitStructSorted)
    if strcmp({GoodUnitStructSorted(n).CellType3}, 'MLIA')
        MLIA(counter) = GoodUnitStructSorted(n).unitID;
        counter = counter + 1;
    end
end

%find cells that inhibit MLIAs
binwidth = .001;
SD = 4;
for n = 1:length(GoodUnitStructSorted)
    if ~strcmp({GoodUnitStructSorted(n).layer}, 'GrC_layer') & ~strcmp({GoodUnitStructSorted(n).layer}, 'PC_GrC_interface')
        if GoodUnitStructSorted(n).FR > 4
            for k = 1:length(MLIA)
             GoodUnitStructSorted(n).CellX_MLIA(k).inhLat = [];
             GoodUnitStructSorted(n).CellX_MLIA(k).inhEnd = [];
             GoodUnitStructSorted(n).CellX_MLIA(k).inhBoo4SD = [];
%              GoodUnitStructSorted(n).CellType2 = [];
                MLIAindex = find([GoodUnitStructSorted.unitID] == MLIA(k));
                [GoodUnitStructSorted(n).CellX_MLIA(k).N, GoodUnitStructSorted(n).CellX_MLIA(k).edges] = XcorrFastINDEX(GoodUnitStructSorted, -.02, .02, binwidth, n, MLIAindex, 0, 1200, 'k', 0, SD, 0);
                GoodUnitStructSorted(n).CellX_MLIA(k).XunitID = GoodUnitStructSorted(n).unitID;
                GoodUnitStructSorted(n).CellX_MLIA(k).MLIunitID = MLIA(k);
                %GoodUnitStructSorted(n).CellX_MLIA(k).CellX_MLIA_dist = Cell2CellDistINDEX(GoodUnitStructSorted, n, MLIAindex, MEH_chanMap);
                [meanLine, stdevLine] = StDevLine(GoodUnitStructSorted(n).CellX_MLIA(k).N, GoodUnitStructSorted(n).CellX_MLIA(k).edges, 0);
                crossings = GoodUnitStructSorted(n).CellX_MLIA(k).edges(GoodUnitStructSorted(n).CellX_MLIA(k).N<(meanLine - SD*stdevLine));
                if ~isempty(crossings)
                    GoodUnitStructSorted(n).CellX_MLIA(k).inhLat = crossings(1);
                    GoodUnitStructSorted(n).CellX_MLIA(k).inhEnd = crossings(end);
                    if GoodUnitStructSorted(n).CellX_MLIA(k).inhLat ~= GoodUnitStructSorted(n).CellX_MLIA(k).inhEnd
                    if crossings(1) < .005 & crossings(1) > 0
                        GoodUnitStructSorted(n).CellX_MLIA(k).inhBoo4SD = 1;
                        GoodUnitStructSorted(n).CellType4 = 'MLIB';
                        GoodUnitStructSorted(n).inhBoo4SD_MLIB = 1;
                    end
                    end
                end  
            end
        end
    end
end

counter = 1;
for n = 1:length(GoodUnitStructSorted)
if strcmp({GoodUnitStructSorted(n).CellType1}, 'MLI')
MLI(counter,1) = GoodUnitStructSorted(n).unitID;
counter = counter + 1;
end
end
[C, ia, ic] = unique([MLI]);
MLI = MLI(ia);

%find cells that inhibit any MLIs
binwidth = .001;
SD = 4;
for n = 1:length(GoodUnitStructSorted)
    if ~strcmp({GoodUnitStructSorted(n).layer}, 'GrC_layer') & ~strcmp({GoodUnitStructSorted(n).layer}, 'PC_GrC_interface')
        if GoodUnitStructSorted(n).FR > 4
            for k = 1:length(MLI)
             GoodUnitStructSorted(n).CellX_MLI(k).inhLat = [];
             GoodUnitStructSorted(n).CellX_MLI(k).inhEnd = [];
             GoodUnitStructSorted(n).CellX_MLI(k).inhBoo4SD = [];
%              GoodUnitStructSorted(n).CellType2 = [];
                MLIindex = find([GoodUnitStructSorted.unitID] == MLI(k));
                [GoodUnitStructSorted(n).CellX_MLI(k).N, GoodUnitStructSorted(n).CellX_MLI(k).edges] = XcorrFastINDEX(GoodUnitStructSorted, -.02, .02, binwidth, n, MLIindex, 0, 1200, 'k', 0, SD, 0);
                GoodUnitStructSorted(n).CellX_MLI(k).XunitID = GoodUnitStructSorted(n).unitID;
                GoodUnitStructSorted(n).CellX_MLI(k).MLIunitID = MLI(k);
                %GoodUnitStructSorted(n).CellX_MLI(k).CellX_MLI_dist = Cell2CellDistINDEX(GoodUnitStructSorted, n, MLIindex, MEH_chanMap);
                [meanLine, stdevLine] = StDevLine(GoodUnitStructSorted(n).CellX_MLI(k).N, GoodUnitStructSorted(n).CellX_MLI(k).edges, 0);
                crossings = GoodUnitStructSorted(n).CellX_MLI(k).edges(GoodUnitStructSorted(n).CellX_MLI(k).N<(meanLine - SD*stdevLine));
                if ~isempty(crossings)
                    GoodUnitStructSorted(n).CellX_MLI(k).inhLat = crossings(1);
                    GoodUnitStructSorted(n).CellX_MLI(k).inhEnd = crossings(end);
                    if GoodUnitStructSorted(n).CellX_MLI(k).inhLat ~= GoodUnitStructSorted(n).CellX_MLI(k).inhEnd
                    if crossings(1) < .005 & crossings(1) > 0
                        GoodUnitStructSorted(n).CellX_MLI(k).inhBoo4SD = 1;
                        GoodUnitStructSorted(n).CellType4 = 'MLIB';
                        GoodUnitStructSorted(n).inhBoo4SD_MLIB = 1;
                    end
                    end
                end  
            end
        end
    end
end


counter = 1;
for n = 1:length(GoodUnitStructSorted)
    if strcmp({GoodUnitStructSorted(n).CellType1}, 'MLI')
        MLI(counter,1) = GoodUnitStructSorted(n).unitID;
        counter = counter + 1;
    end
end

counter = 1;
for n = 1:length(GoodUnitStructSorted)
    if strcmp({GoodUnitStructSorted(n).CellType4}, 'MLIB')
        MLIB(counter,1) = GoodUnitStructSorted(n).unitID;
        counter = counter + 1;
    end
end
% if non-existanct field CellType4
GoodUnitStructSorted(1).CellType4 = [];


tester = GoodUnitStructSorted;
tester(strcmp({GoodUnitStructSorted.layer}, 'GrC_layer')) = [];
mlipc = tester;


%list of all MLIs
counter = 1;
for n = 1:length(GoodUnitStructSorted)
if strcmp({GoodUnitStructSorted(n).CellType1}, 'MLI') | strcmp({GoodUnitStructSorted(n).CellType2}, 'MLIA') | strcmp({GoodUnitStructSorted(n).CellType3}, 'MLIA') | strcmp({GoodUnitStructSorted(n).CellType4}, 'MLIA')
MLI(counter,1) = GoodUnitStructSorted(n).unitID;
counter = counter + 1;
end
end
[C, ia, ic] = unique([MLI]);
MLI = MLI(ia);

%label CS unpaired
for n = 1:length(GoodUnitStructSorted)
    if strcmp({GoodUnitStructSorted(n).layer}, 'ML')
        if ~strcmp({GoodUnitStructSorted(n).CellType1}, 'CS_paired')
            if GoodUnitStructSorted(n).FR < 3
                GoodUnitStructSorted(n).CellType2 = 'CS_unpaired';
            end
        end
    end
    if strcmp({GoodUnitStructSorted(n).layer}, 'PCL') || strcmp({GoodUnitStructSorted(n).layer}, 'PCL_ML_interface')
        if ~strcmp({GoodUnitStructSorted(n).CellType1}, 'CS_paired')
            if GoodUnitStructSorted(n).FR < 2
                GoodUnitStructSorted(n).CellType2 = 'CS_unpaired';
            end
        end
    end
end


%list of unpaired CS;
counter = 1;
for n = 1:length(GoodUnitStructSorted)
if strcmp({GoodUnitStructSorted(n).CellType2}, 'CS_unpaired')
CS_unpaired(counter,1) = GoodUnitStructSorted(n).unitID;
counter = counter + 1;
end
end
[C, ia, ic] = unique([CS_unpaired]);
CS_unpaired = CS_unpaired(ia);
CS = [[SS_CS.CS].'; CS_unpaired];

for n = 1:length(GoodUnitStructSorted)
    if strcmp({GoodUnitStructSorted(n).CellType1}, 'CS_paired') | strcmp({GoodUnitStructSorted(n).CellType2}, 'CS_unpaired')
        GoodUnitStructSorted(n).CellType = 'CS';
    end
    if strcmp({GoodUnitStructSorted(n).CellType1}, 'SS_paired') | strcmp({GoodUnitStructSorted(n).CellType2}, 'SS_unpaired')
        GoodUnitStructSorted(n).CellType = 'SS';
    end
    if strcmp({GoodUnitStructSorted(n).CellType1}, 'SS_paired') | strcmp({GoodUnitStructSorted(n).CellType2}, 'SS_unpaired')
        GoodUnitStructSorted(n).CellType = 'SS';
    end
    %this part probably needs fixing where there are MLIA or MLIB, none at
    %time of writing
    if strcmp({GoodUnitStructSorted(n).CellType1}, 'MLI') | strcmp({GoodUnitStructSorted(n).CellType2}, 'MLIA') | strcmp({GoodUnitStructSorted(n).CellType3}, 'MLIA')
        GoodUnitStructSorted(n).CellType = 'MLI';
    end
end






                