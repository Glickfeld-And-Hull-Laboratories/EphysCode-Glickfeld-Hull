function [neurons, Trigger] = loadMatlabFiles ()
files = dir('*.mat');
load(files(1).name)
load(files(2).name)
neurons = neurons;
Trigger = Trigger;
end


