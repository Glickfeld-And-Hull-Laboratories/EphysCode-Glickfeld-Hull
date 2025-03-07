shiftmax = 20;
for n =1:length(GoodUnitStruct)
    [time, Waveforms, SampleTS] = SampleWaveformsTimeLimTGzerogo(TimeGridA, TimeGridB, GoodUnitStruct, .006, 100, [0 inf], GoodUnitStruct(n).unitID, GoodUnitStruct(n).channel);
    [AlignedWaveforms, peakcentered, noshift] = AlignWaveformsXcorr(Waveforms, shiftmax);
    output(n,1)= GoodUnitStruct(n).unitID;
    output(n,2)= peakcentered;
    output(n,3)= noshift;
    
    AVG = avgeWaveforms(Waveforms);
    AVG2 = avgeWaveforms(AlignedWaveforms);
    
    f = figure;
    layout1 = tiledlayout(1,2);
    set(gcf,'Position',[300 350 800 500]);
nexttile
hold on
for k = 1:size(Waveforms, 2)
plot(Waveforms(shiftmax:(end-shiftmax),k), 'k');
end
plot(AVG(shiftmax:(end-shiftmax),1), 'Color', 'r', 'LineWidth', 2);
title([num2str(GoodUnitStruct(n).unitID) ' on ' num2str(GoodUnitStruct(n).channel)]);
FormatFigure
y1= ylim;


nexttile
hold on
for k = 1:size(AlignedWaveforms, 2)
plot(AlignedWaveforms(:,k), 'k');
end
plot(AVG2, 'Color', 'r', 'LineWidth', 2);
title([num2str(GoodUnitStruct(n).unitID) ' on ' num2str(GoodUnitStruct(n).channel) ' Aligned']);
FormatFigure
ylim(y1);
 print(['\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\marie\NeuropixelsAnalysis\DH\DH12\DH12_21_12_01\DH12_21_12_01_g1\DH12_211201g1_loccar1_2_KS2.5normal_notopchans\AlignmentIssueFigure\' num2str(GoodUnitStruct(n).unitID)],'-depsc','-painters')
end

[time2, Waveforms2, SampleTS2] = SampleWaveformsTimeLimTGzerogo(TimeGridA, TimeGridB, GoodUnitStruct, .006, 100, [0 inf], 415, 84);
[AlignedWaveforms, shiftTime, peakcentered, noshift] = AlignWaveformsXcorr(Waveforms2, 20);
NewTime = SampleTS2 + shiftTime;
[time, MFWaveformssetshift] = GetWaveformsAtTimes(.006, 84, NewTime);
figure
hold on
