function [N] = doubleExpCausalFilter(t_r, t_f, len)
dt = 1e-3; % delta T (1.0/sampling_rate) Because my spiketrains/PSTHs are in 1 ms bins
tau_rise = 0.1e-3;
tau_decay = 50e-3;
t = 0:dt:(len * (tau_rise + tau_decay)); % Just a time-axis from 0 to a long ways after the kernel would decay with steps of dt
rise = exp(-t / tau_rise); % Exponential rise
kernel = exp(-t / tau_decay) - rise; % Exponential decay - exponential rise
kernel = (kernel / sum(kernel)); % Normalize.
% Now just convolve the kernel with the spiketrain
Nc = conv(N, kernel);
Nc = Nc(1:length(N));
end
