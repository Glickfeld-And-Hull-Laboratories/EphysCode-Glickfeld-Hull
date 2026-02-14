
function [exptStruct] = createExptStruct_tutorial(iexp);

    ds = 'NP_CrossOri_RandDirRandPhase_exptlist';
    eval(ds)

    exptStruct.mouse     = expt(iexp).mouse;
    exptStruct.date      = expt(iexp).date;

    if isfield(expt(iexp), 'layerTime')     % Check if 'layerTime' exists before assigning
        exptStruct.layerTime = expt(iexp).layerTime;
    end
    
    exptStruct.exptTime = expt(iexp).exptTime;
    exptStruct.depth     = expt(iexp).z;
    exptStruct.loc       = expt(iexp).saveLoc;

end