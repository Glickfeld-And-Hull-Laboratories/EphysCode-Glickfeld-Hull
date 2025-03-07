function multiWFPlotterOnly4_INDEX(structstruct)
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
    if length([struct(1).AvgWf]) == 180
    time = [0:(1/30000):.006];
    time = time(1:end-1);
    end
    if length([struct(1).AvgWf]) == 90
        time = [0:(1/30000):.003];
    time = time(1:end-1);
    end
    %for n = 1:length(struct)
        %textx = time(end/3) + struct(n).X/4000;
        %texty = max(struct(n).AvgWf + struct(n).Y*Scale/30)+.00005;
        %text(textx, texty, [num2str(struct(n).Chan)]); 
    %end
    
    for n = 1:length(struct)
    if abs(struct(n).X <= 40)
    if abs(struct(n).Y <= 40)
        %if struct(n).Chan == Chan
        if (struct(n).X == 0 & struct(n).Y ==0)
        %plot(time, struct(n).AvgWf/-min(struct(n).AvgWf), 'k', 'LineWidth', 2);
         plot(time, struct(n).AvgWf, 'k', 'LineWidth', 2);
        else
        %plot(time, struct(n).AvgWf/-min(struct(n).AvgWf), 'Color', ParulaColors(n,:));
        plot(time, struct(n).AvgWf, 'Color', ParulaColors(n,:));
        end
    end
    end
    end

  
end

    
