function [ data_st, hilbert_params ] = sigproc_perform_hilbert_transform( data_st, hilbert_params )
% sigproc_perform_hilbert_transform performs hilbert transform
% Usage :
%   [ data_st ] = sigproc_perform_hilbert_transform( data_st )
%   [ data_st, hilbert_params ] = sigproc_perform_hilbert_transform( data_st, hilbert_params )
% Input :
%   data_st
%     .signals          raw data (time * channel * trial)
%   hilbert_params
%     .method           method name to perform ('sigproc_perform_hilbert_transform')
%     .DFT_length       (option) DFT length
% Output :
%   data_st         transformed signal (complex) (time * channel * trial)
%   hilbert_params

if ~exist('hilbert_params','var')
    hilbert_params = [];
end

trial_num = size(data_st.signals,3);
transformed_signals = cell(1,trial_num);

DFT_flag = isfield(hilbert_params,'DFT_length');

for trial_i=1:trial_num
    if DFT_flag
        transformed_signals{trial_i} = hilbert(data_st.signals(:,:,trial_i),hilbert_params.DFT_length);
    else
        transformed_signals{trial_i} = hilbert(data_st.signals(:,:,trial_i));
    end
end

data_st.signals = cat(3,transformed_signals{:});
