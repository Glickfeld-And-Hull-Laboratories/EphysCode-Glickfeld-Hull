

% The catGT and Tprime commands I ran for the test run with both analog and
% digital input for photodiode (didn't need stim on info)

cmd1 = 'CatGT -dir=//duhs-user-nc1.dhe.duke.edu/dusom_glickfeldlab/All_staff/home/sara/Data/neuropixel/260102_analogPDtest -run=ixxxx-260102-test-analogPDinput -g=0 -t=0 -ni -prb=0 -xd=2,0,0,0,0 -xd=2,0,0,5,0 -xa=2,0,0,1,2,25 -dest=//duhs-user-nc1.dhe.duke.edu/dusom_glickfeldlab/All_staff/home/sara/Analysis/Neuropixel/260102_analogPDtest';
cmd2 = 'CatGT -dir=//duhs-user-nc1.dhe.duke.edu/dusom_glickfeldlab/All_staff/home/sara/Data/neuropixel/260102_analogPDtest -run=ixxxx-260102-test-analogPDinput -g=0 -t=0 -ap -prb=0 -xd=2,0,-1,6,500 -no_auto_sync -dest=//duhs-user-nc1.dhe.duke.edu/dusom_glickfeldlab/All_staff/home/sara/Analysis/Neuropixel/260102_analogPDtest';    
cd('C:\Users\smg92\Desktop\CatGTWinApp4.3\CatGT-win');
system(cmd1);
system(cmd2);



% cmd1 = 'TPrime -syncperiod=1.000000 -tostream=\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\sara\Analysis\Neuropixel\260102_analogPDtest\catgt_ixxxx-260102-test-analogPDinput_g0\ixxxx-260102-test-analogPDinput_g0_tcat.imec0.ap.xd_384_6_500.txt -fromstream=1,\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\sara\Analysis\Neuropixel\260102_analogPDtest\catgt_ixxxx-260102-test-analogPDinput_g0\ixxxx-260102-test-analogPDinput_g0_tcat.nidq.xd_1_0_500.txt -events=1,\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\sara\Analysis\Neuropixel\260102_analogPDtest\catgt_ixxxx-260102-test-analogPDinput_g0\ixxxx-260102-test-analogPDinput_g0_tcat.nidq.xd_0_5_0.txt,\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\sara\Analysis\Neuropixel\260102_analogPDtest\260102_analogPDtest_photodiodeSyncDigital.txt -events=1,\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\sara\Analysis\Neuropixel\260102_analogPDtest\catgt_ixxxx-260102-test-analogPDinput_g0\ixxxx-260102-test-analogPDinput_g0_tcat.nidq.xa_0_25.txt,\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\sara\Analysis\Neuropixel\260102_analogPDtest\260102_analogPDtest_photodiodeSyncAnalog.txt';
% cd('C:\Users\smg92\Desktop\TPrime-win');
% system(cmd1);


function [leadingEdgesDigital,leadingEdgesAnalog] = getAnalogDigitalPDtimes(exptStruct)

    date = exptStruct.date;

    % Load stim on information (both MWorks signal and photodiode)
        cd (['\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\' exptStruct.loc '\Analysis\Neuropixel\' exptStruct.date])        % Move from KS_Output folder to ...\Analysis\neuropixel\date folder, where TPrime output is saved
        stimOnTimestampsPD_dig  = table2array(readtable([date '_photodiodeSync.txt']));
        stimOnTimestampsPD_ana  = table2array(readtable([date '_photodiodeSyncAnalog.txt']));

    % Lonely TTL removal
        lonelyThreshold = 0.05; % 50 ms
        timeDiffs       = abs(diff(stimOnTimestampsPD_dig));  % Compute pairwise differences efficiently
        hasNeighbor = [false; timeDiffs < lonelyThreshold] | [timeDiffs < lonelyThreshold; false]; % Identify indices where a close neighbor exists
        filteredPD = stimOnTimestampsPD_dig(hasNeighbor);   % Keep only timestamps that have a neighbor within 50 ms

    % Account for report of the monitor's refresh rate in the photodiode signal
        minInterval = 0.02; % Define a minimum separation threshold (should be longer than a refresh cycle but shorter than ISI)     
        leadingEdgesPD = filteredPD([true; diff(filteredPD) > minInterval]); % Extract the leading edges (first timestamp of each stimulus period)
        % [true; ...] ensures that the very first timestamp is always included because otherwise diff() returns an array that is one element shorter than the original.

    % Find stimulus blocks and separate stim on timestamps
        threshold       = 30; % Time gap to define a break (in seconds)
        breakIndices    = find(diff(leadingEdgesPD) > threshold); % Find the indices where the gap between timestamps exceeds the threshold
        stimBlocks      = cell(length(breakIndices) + 1, 1); % Initialize a cell array to store stimulus blocks
     
        startIdx = 1;
        for i = 1:length(breakIndices) % Extract stimulus blocks
            endIdx          = breakIndices(i);
            stimBlocks{i}   = leadingEdgesPD(startIdx:endIdx);
            startIdx        = endIdx + 1;
        end
        stimBlocks{end} = leadingEdgesPD(startIdx:end); % Store the last block
 


end


