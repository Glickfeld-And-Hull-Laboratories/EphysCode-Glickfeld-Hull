function [CorrDiv] = WFcorr_MLI_Golgi_dist(structstruct, indexList, MEH_chanMap)
%%ParulaColors =distinguishable_colors(length(indexList)); % 10 is number of color
%%title_ = [];
for m = 1:length(indexList)%length(structstruct)
    indexList(m,1);
    struct = structstruct(indexList(m,1)).wfStructStruct;
    Scale(m) = struct.Scale;
    %%title_ = [title_ num2str(indexList(m)) ', '];
end
Scale = max(Scale);

%figure
%hold on
%FormatFigure
for m = 1:length(indexList)%length(structstruct)
%figure
%hold on
%title(['Index ' num2str(indexList(m,1))])


    %k = find([structstruct.unit] == list(m));
    %struct = structstruct(k).TGlim1WFs;
    struct = structstruct(indexList(m)).wfStructStruct;
    %struct = structstruct(k).MultiChanWFStruct;
   
    %Scale = struct.Scale;
    
    %time = time(1:end-1);
    %for n = 1:length(struct)
    %if m == 1
    %    textx = time(end/3) + struct(indexList(m,1)).X/4000;
    %    texty = max(struct(indexList(m,1)).AvgWf + struct(indexList(m,1)).Y*Scale/30)+.00005;
    %    text(textx, texty, [num2str(struct(indexList(m,1)).Chan)]);
    %end
    %end
    
    for n = 1:length(struct)
        struct(n).Size = max(struct(n).AvgWf) - min(struct(n).AvgWf);
    end
    [~,Centre] = max([struct.Size]);
    for n = 1:length(struct)
        struct(n).Corr = corr([struct(Centre).AvgWf], [struct(n).AvgWf]);
        struct(n).CorrComp = (struct(n).Corr)*(struct(n).Size/struct(Centre).Size);
        struct(n).SizeComp = (struct(n).Size/struct(Centre).Size);
        struct(n).CorrDiv = (struct(n).Corr)/(struct(n).Size/struct(Centre).Size);
    end
    for n = 1:length(struct)
        time = [0:(1/30000):((length(struct(n).AvgWf)-1)/30000)];
        %struct(n).Chan;
        %%x = MEH_chanMap(find([MEH_chanMap.chan] == struct(n).Chan)).xcoord;
        %%y = MEH_chanMap(find([MEH_chanMap.chan] == struct(n).Chan)).ycoord;
        %%plot([0:(1/30000):((length(struct(n).AvgWf)-1)/30000)]+ x/4000, struct(n).AvgWf+y*Scale/30, 'Color', ParulaColors(m,:));
        %%hold on
        %plot(time + x/4000, struct(n).AvgWf+y*Scale/30, 'Color', ParulaColors(m,:));
         %plot(time+ struct(n).X/4000, struct(n).AvgWf+struct(n).Chan*Scale/10, 'Color', ParulaColors(m,:));
            if m == 1
        %%textx = time(end/3) + x/4000;
        %%texty = max(struct(n).AvgWf + y*Scale/30)+.00005;
        %text(textx, texty, [num2str(struct(n).Chan)]); 
        %%text(textx, texty, [num2str(struct(n).CorrComp)]); 
       %[num2str(struct(n).Chan)]
    end
    end


%%title(title_);
%%FormatFigure
%saveas(gca, ['WFs ' title_]);
%print(['WFs ' title_], '-dpsc', '-painters');

CorrelationVector = sort([struct.Corr], 'descend');
CorrComp = sort([struct.CorrComp], 'descend');
SizeComp = sort([struct.SizeComp], 'descend');
CorrDiv = sort([struct.CorrDiv], 'descend');
end

    
