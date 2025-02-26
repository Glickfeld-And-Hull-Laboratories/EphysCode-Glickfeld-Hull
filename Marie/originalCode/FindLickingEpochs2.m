function [JuiceEpochLicks, LicksEpochsOnset] = FindLickingEpochs2(JuiceLicks)
detect = 5; %the pre-juice detection time is hardcoded in seconds
ILI = .21; %inter-lick interval
LicksEpochsOnset = []; %this is a list of epoch onset times regardless of trial strucutre
%JuiceEpochLicks = similar to JuiceLicks but has only epoch onsets, not all
%licks, in column 2
k = 1;
for n =2:length(JuiceLicks)
    c = 1;
    trialLicks = JuiceLicks{n,2};
    if length(trialLicks) > 3 %check the first lick if there are at least three licks
    if (trialLicks(1) > JuiceLicks{n,1}-(detect-1)) % if first lick in trial is more than 1 second after detection starts
        if trialLicks(3) - trialLicks(2) < ILI & trialLicks(2)-trialLicks(1) < ILI
            LicksEpochsOnset(k,1) = trialLicks(1);
            k = k+1;
            trialEpochs(c) = trialLicks(1);
            c = c + 1;
        end
    end
    end
    if length(trialLicks)>4 %check the second to nth lick if there are at least four licks  
    for i = 2:(length(trialLicks)-2)
        if trialLicks(i)-trialLicks(i-1) > 1
            if trialLicks(i+2)-trialLicks(i+1) < ILI & trialLicks(i+1)-trialLicks(i) < ILI
                LicksEpochOnset(k,1) = trialLicks(i);
                k = k + 1;
                trialEpochs(c) = trialLicks(i);
                c = c + 1;
            end
        end
    end
    end
    JuiceEpochLicks{n,1} = JuiceLicks{n,1};
    if exist('trialEpochs')
    JuiceEpochLicks{n,2} = trialEpochs;
    else
    JuiceEpochLicks{n,2} = NaN;
    end
    clear trialEpochs
end
end
