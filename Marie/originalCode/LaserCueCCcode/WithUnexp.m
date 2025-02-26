% clear all
% arduinosetup()
%follow steps here: https://docs.arduino.cc/tutorials/uno-rev3/matlab-pwm-blink/

clear all
a = arduino();

%if you would like unexpected trials:
rUnexp = round(rand(round(trials/20), 2)*100/5);
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


trials = 400;
iti = [15 30];
rewardDur = .005;

for trial = 1:trials
        r = iti(1) + (iti(2)-iti(1))*rand;
    if ~ismember(trial, rUnexp) %trial is not an unexpected trial
for n = 1:10
writePWMVoltage(a, 'D11', 0);
    pause(.021);
writePWMVoltage(a, 'D11', 5);
pause(.010);
end
writePWMVoltage(a, 'D11', 0);
writeDigitalPin(a,'D12',1);
    pause(rewardDur);
writeDigitalPin(a,'D12',0);
pause(r);
    else
     for n = 1:10
pause(.5);
end
writePWMVoltage(a, 'D11', 0);
writeDigitalPin(a,'D12',1);
    pause(rewardDur);
writeDigitalPin(a,'D12',0);
pause(r);   
    end
end

%run water out