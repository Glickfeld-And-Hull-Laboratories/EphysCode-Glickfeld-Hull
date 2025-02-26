for c = 1:length(metavars(:,1))
unit = metavars(c,1);
channel = metavars(c,2);
TimeLim = [metavars(c,3) metavars(c,4)];
prettypicture(TimeGridA, TimeGridB, unit, AllUnitStruct, LaserStimAdj, TimeLim, channel, .001, .01, -.05, .12, .1, .15);
end