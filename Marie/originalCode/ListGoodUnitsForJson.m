for n = 1:length(Rlist)
    ForGoodUnits = Summary([Summary.RecorNum] == n);
    fileName = ['RecordingJson' num2str([ForGoodUnits(1).RecorNum]-1) '.txt'];
    ForGoodUnits = [ForGoodUnits.unitID].';
    fileID = fopen(fileName, 'w');
    for k = 1:size(ForGoodUnits, 1)-1
        fprintf(fileID, '%4.0f,', round(ForGoodUnits(k, :)));
    end
    fprintf(fileID, '%4.0f', round(ForGoodUnits(k+1, :)));
    fclose(fileID);
    
    fileName = ['RecordingJson' num2str(n-1) '_optoStim.txt'];
    fileID = fopen(fileName, 'w');
    for k = 1:size([Rlist(n).LaserStim], 1)-1
        fprintf(fileID, '[%4.6f,', Rlist(n).LaserStim(k, 1));
        fprintf(fileID, '%4.6f],', Rlist(n).LaserStim(k, 2));
    end
    fprintf(fileID, '[%4.6f,', Rlist(n).LaserStim(k+1, 1));
        fprintf(fileID, '%4.6f]', Rlist(n).LaserStim(k+1, 2));
    fclose(fileID);
    
    Rlist(n).GlobalSanePeriods = [0 Rlist(n).LaserStim(1, 1)];
    halfInterval = median(diff([Rlist(n).LaserStim(:, 1)]))/2;
    Rlist(n).GlobalSanePeriods = [Rlist(n).GlobalSanePeriods; [[Rlist(n).LaserStim(2:end, 1)] - round(halfInterval) [Rlist(n).LaserStim(2:end, 1)]]];
Rlist(n).GlobalSanePeriods = Rlist(n).GlobalSanePeriods([Rlist(n).GlobalSanePeriods(:,1)] < Rlist(n).DrugBaseline(2),:);
    fileName = ['RecordingJson' num2str(n-1) '_globalSanePeriods.txt'];
    fileID = fopen(fileName, 'w');
    for k = 1:size([Rlist(n).GlobalSanePeriods], 1)-1
        fprintf(fileID, '[%4.6f,', Rlist(n).GlobalSanePeriods(k, 1));
        fprintf(fileID, '%4.6f],', Rlist(n).GlobalSanePeriods(k, 2));
    end
    fprintf(fileID, '[%4.6f,', Rlist(n).GlobalSanePeriods(k+1, 1));
        fprintf(fileID, '%4.6f]', Rlist(n).GlobalSanePeriods(k+1, 2));
    fclose(fileID);
end