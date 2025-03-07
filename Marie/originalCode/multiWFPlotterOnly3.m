function multiWFPlotterOnly3(structstruct, indexList, MEH_chanMap, color)
ParulaColors = colormap(parula(length(indexList))); % 10 is number of color
title_ = [];
for m = 1:length(indexList)%length(structstruct)
    struct = structstruct(indexList(m,1)).wfStructStruct;
    Scale(m) = struct.Scale;
    title_ = [title_ num2str(indexList(m)) ', '];
end
Scale = max(Scale)

%figure
%hold on
%FormatFigure
for m = 1:length(indexList)%length(structstruct)
%figure
hold on
title(['Index ' num2str(indexList(m,1))])


    %k = find([structstruct.unit] == list(m));
    %struct = structstruct(k).TGlim1WFs;
    struct = structstruct(indexList(m)).wfStructStruct;
    %struct = structstruct(k).MultiChanWFStruct;
   
    %Scale = struct.Scale;
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
        %struct(n).Chan;
        x = MEH_chanMap(find([MEH_chanMap.chan] == struct(n).Chan)).xcoord;
        y = MEH_chanMap(find([MEH_chanMap.chan] == struct(n).Chan)).ycoord;
        %plot(time+ x/4000, struct(n).AvgWf+y*Scale/30, 'Color', ParulaColors(m,:));
        plot(time+ x/4000, struct(n).AvgWf+y*Scale/30, 'Color', color);
        %plot(time+ struct(n).X/4000, struct(n).AvgWf+struct(n).Chan*Scale/10, 'Color', ParulaColors(m,:));
    end
      end

%title(title_);
%FormatFigure
%saveas(gca, ['WFs ' title_]);
%print(['WFs ' title_], '-dpsc', '-painters');
end

    
