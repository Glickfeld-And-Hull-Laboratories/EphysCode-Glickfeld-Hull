function [ lfp_threshold ] = ripple_detection_determine_threshold( amp_st_cell, rm_duration )
% Usage:
%   [ lfp_threshold ] = ripple_detection_determine_thrashold( amp_st_cell, rm_duration )
% Input:
%   amp_st_cell     amp_st in ripple_detection_preprocess return value in cell array
%   rm_duration     Period of time (in seconds) to exclude from both ends of the data to avoid edge effects after filtering
% Output:
%   lfp_threshold
%     .mean             mean used for threshold determination
%     .sd               variance used for threshold determination
%     .channel_names    channel name



addpath('eeglab13_5_4b/plugins/firfilt1.6.1');
addpath('signal_processing');

channel_names = amp_st_cell{1}.channel_names;
sampling_rate = amp_st_cell{1}.sampling_rate;

if ~all(cellfun(@(x) all(strcmp(x.channel_names,channel_names)),amp_st_cell,'UniformOutput',true))
    error('%s: channel names do not match',mfilename());
end

if ~all(cellfun(@(x) x.sampling_rate,amp_st_cell,'UniformOutput',true)==sampling_rate)
    error('%s: samplling rates do not match',mfilename());
end


amp_signals = cellfun(@(x) x.signals,amp_st_cell,'UniformOutput',false);


ch_num = size(amp_signals{1},2);

fprintf('Calculating clipping value...');
amp_all = cat(1,amp_signals{:});
lfp_clipping_mean = mean(amp_all,1);
lfp_clipping_sd = std(amp_all,0,1);
lfp_clipping_val = lfp_clipping_mean + 4 * lfp_clipping_sd;
fprintf('done\n');


fprintf('Clipping...');
for cell_i=1:length(amp_signals)
    for ch_i=1:ch_num
        amp_signals{cell_i}(:,ch_i) = min(amp_signals{cell_i}(:,ch_i),lfp_clipping_val(ch_i));
    end
end
fprintf('done\n');


d = designfilt('lowpassfir','PassbandFrequency',40,'StopbandFrequency',45,'DesignMethod','kaiserwin','SampleRate',sampling_rate);
for cell_i=1:length(amp_signals)
    fprintf('Applying low-pass filter [%3d/%3d]\n',cell_i,length(amp_signals));
    amp_signals{cell_i} = filtfilt(d,double(amp_signals{cell_i}.^2)); 
    
    amp_signals{cell_i} = single(amp_signals{cell_i}); 
    

    if size(amp_signals{cell_i},1) <= rm_duration*sampling_rate*2

        amp_signals{cell_i} = [];
    else
        amp_signals{cell_i}(1:(rm_duration*sampling_rate),:) = [];
        amp_signals{cell_i}((end-(rm_duration*sampling_rate)+1):end,:) = [];
    end
end


fprintf('Determining threshold...');
amp_all = cat(1,amp_signals{:});
lfp_threshold.mean = mean(amp_all,1);
lfp_threshold.sd = std(amp_all,0,1);
lfp_threshold.channel_names = channel_names;
fprintf('done\n');

return;
