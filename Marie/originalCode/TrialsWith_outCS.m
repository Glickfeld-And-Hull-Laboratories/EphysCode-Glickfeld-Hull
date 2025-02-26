function [TrialsSpike, TrialsNoSpike] = TrialsWith_outCS(Trials, struct, CSindex, WindowTrialTime)
%[.69 .82]
[TrialsSpike, MaskFire] = TrialsWithSpike2(CSindex, struct, Trials, WindowTrialTime);
TrialsNoSpike = Trials(logical(abs(MaskFire)-1));
end


