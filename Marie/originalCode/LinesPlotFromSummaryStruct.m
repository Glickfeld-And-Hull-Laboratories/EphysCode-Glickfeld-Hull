figure
hold on
for n = 1:length(SummaryStruct_Long)
    if strcmp(SummaryStruct_Long(n).handID, 'Golgi')
        if strcmp(SummaryStruct_Long(n).expertID, 'layer')
            plot(SummaryStruct_Long(n).BiggestWFstruct.alignedWF/-min(SummaryStruct_Long(n).BiggestWFstruct.alignedWF), 'k', 'LineWidth', 1)
        end
        if strcmp(SummaryStruct_Long(n).expertID, 'DE')
            plot(SummaryStruct_Long(n).BiggestWFstruct.alignedWF/-min(SummaryStruct_Long(n).BiggestWFstruct.alignedWF), 'b', 'LineWidth', 1)
        end
    end
end

figure
hold on
for n = 1:length(SummaryStruct_Long)
    if strcmp(SummaryStruct_Long(n).handID, 'MLI')
        if strcmp(SummaryStruct_Long(n).expertID, 'layer')
            plot(SummaryStruct_Long(n).BiggestWFstruct.alignedWF/-min(SummaryStruct_Long(n).BiggestWFstruct.alignedWF), 'm', 'LineWidth', 1)
        end
        if strcmp(SummaryStruct_Long(n).expertID, 'ccg')
            plot(SummaryStruct_Long(n).BiggestWFstruct.alignedWF/-min(SummaryStruct_Long(n).BiggestWFstruct.alignedWF), 'r', 'LineWidth', 1)
        end
    end
end



for n = 1:length(SummaryStruct_Long)
    if strcmp(SummaryStruct_Long(n).handID, 'Golgi')
        if strcmp(SummaryStruct_Long(n).expertID, 'layer')
            plot(SummaryStruct_Long(n).BiggestWFstruct.WF/-min(SummaryStruct_Long(n).BiggestWFstruct.WF), 'k', 'LineWidth', 1)
        end
        if strcmp(SummaryStruct_Long(n).expertID, 'DE')
            plot(SummaryStruct_Long(n).BiggestWFstruct.WF/-min(SummaryStruct_Long(n).BiggestWFstruct.WF), 'b', 'LineWidth', 1)
        end
    end
end


for n = 1:length(SummaryStruct_Long)
    if strcmp(SummaryStruct_Long(n).handID, 'MLI')
        if strcmp(SummaryStruct_Long(n).expertID, 'layer')
            plot(SummaryStruct_Long(n).BiggestWFstruct.WF/-min(SummaryStruct_Long(n).BiggestWFstruct.WF), 'm', 'LineWidth', 1)
        end
        if strcmp(SummaryStruct_Long(n).expertID, 'ccg')
            plot(SummaryStruct_Long(n).BiggestWFstruct.WF/-min(SummaryStruct_Long(n).BiggestWFstruct.WF), 'r', 'LineWidth', 1)
        end
    end
end
