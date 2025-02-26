function [N, edges] = zscorey(N, edges, SDlim)
[meanLine, stdevLine] = StDevLine(N, edges, SDlim);
N = N - meanLine;
N = N/stdevLine;
end
