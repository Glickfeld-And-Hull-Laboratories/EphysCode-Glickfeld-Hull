function [LickOnsets, LickSecond, LickThird] = FindLickOnsets_epochs(licks, threshold, ili, minEpLength)
LickOnsets = [];
k = 1;
for i = 2:(length(licks)-2)
    if ((licks(i) - licks(i-1)) > threshold)
        LickOnsets(k).epochs = licks(i);
       p = i + 1;
       counter = 2;
       while licks(p) - licks(p-1) < ili
           LickOnsets(k).epochs(counter) = licks(p);
           p = p + 1;
           counter = counter + 1;
           if p > (length(licks))
               break
           end
       end  
         k = k+1;
    end
end
if ~isempty(LickOnsets)
epochCell = struct2cell(LickOnsets.').';
longEpochLogic = cellfun(@length, epochCell);
longEpochLogic = longEpochLogic >= minEpLength;
longEpoch = epochCell(longEpochLogic);
LickOnsets = cellfun(@(v)v(1), longEpoch);
if minEpLength > 1
LickSecond = cellfun(@(v)v(2), longEpoch);
else 
    LickSecond = NaN;
end
if minEpLength > 2
LickThird = cellfun(@(v)v(3), longEpoch);
else
    LickThird = NaN;
end
else
   LickSecond = NaN; 
   LickThird = NaN;
end
end

% for n = 1:length(RecordingList)
% RecordingList(n).LickOnsetsEpochs = FindLickOnsets_epochs([RecordingList(n).AllLicksAdj], .5, .21);
% RecordingList(n).onsets_only = cellfun(@(v)v(1), {RecordingList(n).LickOnsetsEpochs.epochs});
% epochCell = {RecordingList(n).LickOnsetsEpochs.epochs}.';
% longEpochLogic = cellfun(@length, epochCell);
% longEpochLogic = longEpochLogic > 2;
% longEpoch = epochCell(longEpochLogic);
% RecordingList(n).onsets_only_threeplus = cellfun(@(v)v(1), longEpoch);
% end