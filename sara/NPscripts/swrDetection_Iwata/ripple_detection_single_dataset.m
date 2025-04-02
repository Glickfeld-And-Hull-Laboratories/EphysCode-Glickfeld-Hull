function [ ripple_info, lfp_st, ripple_st ] = ripple_detection_single_dataset( data_st )
% Usage:
%   [ ripple_info, lfp_st, ripple_st ] = ripple_detection_single_dataset( data_st )
% Input:
%   data_st    bipolar signals from hippocampus
%  
% Output:
%   ripple_info     ripple timing of each channel stored in a cell (1*ch_num)
%                   Each cell has the following structure
%     .start        index of ripple start
%     .end          index of ripple end
%     .peak         index of ripple peak
%     .origin       index of ripple rigin
%   lfp_st          signal with power line noise removed in preprocessing
%   ripple_st       filtered signal with 70-180Hz filter

% Preprocessing (filtering)
lfp_signal = ripple_detection_preprocess(data_st);

% Determination of threshold values
% To avoid filtering edge effects, the 10 seconds at start and end are cut off.
amp_st = lfp_signal.amp_st;
amp_st.signals(1:(10*amp_st.sampling_rate),:) = [];
amp_st.signals((end-(10*amp_st.sampling_rate)+1):end,:) = [];

% Remove 10 seconds at start and end of each for threshold determination.
lfp_threshold = ripple_detection_determine_threshold({amp_st},10);

% Applying threshold
ripple_info = ripple_detection_apply_threshold(lfp_signal,lfp_threshold);

lfp_st = lfp_signal.lfp_st;
ripple_st = lfp_signal.ripple_st;
