clear all

trials = 400;
iti = [15 30];
SolenoidOn = false;
a = arduino();
writeDigitalPin(a,'D7',0);
writeDigitalPin(a,'D8',0);
writeDigitalPin(a,'D4',0);
writeDigitalPin(a,'D5',0);
fprintf('Ready \n')
%pause(30);

for ii = 1:(trials)
    
    r = iti(1) + (iti(2)-iti(1))*rand;
    %if mod(ii,2) == 1
        if SolenoidOn
            writeDigitalPin(a,'D7',0);
            writeDigitalPin(a,'D8',0);
            SolenoidOn = false;
%         %else
%             writeDigitalPin(a,'D7',1);
%             writeDigitalPin(a,'D8',1);
%             SolenoidOn = true;
%         end
    end
    pause(r/2)
    writeDigitalPin(a,'D4',1);
    writeDigitalPin(a,'D5',1);
    pause(0.03);
    writeDigitalPin(a,'D5',0);
    writeDigitalPin(a,'D4',0);
    pause(r/2)
    fprintf('waiting... end of trial %d for %4.2f secs \n',ii,r)

end

fprintf('Pause start \n')
writeDigitalPin(a,'D7',1);
writeDigitalPin(a,'D8',1);
SolenoidOn = true;
pause(60*40)

fprintf('Pause end \n')
writeDigitalPin(a,'D7',0);
writeDigitalPin(a,'D8',0);
SolenoidOn = false;
pause(10)

for ii = ((trials/2)+1):trials
    
    r = iti(1) + (iti(2)-iti(1))*rand;
    if mod(ii,2) == 1
        if SolenoidOn
            writeDigitalPin(a,'D7',0);
            writeDigitalPin(a,'D8',0);
            SolenoidOn = false;
        else
            writeDigitalPin(a,'D7',1);
            writeDigitalPin(a,'D8',1);
            SolenoidOn = true;
        end
    end
    pause(r/2)
    writeDigitalPin(a,'D4',1);
    writeDigitalPin(a,'D5',1);
    pause(0.03);
    writeDigitalPin(a,'D5',0);
    writeDigitalPin(a,'D4',0);
    pause(r/2)
    fprintf('waiting... end of trial %d for %4.2f secs \n',ii,r)

end

writeDigitalPin(a,'D7',1);
writeDigitalPin(a,'D8',1);