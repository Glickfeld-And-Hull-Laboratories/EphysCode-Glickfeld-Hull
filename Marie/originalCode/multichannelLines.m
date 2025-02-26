figure

channels = [136 135 134 133 132 131 130];
tiledlayout(length(channels),1)

for n = 1:length(channels)
    fprintf(num2str(channels(n)));
nexttile(n)
MakeLongTrace(AllUnitStruct, channels(n), unitML, [997.52 997.72], colors);
ylim([-.00015, .00015]);
channel = num2str(channels(n));
ylabel(channel);
end
