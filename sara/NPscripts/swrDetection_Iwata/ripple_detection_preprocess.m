function [ lfp_signal ] = ripple_detection_preprocess( data_st )
% Usage:
%   [ lfp_signal ] = ripple_detection_preprocess( data_st )
% Input:
%   data_st         bipolar signals
% Output:
%   lfp_signal
%     .lfp_st       Signal with power line noise removed by preprocessing
%     .ripple_st    70-180Hz filtered signal on lfp_st
%     .amp_st       Instantaneous amplitude of ripple_st


addpath('eeglab13_5_4b/plugins/firfilt1.6.1');
addpath('signal_processing');

if ~ismatrix(data_st.signals)
    error('%s: number of trials must be 1',mfilename());
end

lfp_st = data_st;


switch (lfp_st.sampling_rate)
    case 1000
        filt_order = 1150;
    case 2000
        filt_order = 2350;
    otherwise
        error('%s: failed to determin filter order',mfilename());
end

% 60 Hz
d = designfilt('bandstopfir','FilterOrder',filt_order,'CutoffFrequency1',60-1.5,'CutoffFrequency2',60+1.5,'SampleRate',lfp_st.sampling_rate);
lfp_st.signals = filtfilt(d,lfp_st.signals);

% 120 Hz
d = designfilt('bandstopfir','FilterOrder',filt_order,'CutoffFrequency1',120-1.5,'CutoffFrequency2',120+1.5,'SampleRate',lfp_st.sampling_rate);
lfp_st.signals = filtfilt(d,lfp_st.signals);

% 180 Hz
d = designfilt('bandstopfir','FilterOrder',filt_order,'CutoffFrequency1',180-1.5,'CutoffFrequency2',180+1.5,'SampleRate',lfp_st.sampling_rate);
lfp_st.signals = filtfilt(d,lfp_st.signals);

% 240 Hz
d = designfilt('bandstopfir','FilterOrder',filt_order,'CutoffFrequency1',240-1.5,'CutoffFrequency2',240+1.5,'SampleRate',lfp_st.sampling_rate);
lfp_st.signals = filtfilt(d,lfp_st.signals);

ripple_st = lfp_st;

% 70-180 Hz filtering (zero-lag linear-phase Hamming windowed FIR filter with a transition bandwidth of 5 Hz) 
d = designfilt('bandpassfir','PassbandFrequency1',70,'PassbandFrequency2',180,'StopbandFrequency1',65,'StopbandFrequency2',185,'SampleRate',ripple_st.sampling_rate);
ripple_st.signals = filtfilt(d,ripple_st.signals);

amp_st = ripple_st;

% hilbert transformation
amp_st = sigproc_perform_hilbert_transform(amp_st);


amp_st.signals = abs(amp_st.signals);

lfp_signal = [];
lfp_signal.lfp_st = lfp_st;
lfp_signal.ripple_st = ripple_st;
lfp_signal.amp_st = amp_st;

return
