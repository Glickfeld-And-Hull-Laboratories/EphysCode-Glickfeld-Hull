function [state, units] = detectNoResponsesDE(ZERO, N, SDline, msbins, firstCutoff, reqBinH)

state = '0';
units = struct('Lat1',[], 'Lat2',[]);
checker1 = find(N(ZERO:(end)) > SDline); %does resp exceed stdev cutoff within first time window
if checker1
    if length(checker1)>1
            state = 'response';
         
    end

end
end

