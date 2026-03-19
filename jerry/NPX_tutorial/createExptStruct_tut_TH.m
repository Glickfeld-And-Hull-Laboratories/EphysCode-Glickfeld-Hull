
function [exptStruct] = createExptStruct_tutorial(iexp);

    ds = 'NP_16dir_tut_exptlist_TH';
    eval(ds);

    exptStruct.mouse     = expt(iexp).mouse;
    exptStruct.date      = expt(iexp).date;
    exptStruct.exptTime  = expt(iexp).exptTime;
    exptStruct.depth     = expt(iexp).z;
    exptStruct.loc       = expt(iexp).saveLoc;
end