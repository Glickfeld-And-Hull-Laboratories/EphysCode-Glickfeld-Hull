
function [exptStruct] = iniExptStruct(iexp);

    ds = 'npxExptList';
    eval(ds);

    exptStruct.mouse      = expt(iexp).mouse;
    exptStruct.date       = expt(iexp).date;
    exptStruct.exptType   = expt(iexp).exptType;
    if length(expt(iexp).exptTime) == 1
        exptStruct.exptTime   = cell2mat(expt(iexp).exptTime);
    else
        exptStruct.exptTime   = expt(iexp).exptTime;
    end
    exptStruct.depth      = expt(iexp).depth;
    exptStruct.loc        = expt(iexp).loc;
    exptStruct.exptType   = expt(iexp).exptType;
    exptStruct.eyetrack   = expt(iexp).eyetrack;    
    exptStruct.wheeltrack = expt(iexp).wheeltrack;   
end