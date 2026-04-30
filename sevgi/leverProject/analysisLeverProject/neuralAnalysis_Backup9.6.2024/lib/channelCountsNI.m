% =========================================================
% Directly transferred from DemoReadSGLXData.m (SpikeGLX_Datafile_Tools https://billkarsh.github.io/SpikeGLX/#post-processing-tools)
% =========================================================
% Return counts of each nidq channel type that compose
% the timepoints stored in binary file.
%
function [MN,MA,XA,DW] = channelCountsNI(meta)
    M = str2num(meta.snsMnMaXaDw);
    MN = M(1);
    MA = M(2);
    XA = M(3);
    DW = M(4);
end % ChannelCountsNI