% clear all
% arduinosetup()
%follow steps here: https://docs.arduino.cc/tutorials/uno-rev3/matlab-pwm-blink/

clear all
a = arduino();

trials = 400;
iti = [15 30];
rewardDur = .005;
UnexpBoo = 1;
    UnexpNum = 2; %number of trials in a block of 20 that will be unexpected;
OmitBoo = 1;
    OmitNum = 2;  %number of trials in a block of 20 that will be omitted trials

    
%calculate trials for unexpected reward, omitted reward, and cc trials
trialsInd = [1:trials];
if UnexpBoo == 1
rUnexp = round(rand(round(trials/20), UnexpNum)*100/5);  %block size = 20 trials;
for n = 1:length(rUnexp)
        if rUnexp(n,1) == rUnexp(n,2)
            if rUnexp(n,2) < 20
                rUnexp(n,2) = rUnexp(n,2) + 1;
            else
                rUnexp(n,2) = rUnexp(n,2) - 1;
            end
        end
end
rUnexp = rUnexp+[0:20:(length(rUnexp)-1)*20].';
rUnexp = sort([rUnexp(:,1); rUnexp(:,2)]);
else
    rUnexp = [];
end
if OmitBoo == 1
availableTrials = setdiff(trialsInd, rUnexp);
rOmit = [];
for n = 1:round(trials/20)
    availTrialsThisBlock = availableTrials(availableTrials >= (n-1)*20+1 & availableTrials <= n*20);
    rOmit = [rOmit; availTrialsThisBlock(randperm((20-2), 2)).'];
end
else
    rOmit = [];
end
    rOmit = sort(rOmit);
    rCC = setdiff(trialsInd, rUnexp);
    rCC = setdiff(rCC, rOmit);
    % test non-overlapping
    if isempty(intersect(intersect(rUnexp, rOmit), rOmit)) & isempty(intersect(rCC, rUnexp)) & isempty(intersect(rUnexp, rOmit))
        if length(rUnexp) + length(rOmit) + length(rUnexp) == trials
            fprintf('\n hello \n');
        end
    end
    
    
counterCC = 0;
counterOmit = 0;
counterUnexpected = 0;
for trial = 1:trials
    r = iti(1) + (iti(2)-iti(1))*rand; %determine length of this trial
    if ~ismember(rUnexp)     %if trial is not unexpected trial
    for n = 1:13
writePWMVoltage(a, 'D11', 0);
    pause(.011);
writePWMVoltage(a, 'D11', 5);
pause(.005);
end
writePWMVoltage(a, 'D11', 0);
writeDigitalPin(a,'D12',1);
    pause(rewardDur);
writeDigitalPin(a,'D12',0);
pause(r);
    else        %if trial is unexpected trial
   pause (0.5)     %pause while it would have played laser
writePWMVoltage(a, 'D11', 0);
writeDigitalPin(a,'D12',1);
    pause(rewardDur);
writeDigitalPin(a,'D12',0);
pause(r);
end
end

%run water out