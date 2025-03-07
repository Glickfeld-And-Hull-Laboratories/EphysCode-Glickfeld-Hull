function [Trial1, Trial2] = TrialDivide(Trigger, Events, xmin1, xmax1, xmin2, xmax2, ExclusiveBoo)
%Divide a trigger train into trigger where something happens and trigger
%where something else happens (or nothing happens)
%Trial1- event happens between xmin1 & xmin2
%Trial2- it doesn't (xmin2 = NaN and ExclusiveBoo = 0);

if isnan(xmin2)
c1 = 1;
c2 = 1;
for n = 1:length(Trigger)
    if find((Trigger(n) + xmin1) < Events & Events < (Trigger(n) + xmax1))
        Trial1(c1) = Trigger(n);
        c1 = c1+1;
    else
        Trial2(c2) = Trigger(n);
        c2 = c2 + 1;
    end
end
Trial1 = rmmissing(Trial1).';
Trial2 = rmmissing(Trial2).';
end

if ~isnan(xmin2) && ExclusiveBoo == 1
    c1 = 1;
c2 = 1;
for n = 1:length(Trigger)
    if find((Trigger(n) + xmin1) < Events & Events < (Trigger(n) + xmax1))
        Trial1(c1) = Trigger(n);
        c1 = c1+1;
    elseif find((Trigger(n) + xmin2) < Events & Events < (Trigger(n) + xmax2))
        Trial2(c2) = Trigger(n);
        c2 = c2 + 1;
    end
end
Trial1 = rmmissing(Trial1).';
Trial2 = rmmissing(Trial2).';
end
        