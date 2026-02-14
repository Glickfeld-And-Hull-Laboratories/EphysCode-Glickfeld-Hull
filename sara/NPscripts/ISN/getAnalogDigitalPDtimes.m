

% The catGT and Tprime commands I ran for the test run with both analog and
% digital input for photodiode (didn't need stim on info)

cmd1 = 'CatGT -dir=//duhs-user-nc1.dhe.duke.edu/dusom_glickfeldlab/All_staff/home/sara/Data/neuropixel/260102_analogPDtest -run=ixxxx-260102-test-analogPDinput -g=0 -t=0 -ni -prb=0 -xd=0,0,1,0,0 -xd=0,0,1,5,0 -dest=//duhs-user-nc1.dhe.duke.edu/dusom_glickfeldlab/All_staff/home/sara/Analysis/Neuropixel/260102_analogPDtest';
cmd2 = 'CatGT -dir=//duhs-user-nc1.dhe.duke.edu/dusom_glickfeldlab/All_staff/home/sara/Data/neuropixel/260102_analogPDtest -run=ixxxx-260102-test-analogPDinput -g=0 -t=0 -ap -prb=0 -xd=2,0,-1,6,500 -no_auto_sync -dest=//duhs-user-nc1.dhe.duke.edu/dusom_glickfeldlab/All_staff/home/sara/Analysis/Neuropixel/260102_analogPDtest';    
cd('C:\Users\smg92\Desktop\CatGTWinApp4.3\CatGT-win');
system(cmd1);
system(cmd2);

% analog command -- never got this to work
cmd1 = 'CatGT -dir=//duhs-user-nc1.dhe.duke.edu/dusom_glickfeldlab/All_staff/home/sara/Data/neuropixel/260102_analogPDtest -run=ixxxx-260102-test-analogPDinput -g=0 -t=0 -ni -prb=0 -xa=0,0,1,0.5,0.1,0 -dest=//duhs-user-nc1.dhe.duke.edu/dusom_glickfeldlab/All_staff/home/sara/Analysis/Neuropixel/260102_analogPDtest';
cd('C:\Users\smg92\Desktop\CatGTWinApp4.3\CatGT-win');
system(cmd1);

% Tprime command
cmd1 = 'TPrime -syncperiod=1.000000 -tostream=\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\sara\Analysis\Neuropixel\260102_analogPDtest\catgt_ixxxx-260102-test-analogPDinput_g0\ixxxx-260102-test-analogPDinput_g0_tcat.imec0.ap.xd_384_6_500.txt -fromstream=1,\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\sara\Analysis\Neuropixel\260102_analogPDtest\catgt_ixxxx-260102-test-analogPDinput_g0\ixxxx-260102-test-analogPDinput_g0_tcat.nidq.xd_1_0_500.txt -events=1,\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\sara\Analysis\Neuropixel\260102_analogPDtest\catgt_ixxxx-260102-test-analogPDinput_g0\ixxxx-260102-test-analogPDinput_g0_tcat.nidq.xd_1_5_0.txt,\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\sara\Analysis\Neuropixel\260102_analogPDtest\260102_analogPDtest_photodiodeSyncDigital.txt ';
cd('C:\Users\smg92\Desktop\TPrime-win');
system(cmd1);




% Memory-map the binary file
m = memmapfile('ixxxx-260102-test-analogPDinput2_g0_t0.nidq.bin','Format','int16');  % adjust 'int16' if needed
% Access the data
data = m.Data;  % now you can index normally
% Determine number of channels
Nchan = 2;  % analog + digital
% Truncate extra samples at end so it's divisible by Nchan
Nsamps = floor(length(data)/Nchan);
data = data(1:Nsamps*Nchan);
% Reshape into samples x channels
data = reshape(data, Nchan, []).';
analogData = data(:,1).* (5 / 32768);   % analog channel
digitalData = data(:,2);  % digital channel


th = 1.2;
leading_edges = find(analogData(1:end-1) < th & analogData(2:end) >= th) + 1;
minISI = round(1.5 * 1e6);   % 0.5s gap separates stimuli
leadingEdges_ana = leading_edges(1);
for i = 2:length(leading_edges)
    if leading_edges(i) - leadingEdges_ana(end) > minISI
        leadingEdges_ana(end+1) = leading_edges(i);
    end
end


threshold = 235;%110;
%Find indices where the signal rises past the threshold
ttl = digitalData > threshold;
risingEdges = find(diff(ttl) == 1);

minISI = round(0.5 * 1e6);   % 0.5s gap separates stimuli
leadingEdges_dig = risingEdges([true; diff(risingEdges) > minISI]);


analogOn = leadingEdges_ana(2:end-1);  %ixxxx-260102-test-analogPDinput2
digitalOn = leadingEdges_dig(2:end-2)'; %ixxxx-260102-test-analogPDinput2
% analogOn = leadingEdges_ana; %ixxxx-260102-test-analogPDinput
% digitalOn = leadingEdges_dig'; %ixxxx-260102-test-analogPDinput

sampDiff = analogOn - digitalOn;

figure; 
    subplot 421
        histogram(diff(analogOn),100)
        subtitle('diff analogOn')
    subplot 422
        histogram(diff(digitalOn),100)
        subtitle('diff digitalOn')
    subplot 423
        histogram(sampDiff,100)
        avgDiff = mean(sampDiff);
        stdDiff = std(sampDiff);
        subtitle(['avgDiff ' num2str(round(avgDiff/10^3,3)) 'ms,  stdDiff ' num2str(round(stdDiff/10^3,3)) 'ms'])
    subplot 424
        scatter(1:length(analogOn),sampDiff)
        subtitle('look at sampDiff across time')


print(fullfile(['\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\sara\x_temp\'], ['photodiodeAnalogDigitalTest_sampDiff_test1.pdf']), '-dpdf','-fillpage')






figure;
    subplot 411
        plot(analogData(280000000:310000000)); hold on
        ylim([-1 4])
        yline(1.2,'g--'); % thresh-hyst
    subplot 412
        plot(digitalData(280000000:310000000)); hold on
        yline(110,'g--'); % thresh-hyst
    subplot 413
        plot(analogData(1000000:10000000)); hold on
        ylim([-1 4])
        yline(1.2,'g--'); % thresh-hyst
    subplot 414
        plot(digitalData(1000000:10000000)); hold on
        yline(110,'g--'); % thresh-hyst     


figure;
    subplot 411
        plot(analogData); hold on
        xlim([221100000 221500000]);
        ylim([-1 4])
        for il = 1:length(analogOn)
            xline(analogOn(il),'r--'); % threshold
        end
        yline(1.2,'g--'); % thresh-hyst
    subplot 412
        plot(digitalData); hold on
        xlim([221100000 221500000]);
        for il = 1:length(digitalOn)
            xline(digitalOn(il),'r--'); % threshold
        end
        yline(235,'g--'); % thresh-hyst


     print(fullfile(['\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\sara\x_temp\'], ['photodiodeAnalogDigitalTest_viewSignals_test1_smallwindow.pdf']), '-dpdf','-fillpage')




figure;
    subplot 411
        plot(analogData); hold on
        xlim([1000000 10000000]);
        ylim([-1 4])
        for il = 1:length(leadingEdges_ana)
            xline(leadingEdges_ana(il),'r--'); % threshold
        end
        yline(1.2,'g--'); % thresh-hyst
    subplot 412
        plot(digitalData); hold on
        xlim([1000000 10000000]);
        for il = 1:length(leadingEdges_dig)
            xline(leadingEdges_dig(il),'r--'); % threshold
        end
        yline(230,'g--'); % thresh-hyst



figure;
    subplot 221;
        scatter(leadingEdges_dig,1:length(leadingEdges_dig)); hold on
        scatter(leadingEdges_ana,1:length(leadingEdges_ana))
     subplot 222;
        scatter(digitalOn,1:length(digitalOn)); hold on
        scatter(analogOn,1:length(analogOn))    
    subplot 223; 
        histogram(diff(analogOn),50); 
        subtitle('analogOn')
    subplot 224; 
        histogram(diff(digitalOn),50);
        subtitle('digitalOn')


