% clear all
% arduinosetup()
%follow steps here: https://docs.arduino.cc/tutorials/uno-rev3/matlab-pwm-blink/

clear all
a = arduino();

trials = 400;
iti = [15 30];
rewardDur = 0;
UnexpBoo = 0;  %make this zero if you want no unexpected trials
UnexpNum = 2; %number of trials in a block of 20 that will be unexpected; do not let UnexpNum + OmitNum > 20
OmitBoo = 1;        %make this zero if you want no omitted trials
OmitNum = 20;  %number of trials in a block of 20 that will be omitted trials; do not let UnexpNum + OmitNum > 20

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
        rOmit = [rOmit; availTrialsThisBlock(randperm(length(availTrialsThisBlock), OmitNum)).'];
        rOmit = sort(rOmit);      % print details of planned experiment
    end
else
    rOmit = [];
end

rCC = setdiff(trialsInd, rUnexp);
rCC = setdiff(rCC, rOmit);
% test non-overlapping
if isempty(intersect(intersect(rUnexp, rOmit), rOmit)) & isempty(intersect(rCC, rUnexp)) & isempty(intersect(rUnexp, rOmit))
    if length(rUnexp) + length(rOmit) + length(rCC) == trials
        fprintf(['\n iti ' num2str(iti(1)) ' to ' num2str(iti(2)) '\n']);
        fprintf(['\n' num2str((length(rUnexp)/trials)*100) '%% unexpected;  ' num2str((length(rOmit)/trials)*100) '%% omited \n']);
        fprintf(['\n Totals: ' num2str(length(rUnexp)) ' unexpected \n         ' num2str(length(rOmit)) ' omited \n         ' num2str(length(rCC)) ' paired \n']);
    end
end
writePWMVoltage(a, 'D10', 5);
 writePWMVoltage(a, 'D11', 0);
%end precalcluate trials

%run experiment - SAVE SPIKEGLX!!!!!!!
 writePWMVoltage(a, 'D10', 5);
 writePWMVoltage(a, 'D11', 0);
 pause(iti(1) + (iti(2)-iti(1))*rand);
counterCC = 0;
counterUnexp = 0;
counterOmit = 0;
    for trial = 1:trials
        r = iti(1) + (iti(2)-iti(1))*rand; %determine length of this trial
        if ~ismember(trial, rUnexp)  && ~ismember(trial, rOmit)   %if trial is not unexpected trial
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
            counterCC = counterCC + 1;
            pause(r);
        end
        if ismember(trial, rUnexp) %if trial is unexpected trial
            pause (0.5)     %pause while it would have played laser
            writePWMVoltage(a, 'D11', 0);
            writeDigitalPin(a,'D12',1);
            pause(rewardDur);
            writeDigitalPin(a,'D12',0);
            counterUnexp = counterUnexp + 1;
            pause(r);
        end
        if ismember(trial, rOmit) %if trial is omitted trial
            for n = 1:13
                writePWMVoltage(a, 'D11', 0);
                pause(.011);
                writePWMVoltage(a, 'D11', 5);
                pause(.005);
            end
            writePWMVoltage(a, 'D11', 0);
            writeDigitalPin(a,'D12',0); %don't deliver water
            pause(rewardDur);  % pause during what would have been reward delivery
            writeDigitalPin(a,'D12',0);
            counterOmit = counterOmit + 1;
            pause(r);
        end
        fprintf(['\n Totals: ' num2str(counterUnexp) ' unexpected \n         ' num2str(counterOmit) ' omited \n         ' num2str(counterCC) ' paired \n         ' num2str(counterCC + counterUnexp + counterOmit) ' total \n']);
    end
    % DID YOU START RECORDING YET?!?!?!?!
%end run experiment

 writePWMVoltage(a, 'D10', 0);

% %run water out
% writeDigitalPin(a,'D12',1)
% writeDigitalPin(a,'D12',0)
% 


for n = 1:13
                writePWMVoltage(a, 'D11', 0);
                pause(.011);
                writePWMVoltage(a, 'D11', 5);
                pause(.005);
            end
            writePWMVoltage(a, 'D11', 0);
            
%          
writeDigitalPin(a,'D12', 1);
pause(13);
writeDigitalPin(a,'D12',0);
% 
writePWMVoltage(a, 'D10', 0);


for n = 1:13
                writePWMVoltage(a, 'D11', 0);
                pause(.011);
                writePWMVoltage(a, 'D11', 5);
                pause(.005);
            end
            writePWMVoltage(a, 'D11', 0);
            writeDigitalPin(a,'D12',1);
            %pause(rewardDur);
            writeDigitalPin(a,'D12',0);
            
            