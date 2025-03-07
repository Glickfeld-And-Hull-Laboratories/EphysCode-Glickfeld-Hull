fid = fopen('JuiceTimesAdj_ag0.txt');
JuiceTimesAdj_ag0 = fscanf(fid, '%f');
fclose(fid);
fid = fopen('ToneTimesAdj_ag0.txt');
ToneTimesAdj_ag0 = fscanf(fid, '%f');
fclose(fid);

ToneTimesAdj_ag0 = ToneTimesAdj_ag0 + g1FileTime;
JuiceTimesAdj_ag0 =JuiceTimesAdj_ag0 + g1FileTime;
fid = fopen('JuiceTimesAdj_g1.txt');
JuiceTimesAdj_g1 = fscanf(fid, '%f');
fclose(fid);
fid = fopen('ToneTimesAdj_g1.txt');
ToneTimesAdj_g1 = fscanf(fid, '%f');
fclose(fid);
ToneTimesAdj_g1 = ToneTimesAdj_g1(ToneTimesAdj_g1<g1FileTime);
JuiceTimesAdj_g1 = JuiceTimesAdj_g1(JuiceTimesAdj_g1<g1FileTime);
ToneTimesBoth = [ToneTimesAdj_g1; ToneTimesAdj_ag0];
JuiceTimesBoth = [JuiceTimesAdj_g1; JuiceTimesAdj_ag0];
fid = fopen('AllLicksAdj_g1.txt');
AllLicksAdj_g1 = fscanf(fid, '%f');
fclose(fid);
fid = fopen('AllLicksAdj_ag0.txt');
AllLicksAdj_ag0 = fscanf(fid, '%f');
fclose(fid);
AllLicksAdj_ag0 = AllLicksAdj_ag0 + g1FileTime;
AllLicksAdj_g1 = AllLicksAdj_g1(AllLicksAdj_g1<g1FileTime);
AllLicksAdjBoth= [AllLicksAdj_g1; AllLicksAdj_ag0];

fid = fopen('1672_230209_g1_tcat.imec0.ap.SY_384_6_500.txt');
SY_g1 = fscanf(fid, '%f');
fclose(fid);
fid = fopen('1673_230217a_g0_tcat.imec0.ap.SY_384_6_500.txt');
SY_ag0 = fscanf(fid, '%f');
fclose(fid);
SY_ag0 = SY_ag0 + g1FileTime;
SY_g1 = SY_g1(SY_g1<g1FileTime);
SYBoth= [SY_g1; SY_ag0];

fid = fopen('1672_230209_g1_tcat.nidq.XD_2_0_0.txt');
XD_2_0_0_g1 = fscanf(fid, '%f');
fclose(fid);
fid = fopen('1672_230209a_g0_tcat.nidq.XD_2_0_0.txt');
XD_2_0_0_ag0 = fscanf(fid, '%f');
fclose(fid);
XD_2_0_0_ag0 = XD_2_0_0_ag0 + g1FileTime;
XD_2_0_0_g1 = XD_2_0_0_g1(XD_2_0_0_g1<g1FileTime);
XD_2_0_0Both= [XD_2_0_0_g1; XD_2_0_0_ag0];



save AllLicksAdj_all.txt AllLicksAdj_all -ascii -double
save JuiceTimesAdj_all.txt JuiceTimesAdj_all -ascii -double
save ToneTimesAdj_all.txt ToneTimesAdj_all -ascii -double
save SY_all.txt SY_all -ascii -double
save XD_2_0_0_all.txt XD_2_0_0_all -ascii -double

TPrime -syncperiod=1.000000 -tostream=Z:\NeuropixelsAnalysis\AuditoryDay1\1672\supercat_1672_230209_g1\SY_all.txt -fromstream=1,Z:\NeuropixelsAnalysis\AuditoryDay1\1672\supercat_1672_230209_g1\XD_2_0_0_all.txt -events=1,Z:\NeuropixelsAnalysis\AuditoryDay1\1672\supercat_1672_230209_g1\JuiceTimesAdj_all.txt,Z:\NeuropixelsAnalysis\AuditoryDay1\1672\supercat_1672_230209_g1\JuiceTimesDoubleAdj.txt
TPrime -syncperiod=1.000000 -tostream=Z:\NeuropixelsAnalysis\AuditoryDay1\1672\supercat_1672_230209_g1\SY_all.txt -fromstream=1,Z:\NeuropixelsAnalysis\AuditoryDay1\1672\supercat_1672_230209_g1\XD_2_0_0_all.txt -events=1,Z:\NeuropixelsAnalysis\AuditoryDay1\1672\supercat_1672_230209_g1\ToneTimesAdj_all.txt,Z:\NeuropixelsAnalysis\AuditoryDay1\1672\supercat_1672_230209_g1\ToneTimesDoubleAdj.txt
TPrime -syncperiod=1.000000 -tostream=Z:\NeuropixelsAnalysis\AuditoryDay1\1672\supercat_1672_230209_g1\SY_all.txt -fromstream=1,Z:\NeuropixelsAnalysis\AuditoryDay1\1672\supercat_1672_230209_g1\XD_2_0_0_all.txt -events=1,Z:\NeuropixelsAnalysis\AuditoryDay1\1672\supercat_1672_230209_g1\AllLicksAdj_all.txt,Z:\NeuropixelsAnalysis\AuditoryDay1\1672\supercat_1672_230209_g1\AllLicksDoubleAdj.txt
TPrime -syncperiod=1.000000 -tostream=Z:\NeuropixelsAnalysis\AuditoryDayN\1673\1673_230217\supercat\supercat_1673_230217_g1\SY_Both.txt -fromstream=1,Z:\NeuropixelsAnalysis\AuditoryDayN\1673\1673_230217\supercat\supercat_1673_230217_g1\XD_2_0_0Both.txt -events=1,Z:\NeuropixelsAnalysis\AuditoryDayN\1673\1673_230217\supercat\supercat_1673_230217_g1\SpeedTimesBothAdj.txt,Z:\NeuropixelsAnalysis\AuditoryDayN\1673\1673_230217\supercat\supercat_1673_230217_g1\SpeedTimesDoubleAdj.txt

fid = fopen('JuiceTimesDoubleAdj.txt');
JuiceTimesAdj = fscanf(fid, '%f');
fclose(fid);
fid = fopen('ToneTimesDoubleAdj.txt');
ToneTimesAdj = fscanf(fid, '%f');
fclose(fid);
fid = fopen('AllLicksDoubleAdj.txt');
AllLicksAdj = fscanf(fid, '%f');
fclose(fid);

fid = fopen(SpeedTimes_g1.txt');
SpeedTimes_g1 = fscanf(fid, '%f');
fclose(fid);