function [ ripple_info ] = ripple_detection_apply_threshold( lfp_signal, lfp_threshold )
% Usage:
%   [ ripple_info ] = ripple_detection_apply_threshold( lfp_signal, lfp_threshold )
% Input:
%   lfp_signal      Return value of ripple_detection_preprocess
%   lfp_threshold   Return value of ripple_detection_determine_threshold
% Output:
%   ripple_info     Ripple information for each channel as a cell array
%                   
%                     .start    Start time of ripple
%                     .end      End time of ripple
%                     .peak     Peak time of the instantaneous amplitude (lfp_signal.amp_st) of the signal filtered in the ripple band
%                     .origin   Minimum amplitude of the signal filtered in the ripple band at the peak time nearest to the peak



if ~all(strcmp(lfp_signal.lfp_st.channel_names,lfp_signal.ripple_st.channel_names))
    error('%s: channel names do not match',mfilename());
end
if ~all(strcmp(lfp_signal.lfp_st.channel_names,lfp_signal.amp_st.channel_names))
    error('%s: channel names do not match',mfilename());
end

if ~all(strcmp(lfp_signal.lfp_st.channel_names,lfp_threshold.channel_names))
    error('%s: channel names do not match',mfilename());
end

if ~all([(lfp_signal.lfp_st.sampling_rate==lfp_signal.ripple_st.sampling_rate) (lfp_signal.lfp_st.sampling_rate==lfp_signal.amp_st.sampling_rate)])
    error('%s: samplling rates do not match',mfilename());
end


ch_num = size(lfp_signal.amp_st.signals,2);

% sampling rate
sampling_rate = lfp_signal.amp_st.sampling_rate;


lfp_thresholding_val_up = lfp_threshold.mean + 4 * lfp_threshold.sd;
lfp_thresholding_val_down = lfp_threshold.mean + 2 * lfp_threshold.sd;


ripple_info = cell(1,ch_num);
for ch_i=1:ch_num

    tmp_amp = lfp_signal.amp_st.signals(:,ch_i).^2;
    tmp_flag = tmp_amp > lfp_thresholding_val_up(ch_i);
    up_inds = find((~tmp_flag(1:(end-1))) & tmp_flag(2:end)) + 1;

    tmp_flag = tmp_amp < lfp_thresholding_val_down(ch_i);
    down_inds = find((~tmp_flag(1:(end-1))) & tmp_flag(2:end)); % ‚±‚¿‚ç‚Í+1‚ð‚µ‚È‚­‚ÄOK
    
    ripple_candidates = [];
    test_i=1;
    while (length(up_inds) >= test_i)

        tmp_ind = find(down_inds > up_inds(test_i),1,'first');
        if isempty(tmp_ind)
            break;
        end

        ripple_candidates = [ripple_candidates ; up_inds(test_i) down_inds(tmp_ind)];

        tmp_ind = find(down_inds(tmp_ind) < up_inds,1,'first');
        if isempty(tmp_ind)

            break;
        end
        test_i = tmp_ind;
    end
    

    if isempty(ripple_candidates)
        continue;
    end
    

    ripple_len = (ripple_candidates(:,2) - ripple_candidates(:,1) + 1) / sampling_rate;
    tmp_flag = (ripple_len < 0.02) | (ripple_len > 0.2);
    ripple_candidates(tmp_flag,:) = [];
    

    ripple_peaks = nan(1,size(ripple_candidates,1));
    for ripple_i=1:length(ripple_peaks)
        [~,max_ind] = max(tmp_amp(ripple_candidates(ripple_i,1):ripple_candidates(ripple_i,2)));
        ripple_peaks(ripple_i) = max_ind + ripple_candidates(ripple_i,1) - 1;
    end
    

    adjacent_matrix = false(size(ripple_candidates,1));
    for ripple_i=1:size(ripple_candidates,1)
        adjacent_matrix(ripple_i,:) = abs(ripple_peaks - ripple_peaks(ripple_i)) / sampling_rate < 0.03;
    end
    

    bins = conncomp(graph(adjacent_matrix),'OutputForm','cell');
    

    nonrectified_signal = lfp_signal.ripple_st.signals(:,ch_i);
    

    nonrectified_signal = double(nonrectified_signal);
    

    [~,trough_locs] = findpeaks(-1*nonrectified_signal);
    
    ripple_info{ch_i} = repmat(struct('start',[],'end',[],'peak',[],'origin',[]),1,length(bins));
    for bin_i=1:length(bins)
        ripple_info{ch_i}(bin_i).start = min(ripple_candidates(bins{bin_i},1));
        ripple_info{ch_i}(bin_i).end = max(ripple_candidates(bins{bin_i},2));
        [~,max_ind] = max(tmp_amp(ripple_peaks(bins{bin_i})));
        ripple_info{ch_i}(bin_i).peak = ripple_peaks(bins{bin_i}(max_ind));

        [~,min_ind] = min(abs(trough_locs - ripple_info{ch_i}(bin_i).peak));
        ripple_info{ch_i}(bin_i).origin = trough_locs(min_ind);
    end
end
