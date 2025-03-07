function AvgWvF = avgeWaveformsNew(WvTraces)
%title_ = inputname(1);
sz = size(WvTraces);
numrows = sz(1);
numcolumns = sz(1,2);
AvgWvF = (sum(WvTraces, 2))/(numcolumns);


end


