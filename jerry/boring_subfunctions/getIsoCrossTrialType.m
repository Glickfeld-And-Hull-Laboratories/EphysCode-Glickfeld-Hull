function trialTypes = getIsoCrossTrialType(cenDir,surDir,doCen,doSur,figBool)
% Uses mWorks trial info to assign correct stimulus type to each trial.
% Currently bruteforcing optiions, but can be coded to be adaptive if more
% trial types exist. 
if nargin < 5
    figBool = false;
end

v1 = [0;90;1;0]; % small only, 0 deg
v2 = [90;0;1;0]; % small only, 90 deg
v3 = [0;90;1;1]; % cross, center at 0 deg
v4 = [90;0;1;1]; % cross, center at 90 deg
v5 = [90;0;0;1]; % iso (large only), all at 0 deg
v6 = [0;90;0;1]; % iso (large only), all at 90 deg

options = [v1 v2 v3 v4 v5 v6];
results = ["sma0" "sma90" "crs0" "crs90" "iso0" "iso90"];

trialsMat = vertcat(cenDir,surDir,doCen,doSur);
if class(trialsMat) == "cell"
    trialsMat = cell2mat(trialsMat);
end

trialsMat(trialsMat == 180) = 0;

[sz1 sz2] = size(trialsMat);
trialTypes = results(arrayfun(@(c) find(all(trialsMat(:,c)==options,1)),1:sz2));

if figBool == true
    figure;
    histogram(categorical(trialTypes));
end

end