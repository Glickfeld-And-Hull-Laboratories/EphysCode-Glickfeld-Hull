function WFfromH5(dataStruct)
for n =2:length(fieldnames(dataStruct))

    fields = fieldnames(dataStruct);
    data = struct2cell(dataStruct);
    CellList = [fields data];
    channel = CellList{n,2}.primary_channel;
    channelindex = find([CellList{n,2}.channel_ids] == channel);
    figure
    plot([CellList{n,2}.mean_waveform_preprocessed(:,channelindex)]);
    title({[CellList{n,2}.optotagged_label{1,1} ' ' strrep(CellList{n,1}, '_', ' ')]; [ ' aka ' num2str(CellList{n,2}.neuron_id) ' from ' strrep(CellList{n,2}.dataset_id{1,1}, '_', ' ')]});
    %title([CellList{n,2}.optotagged_label{1,1} ' ' strrep(CellList{n,1}, '_', ' ')])
end
    