function readDigitalChannels()

    global dw digitalChList pathToRecFolder
    addpath('../lib/');
    niBinFiles = dir([pathToRecFolder '*nidq.bin']);
    niBinFile = niBinFiles(1);

    % Parse the corresponding metafile
    meta = readMeta(niBinFile.name, pathToRecFolder);

    % Get first one second of data
    nSamp = floor(1.0 * samplingRate(meta));
    dataArray = readBin(0, nSamp, meta, niBinFile.name, pathToRecFolder);
    
    % **************** DIGITAL READ OUT *********************
    dataArrayDigital = extractDigital(dataArray, meta, dw, digitalChList);
    % for i = 1:numel(dLineList)
    %     figure
    %     plot(dataArrayDigital(i,:));    
    %     ylim([0 1.2]);
    % end
    fs = str2num(meta.niSampRate);
    x = 1/fs:1/fs:3884.634918;
    plot(x(1:50000000),dataArrayDigital(2,1:50000000))

    %********** DIGITAL READ OUT *********************

    %save('NI_AuxChannels','dataArrayDigital'); %'dataArrayAnalog',
end