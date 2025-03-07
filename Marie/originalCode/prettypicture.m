function prettypicture(TimeGridA, TimeGridB, unit, structure, Trigger, TimeLim, channel, binSize, wvTime, RespNeg, RespPos, ISImax, ACGwin)

figure
tiledlayout('flow');
ax1 = nexttile;
SampleWaveformsTimeLim(structure, wvTime, 100, TimeLim, unit, channel);

ax2 = nexttile;
%SampleWaveformsTimeLimTG(TimeGridA, TimeGridB,structure, wvTime, 100, TimeLim, unit, channel);

ax3 = nexttile;

%ISIstructTimeGridTimeLim(TimeGridA, TimeGridB, structure, unit, [0 ISImax], TimeLim, binSize);

ax4 = nexttile;

autoCorrStructNewLimits(structure, -1*ACGwin, ACGwin, binSize, unit, TimeLim, 'k');

ax5 = nexttile;

%autoCorrStructNewLimitsTG(TimeGridA, TimeGridB, structure, -1*ACGwin, ACGwin, binSize, unit, TimeLim, 'k');

ax6 = nexttile;

%OneUnitHistStructTimeLim(Trigger, unit, structure, RespNeg, RespPos, binSize, TimeLim);

ax7 = nexttile;

%FRstructTimeGridTimeLimit(TimeGridA,TimeGridB, TimeLim, structure, unit)

end