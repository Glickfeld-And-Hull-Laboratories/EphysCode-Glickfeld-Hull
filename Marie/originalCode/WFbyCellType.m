function data = WFbyCellType(dataStruct)
types = {'MFB'; 'PkC_ss'; 'PkC_cs'; 'MLI'};
colors = ['r', 'b', 'k', 'm'];
count = [ 0; 0; 0; 0];
counter = 1;
for c = 1:length(types)
    figure
    hold on
    for n =2:length(fieldnames(dataStruct))

        fields = fieldnames(dataStruct);
        data = struct2cell(dataStruct);
        CellList = [fields data];
        ForFranscisco(counter)= {[CellList{n,2}.dataset_id], [CellList{n,2}.optotagged_label], CellList{n,2}.neuron_id, CellList{n,2}.primary_channel};
        channel = CellList{n,2}.primary_channel;
        channelindex = find([CellList{n,2}.channel_ids] == channel);
        if strcmp(CellList{n,2}.optotagged_label{1,1}, types{c})
            count(c) = count(c)+1;
            plot([CellList{n,2}.mean_waveform_preprocessed(:,channelindex)], colors(c));
        end
        %title({[CellList{n,2}.optotagged_label{1,1} ' ' strrep(CellList{n,1}, '_', ' ')]; [ ' aka ' num2str(CellList{n,2}.neuron_id) ' from ' strrep(CellList{n,2}.dataset_id{1,1}, '_', ' ')]});
        title(types{c})
        counter = counter+1;
    end
    
end
count
end
