function multiWFPlotterCompColors(structstruct, indexList, colorsList, MEH_chanMap)

for m = 1:length(indexList)%length(structstruct)
    struct = structstruct(indexList(m,1)).wfStructStruct;
    Scale(m) = struct.Scale;
end
Scale = max(Scale);

for m = 1:length(indexList)
    struct = structstruct(indexList(m)).wfStructStruct;
    for n = 1:length(struct)
        time = [0:(1/30000):((length(struct(n).AvgWf)-1)/30000)];
        x = MEH_chanMap(find([MEH_chanMap.chan] == struct(n).Chan)).xcoord;
        y = MEH_chanMap(find([MEH_chanMap.chan] == struct(n).Chan)).ycoord;
        plot([0:(1/30000):((length(struct(n).AvgWf)-1)/30000)]+ x/4000, struct(n).AvgWf+y*Scale/30, 'Color', colorsList(m,:));
        hold on
        %plot(time + x/4000, struct(n).AvgWf+y*Scale/30, 'Color', ParulaColors(m,:));
         %plot(time+ struct(n).X/4000, struct(n).AvgWf+struct(n).Chan*Scale/10, 'Color', ParulaColors(m,:));
        
        if struct(n).Chan == structstruct(indexList(m)).channel
            textx = time(end/3) + x/4000;
        texty = max(struct(n).AvgWf + y*Scale/30)+.00005;
        text(textx, texty, [num2str(structstruct(indexList(m)).channel)], 'Color', colorsList(m,:))
        end
    end
end
FormatFigure
%saveas(gca, ['WFs ' title_]);
%print(['WFs ' title_], '-dpsc', '-painters');
end

    
