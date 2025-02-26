%Fr at time of change from run/notrun to other state.
function [STOPtoRUN, RUNtoSTOP] = FindRunChangePoints(ifRunAdj);
m = 1;
p = 1;
for n = 1:(length(ifRunAdj)-1)
    k = n+1
    if ifRunAdj(n,2)== 1
        if ifRunAdj(k, 2) == 2
            STOPtoRUN(m,1) = ifRunAdj(k, 1);
            m = m+1;
        end
    end
    
    if ifRunAdj(n,2) == 2
        if ifRunAdj(k, 2) == 1
           RUNtoSTOP(p,1) = ifRunAdj(k, 1);
            p = p+1;
        end
    end
end