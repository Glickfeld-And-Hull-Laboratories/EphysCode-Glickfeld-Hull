function waveformByChannel(unit, struct, TimeLim1, TimeGridA, TimeGridB)

unitIN = find([struct.unitID] == unit);
channel = struct(unitIN).channel;

 figure
layout= tiledlayout('flow');
nexttile

[time, WF, ~] = SampleWaveformsTimeLimTG(TimeGridA, TimeGridB, struct, .003, 100, TimeLim1, unit, channel);
title([num2str(unit) ' on ' num2str(channel)]);

nexttile
TileChannel = channel + 1;
[time, WF, ~] = SampleWaveformsTimeLimTG(TimeGridA, TimeGridB, struct, .003, 100, TimeLim1, unit, TileChannel);
title([num2str(unit) ' on ' num2str(TileChannel)]);

nexttile
TileChannel = channel + 2;
[time, WF, ~] = SampleWaveformsTimeLimTG(TimeGridA, TimeGridB, struct, .003, 100, TimeLim1, unit, TileChannel);
title([num2str(unit) ' on ' num2str(TileChannel)]);

nexttile
TileChannel = channel + 3;
[time, WF, ~] = SampleWaveformsTimeLimTG(TimeGridA, TimeGridB, struct, .003, 100, TimeLim1, unit, TileChannel);
title([num2str(unit) ' on ' num2str(TileChannel)]);

nexttile
TileChannel = channel + 4;
[time, WF, ~] = SampleWaveformsTimeLimTG(TimeGridA, TimeGridB, struct, .003, 100, TimeLim1, unit, TileChannel);
title([num2str(unit) ' on ' num2str(TileChannel)]);

nexttile
TileChannel = channel - 1;
[time, WF, ~] = SampleWaveformsTimeLimTG(TimeGridA, TimeGridB, struct, .003, 100, TimeLim1, unit, TileChannel);
title([num2str(unit) ' on ' num2str(TileChannel)]);

nexttile
TileChannel = channel - 2;
[time, WF, ~] = SampleWaveformsTimeLimTG(TimeGridA, TimeGridB, struct, .003, 100, TimeLim1, unit, TileChannel);
title([num2str(unit) ' on ' num2str(TileChannel)]);

nexttile
TileChannel = channel - 3;
[time, WF, ~] = SampleWaveformsTimeLimTG(TimeGridA, TimeGridB, struct, .003, 100, TimeLim1, unit, TileChannel);
title([num2str(unit) ' on ' num2str(TileChannel)]);

nexttile
TileChannel = channel - 4;
[time, WF, ~] = SampleWaveformsTimeLimTG(TimeGridA, TimeGridB, struct, .003, 100, TimeLim1, unit, TileChannel);
title([num2str(unit) ' on ' num2str(TileChannel)]);
end