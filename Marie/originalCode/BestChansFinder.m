function BestChansFinder(unit, struct, trigger)

TrigMin = .1
TrigMax = .2
ylimitTrace = NaN;

unitIN = find([struct.unitID] == unit);

figure
tiledlayout('flow');
nexttile
%layout1.Layout.TileSpan = [1 3];
%plot(trigger);
trial = 20 %which laser stimulation trial to use for the trace
ChansFromChan = 0;
[TraceData, reporter] = LongTraceRead([trigger(trial)+TrigMin, trigger(trial)+TrigMax], unit, struct, ChansFromChan);
 AddUnitToTrace ([trigger(trial)+TrigMin, trigger(trial)+TrigMax], struct, unit, ChansFromChan, 'm');
  %AddUnitToTrace ([trigger(trial)+TrigMin, trigger(trial)+TrigMax], struct, 234, 1, 'y');
 xline(trigger(trial), 'b');
  hold on
 plot([trigger(trial); trigger(trial)+.1], [0;0], 'b');
 title(['ch ' num2str(struct(unitIN).channel)]);
 if ~isnan(ylimitTrace)
   ylim(ylimitTrace);
   end
 
 nexttile
 ChansFromChan = -3;
[TraceData, reporter] = LongTraceRead([trigger(trial)+TrigMin, trigger(trial)+TrigMax], unit, struct, ChansFromChan);
 AddUnitToTrace ([trigger(trial)+TrigMin, trigger(trial)+TrigMax], struct, unit, ChansFromChan, 'm');
 %AddUnitToTrace ([trigger(trial)+TrigMin, trigger(trial)+TrigMax], struct, 234, 2, 'y');
  xline(trigger(trial), 'b');
   hold on
  plot([trigger(trial); trigger(trial)+.1], [0;0], 'b');
   title(num2str(ChansFromChan));
    if ~isnan(ylimitTrace)
   ylim(ylimitTrace);
   end
   
 nexttile
 ChansFromChan = 2;
[TraceData, reporter] = LongTraceRead([trigger(trial)+TrigMin, trigger(trial)+TrigMax], unit, struct, ChansFromChan);
 AddUnitToTrace ([trigger(trial)+TrigMin, trigger(trial)+TrigMax], struct, unit, ChansFromChan, 'm');
 %AddUnitToTrace ([trigger(trial)+TrigMin, trigger(trial)+TrigMax], struct, 234, 0, 'y');
  xline(trigger(trial), 'b');
  hold on
plot([trigger(trial); trigger(trial)+.1], [0;0], 'b');
   title(num2str(ChansFromChan));
   if ~isnan(ylimitTrace)
   ylim(ylimitTrace);
   end
   
    nexttile
 ChansFromChan = -1;
[TraceData, reporter] = LongTraceRead([trigger(trial)+TrigMin, trigger(trial)+TrigMax], unit, struct, ChansFromChan);
 AddUnitToTrace ([trigger(trial)+TrigMin, trigger(trial)+TrigMax], struct, unit, ChansFromChan, 'm');
 %AddUnitToTrace ([trigger(trial)+TrigMin, trigger(trial)+TrigMax], struct, 234, 0, 'y');
  xline(trigger(trial), 'b');
  hold on
plot([trigger(trial); trigger(trial)+.1], [0;0], 'b');
   title(num2str(ChansFromChan));
   if ~isnan(ylimitTrace)
   ylim(ylimitTrace);
   end
   
    nexttile
 ChansFromChan = -2;
[TraceData, reporter] = LongTraceRead([trigger(trial)+TrigMin, trigger(trial)+TrigMax], unit, struct, ChansFromChan);
 AddUnitToTrace ([trigger(trial)+TrigMin, trigger(trial)+TrigMax], struct, unit, ChansFromChan, 'm');
 %AddUnitToTrace ([trigger(trial)+TrigMin, trigger(trial)+TrigMax], struct, 234, 0, 'y');
  xline(trigger(trial), 'b');
  hold on
plot([trigger(trial); trigger(trial)+.1], [0;0], 'b');
   title(num2str(ChansFromChan));
   if ~isnan(ylimitTrace)
   ylim(ylimitTrace);
   end
   
    nexttile
 ChansFromChan = -4;
[TraceData, reporter] = LongTraceRead([trigger(trial)+TrigMin, trigger(trial)+TrigMax], unit, struct, ChansFromChan);
 AddUnitToTrace ([trigger(trial)+TrigMin, trigger(trial)+TrigMax], struct, unit, ChansFromChan, 'm');
 %AddUnitToTrace ([trigger(trial)+TrigMin, trigger(trial)+TrigMax], struct, 234, 0, 'y');
  xline(trigger(trial), 'b');
  hold on
plot([trigger(trial); trigger(trial)+.1], [0;0], 'b');
   title(num2str(ChansFromChan));
   if ~isnan(ylimitTrace)
   ylim(ylimitTrace);
   end