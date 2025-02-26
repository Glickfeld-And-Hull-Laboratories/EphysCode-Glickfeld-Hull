function [Nc] = doubleExpCausalFilter(N, t_r, t_d, len, kernelBoo)
% t_r = tau rise
% t_d = tau decay
% len = length of time axis for kernel (not exactly, see below)
% N = signal to be filtered.
dt = 1e-3; % delta T (1.0/sampling_rate) Because my spiketrains/PSTHs are in 1 ms bins
t = 0:dt:(len * (t_r + t_d)); % Just a time-axis from 0 to a long ways after the kernel would decay with steps of dt
rise = exp(-t / t_r); % Exponential rise
kernel = exp(-t / t_d) - rise; % Exponential decay - exponential rise
kernel = (kernel / sum(kernel)); % Normalize.
if kernelBoo == 1
    figure
    plot(kernel, 'k');
% Now just convolve the kernel with the spiketrain
end
Nc = conv(N, kernel);
Nc = Nc(1:length(N));
end
