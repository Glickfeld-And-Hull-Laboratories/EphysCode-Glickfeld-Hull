% in 210928_1627g0_noloccar

figure
tiledlayout(6,1)
nexttile
channel = 121
[TraceData, reporter] = LongTraceRead([1642.34 1642.4], unit1155, channel);
channel = 121;
AddUnitToTrace (TimeLim, unit1155, channel, colors(1,:));

AddUnitToTrace (TimeLim, unit428, channel, colors(3,:));
AddUnitToTrace (TimeLim, unit1059, channel, colors(4,:));
AddUnitToTrace (TimeLim, unit427, channel, colors(5,:));
AddUnitToTrace (TimeLim, unit1117,channel, colors(2,:));
ylim([-.001 .001]);
channel = 120;
nexttile
[TraceData, reporter] = LongTraceRead([1642.34 1642.4], unit1155, channel);
AddUnitToTrace (TimeLim, unit1155, channel, colors(1,:));

AddUnitToTrace (TimeLim, unit428, channel, colors(3,:));
AddUnitToTrace (TimeLim, unit1059, channel, colors(4,:));
AddUnitToTrace (TimeLim, unit427, channel, colors(5,:));
AddUnitToTrace (TimeLim, unit1117,channel, colors(2,:));
ylim([-.001 .001]);
nexttile
channel = 119;
[TraceData, reporter] = LongTraceRead([1642.34 1642.4], unit1155, channel);
AddUnitToTrace (TimeLim, unit1155, channel, colors(1,:));

AddUnitToTrace (TimeLim, unit428, channel, colors(3,:));
AddUnitToTrace (TimeLim, unit1059, channel, colors(4,:));
AddUnitToTrace (TimeLim, unit427, channel, colors(5,:));
AddUnitToTrace (TimeLim, unit1117,channel, colors(2,:));
ylim([-.001 .001]);
channel = 118;
nexttile
[TraceData, reporter] = LongTraceRead([1642.34 1642.4], unit1155, channel);
AddUnitToTrace (TimeLim, unit1155, channel, colors(1,:));

AddUnitToTrace (TimeLim, unit428, channel, colors(3,:));
AddUnitToTrace (TimeLim, unit1059, channel, colors(4,:));
AddUnitToTrace (TimeLim, unit427, channel, colors(5,:));
AddUnitToTrace (TimeLim, unit1117,channel, colors(2,:));
ylim([-.001 .001]);
nexttile
channel = 117;
[TraceData, reporter] = LongTraceRead([1642.34 1642.4], unit1155, channel);
AddUnitToTrace (TimeLim, unit1155, channel, colors(1,:));

AddUnitToTrace (TimeLim, unit428, channel, colors(3,:));
AddUnitToTrace (TimeLim, unit1059, channel, colors(4,:));
AddUnitToTrace (TimeLim, unit427, channel, colors(5,:));
AddUnitToTrace (TimeLim, unit1117,channel, colors(2,:));
ylim([-.001 .001]);
channel = 116;
nexttile
[TraceData, reporter] = LongTraceRead([1642.34 1642.4], unit1155, channel);
AddUnitToTrace (TimeLim, unit1155, channel, colors(1,:));

AddUnitToTrace (TimeLim, unit428, channel, colors(3,:));
AddUnitToTrace (TimeLim, unit1059, channel, colors(4,:));
AddUnitToTrace (TimeLim, unit427, channel, colors(5,:));
AddUnitToTrace (TimeLim, unit1117,channel, colors(2,:));
ylim([-.001 .001]);
[TraceData, reporter] = LongTraceRead([1642.34 1642.4], unit1155, channel);
AddUnitToTrace (TimeLim, unit1155, channel, colors(1,:));

AddUnitToTrace (TimeLim, unit428, channel, colors(3,:));
AddUnitToTrace (TimeLim, unit1059, channel, colors(4,:));
AddUnitToTrace (TimeLim, unit427, channel, colors(5,:));
AddUnitToTrace (TimeLim, unit1117,channel, colors(2,:));
ylim([-.001 .001]);