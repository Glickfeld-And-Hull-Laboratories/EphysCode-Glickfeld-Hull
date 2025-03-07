function multiWFPlotterOnly4(structstruct)
ParulaColors = colormap(parula(length(structstruct))); % 10 is number of color
for m = 1:length(structstruct)%length(structstruct)
    struct = structstruct(m).wfStructStruct;
    Scale(m) = struct.Scale;
end
Scale = max(Scale);

for m = 1:length(structstruct)%length(structstruct)
figure
hold on
title(num2str(structstruct(m).unitID))
FormatFigure
 ParulaColors = colormap(parula(13)); 
Chan = structstruct(m).BiggestWFstruct.chan;

    %k = find([structstruct.unit] == list(m));
    %struct = structstruct(k).TGlim1WFs;
    struct = structstruct(m).wfStructStruct;
    %struct = structstruct(k).MultiChanWFStruct;
   
    Scale = struct.Scale;
    time = [0:(1/30000):.006];
    time = time(1:end-1);
    %for n = 1:length(struct)
        %textx = time(end/3) + struct(n).X/4000;
        %texty = max(struct(n).AvgWf + struct(n).Y*Scale/30)+.00005;
        %text(textx, texty, [num2str(struct(n).Chan)]); 
    %end
    
    for n = 1:length(struct)
    if abs(struct(n).X < 25)
    if abs(struct(n).Y < 25)
        if struct(n).Chan == Chan
        plot(time, struct(n).AvgWf/-min(struct(n).AvgWf), 'k');
        else
        plot(time, struct(n).AvgWf/-min(struct(n).AvgWf), 'Color', ParulaColors(n,:));
        end
    end
    end
    end

  
end

    
