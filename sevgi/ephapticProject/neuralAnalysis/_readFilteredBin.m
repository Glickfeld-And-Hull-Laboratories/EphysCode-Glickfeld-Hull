% =========================================================
% Directly transferred from DemoReadSGLXData.m (SpikeGLX_Datafile_Tools https://billkarsh.github.io/SpikeGLX/#post-processing-tools)
% Updated by SO Hull lab 1/19/2023: to read multi samples at once to speed up the raw data reading
% samples: is array now, holding the start positions for multi-read
% bestCh: reads only best channel
% =========================================================
% Read nSamp timepoints from the binary file, starting
% at timepoint offset samples(i). The returned array has
% dimensions [nChan,nSamp]. Note that nSamp returned
% is the lesser of: {nSamp, timepoints available}.
%
% IMPORTANT: samples must be array of start positions and nSamp must be integer.
%
function dataArray = readFilteredBin(samples, nSamp, chOfInterest, fileSizeBytes, binName, path)
    globals;
    sizeOfSingle = 4; % Filtered bin file is in the single data type format
    %nChan = str2double(meta.nSavedChans);

    nFileSamp = str2double(fileSizeBytes) / (sizeOfSingle * NUM_OF_CHANNELS);
    
    sizeA = [NUM_OF_CHANNELS, nSamp];
    
    dataArray = NaN(length(samples),nSamp);
    fid = fopen(fullfile(path, binName), 'rb');
    for i=1:length(samples)                
        samples(i) = max(samples(i), 0);
        nSamp = min(nSamp, nFileSamp - samples(i));

        fseek(fid, samples(i) * sizeOfSingle * NUM_OF_CHANNELS, 'bof');
        tempData = fread(fid, sizeA, 'single=>double');
        dataArray(i,1:size(tempData,2)) = tempData(chOfInterest, :);
    end
    fclose(fid);
end % ReadBin