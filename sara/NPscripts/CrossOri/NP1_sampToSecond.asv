% Convert .npy file from sample times to seconds. This is necessary prior
% to running TPrime for syncing.

% Ask user for binary file
[binName,path] = uigetfile('*.bin', 'Select Binary File');

% Parse the corresponding metafile
meta = SGLX_readMeta.ReadMeta(binName, path); % Function downloaded from open source code: https://github.com/jenniferColonell/SpikeGLX_Datafile_Tools/blob/main/README.md

% Get sample rate
srate = str2double(meta.imSampRate);

% Divide the rate into each array element



% Save times


% Get first one second of data
nSamp = floor(1.0 * SGLX_readMeta.SampRate(meta));
dataArray = SGLX_readMeta.ReadBin(1, nSamp, meta, binName, path);
dataType = 'A';         %set to 'A' for analog, 'D' for digital data

