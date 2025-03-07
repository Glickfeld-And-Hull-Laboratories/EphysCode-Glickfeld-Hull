[SpeedTimes, SpeedValues] = QuadratureDecoderFast();
SpeedTimes = SpeedTimes.';

% ADJUST SPEED TIMES!!!!!! so so sad.
save SpeedTimes.txt SpeedTimes -ascii -double
TPrime -syncperiod=1.000000 -tostream=Z:\NeuropixelsAnalysis\AuditoryDay1\1694\1694_240626_day15_Npx_g0_analysis\1694_240626_day15_Npx_g0_tcat.imec0.ap.SY_384_6_500.txt -fromstream=1,Z:\NeuropixelsAnalysis\AuditoryDay1\1694\1694_240626_day15_Npx_g0_analysis\1694_240626_day15_Npx_g0_tcat.nidq.XD_2_0_0.txt -events=1,Z:\NeuropixelsAnalysis\AuditoryDay1\1694\1694_240626_day15_Npx_g0_analysis\SpeedTimes.txt,Z:\NeuropixelsAnalysis\AuditoryDay1\1694\1694_240626_day15_Npx_g0_analysis\SpeedTimesAdj.txt

fid = fopen('SpeedTimesAdj.txt');
SpeedTimesAdj = fscanf(fid, '%f');
fclose(fid);
%import AllLicksAdj
% fid = fopen('AllLicksAdj.txt');
% AllLicksAdj = fscanf(fid, '%f');
% fclose(fid);
[RunMetaData, Index_stay_cell, Index_move_cell, Index_forwardrun_cell, still_TGA, still_TGB, move_TGA, move_TGB] = find_behavStatesMEH(SpeedTimesAdj, SpeedValues);


% if Licking Data is present
for n = 1:length(still_TGA)
if ~isempty(find(still_TGA(n) < AllLicksAdj & AllLicksAdj < still_TGB(n)))
qsc_TGA(n) = NaN;
qsc_TGB(n) = NaN;
else
qsc_TGA(n) = still_TGA(n);
qsc_TGB(n) = still_TGB(n);
end
end
qsc_TGA = rmmissing(qsc_TGA);
qsc_TGB = rmmissing(qsc_TGB);
%
%else this 
%for n = 1:length(still_TGA)
%qsc_TGA(n) = still_TGA(n);
%qsc_TGB(n) = still_TGB(n);
 
RunningStruct.SpeedTimesAdj = SpeedTimesAdj;
RunningStruct.SpeedValues = SpeedValues;
RunningStruct.qsc_TGA = qsc_TGA;
RunningStruct.qsc_TGB = qsc_TGB;
RunningStruct.move_TGA = move_TGA;
RunningStruct.move_TGB = move_TGB;
RunningStruct.RunMetaData = RunMetaData;
RunningStruct.loc = what().path;
%save('RunningData')

