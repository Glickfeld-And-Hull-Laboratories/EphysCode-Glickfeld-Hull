%waveform comparison for Court
function wavecompare(struct, dataLength, num, depth, cellTypeString)
  %figure
    %hold on
    %title_ = '';
for n = 1:length(struct)
    if ((struct(n).TrueDepth < depth) && (strcmp(struct(n).CellType, cellTypeString)))
    [RunA, RunB, NorunA, NorunB]= ifRunTimeBlocks(struct(n).ifRunAdj);
    timeLim = struct(n).TimeLim;
    unit = struct(n).unitID;
    chan = struct(n).channel;
    figure
    hold on
    SampleWaveformsTimeBlocks(RunA, RunB, struct, dataLength, num, timeLim, 'g', unit, chan);
    SampleWaveformsTimeBlocks(NorunA, NorunB, struct, dataLength, num, timeLim, 'r', unit, chan);
    title([num2str(unit) ' at ' num2str(struct(n).TrueDepth)]);
    title_ = [num2str(unit) ' at ' num2str(struct(n).TrueDepth)];
    %title_ = ([title_ num2str(unit) ' at ' num2str(struct(n).TrueDepth) ', ']);
    FormatFigure
    hold off
    title_eps = [title_ '.eps'];
    saveas(gca, title_eps, 'epsc');
    saveas(gca, title_);
    end
    %title(title_);
    %hold off
end

    
    