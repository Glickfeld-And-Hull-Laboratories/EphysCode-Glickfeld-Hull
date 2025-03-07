counter = 1;
for n = 1:length(SumSt)
for m = n:length(SumSt)
if ~(m==n)
%if SumSt(n).unitIDdrive == SumSt(m).unitIDdrive
%if SumSt(n).unitIDfollow == SumSt(m).unitIDfollow
if SumSt(n).unitID == SumSt(m).unitID
if strcmp(SumSt(n).recordingID, SumSt(m).recordingID)
mn(counter).m = m;
mn(counter).n = n;
counter = counter +1;
end
end
end
end
end
end