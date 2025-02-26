figure
hold on
%layout1.Layout.TileSpan = [1 3];
%plot(trigger);
%trial = 20; %which laser stimulation trial to use for the trace
%fprintf(['For unit ' unitStr 'Laser trial' num2str(trial)]);
TrigMin = -.05;
TrigMax = .05;
ChansFromChan = 0;
unit = 197;
timeTS = 2.967449029318315e+03;
[TraceData, reporter] = LongTraceRead([timeTS+TrigMin, timeTS+TrigMax], unit, AllUnitStruct, ChansFromChan);
 AddUnitToTrace ([timeTS+TrigMin, timeTS+TrigMax], AllUnitStruct, unit, ChansFromChan, 'm');
  %AddUnitToTrace ([trigger(trial)+TrigMin, trigger(trial)+TrigMax], struct, 234, 1, 'y');
 %xline(timeTS, 'b', 'LineWidth', 2, 'Label', 'spike');
  hold on
 p = plot([timeTS-.05; timeTS], [-.0001;-.0001], 'b');
    p.LineWidth = 2;
    text( timeTS-.04, -.00012, '50 ms', 'Color', 'blue');
