function [RunA, RunB, NorunA, NorunB]= ifRunTimeBlocks(ifRunAdj);
%A = start of time blocks
% B = end of time blocks

rCount = 1;

NrCount = 1;

stateVAR = 0;

if ifRunAdj(1,2) == 1
    NorunA(1,1) = ifRunAdj(1,1);
 
    stateVAR = 1;
else
    RunA(1,1) = ifRunAdj(1,1);

    stateVAR = 2;
end

for n = 2:(length(ifRunAdj)-1)
  
    %if state == NORUN && ifRunAdj(n, 2) == 1
    %end
    %if state == RUN && ifRunAdj(n,2) == 2
    %end
    if stateVAR == 1 && ifRunAdj(n,2) == 2
        NorunB(NrCount,1) = ifRunAdj(n,1);
        NrCount =NrCount +1;
        RunA(rCount,1) = ifRunAdj(n,1);
        stateVAR = 2;
    end
    if stateVAR == 2 && ifRunAdj(n,2) == 1
        RunB(rCount,1) = ifRunAdj(n,1);
        rCount = rCount + 1;
        NorunA(NrCount,1) = ifRunAdj(n,1);
        stateVAR = 1;
    end
end

for n = length(ifRunAdj)
    if stateVAR == 1 && ifRunAdj(n, 2) == 1
        NorunB(NrCount,1) = ifRunAdj(n,1);
    end
    if stateVAR == 2 && ifRunAdj(n,2) == 2
        RunB(rCount,1) = ifRunAdj(n,1);
    end
  
end
    
