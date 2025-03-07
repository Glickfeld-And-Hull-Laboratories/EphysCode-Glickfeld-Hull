% go to folder of interest!!!  & set these variables

function [UnitStruct] = FullBinaryPersuitImport()

% Changed this section to ask for .meta file instead of .bin file MEH
% 12/0/21
% Ask user for binary file

if length(dir('*.meta')) ~= 1
    [binName,path] = uigetfile('*.meta', 'Select Meta File');
end
if length(dir('*.meta')) == 1
  binfolder = dir('*.meta');
  binName = binfolder(1).name;
  path = binfolder(1).folder;
end
tic 

% Parse the corresponding metafile
meta = ReadMeta(binName, path);


ts = readNPY('spike_times.npy');           %convert all spike times from python to matlab
SpikeTimeSec = double(ts)/SampRate(meta);              % create vector of all spike timestamps
cl = double(readNPY('spike_templates.npy'));           % create vector designating cluster for each ts
if size(SpikeTimeSec) ~= size(cl);                       % check that vector sizes are equal
       printf('warning: spike_times and spike_clusters are unequal')
end
writeNPY(SpikeTimeSec, 'spike_times_sec.npy');
%need to write spiketimesec to an .npy file

unitList = unique(cl);

% find vectors of spiketimes of each unit and make structure together with
% the name/number of the unit
for j = 1:length(unitList)
    unit = unitList(j);
    k = find(cl(:,1) == unit);                     % create logical vector for cluster of interest THIS IS WHERE YOU ARE!!!!!!!!!!! somehow causing problems when it switches to double digits. maybe convert srting back to double somehow?? & create vector of indices for clusters of interest
    unit_timestamps = SpikeTimeSec(k);                      % create a vector of timestamps for cluster of interest
    %unit_amplitudes = amp(k);
    %strUnit = string(unit);
    %eval('strUnit = unit_timestamps');
    UnitStruct(j).unitID = unit;
    UnitStruct(j).timestamps = unit_timestamps;
    %UnitStruct(j).amplitudes = unit_amplitudes;
end



end %SamptToSec


% =========================================================
% Parse ini file returning a structure whose field names
% are the metadata left-hand-side tags, and whose right-
% hand-side values are MATLAB strings. We remove any
% leading '~' characters from tags because MATLAB uses
% '~' as an operator.
%
% If you're unfamiliar with structures, the benefit
% is that after calling this function you can refer
% to metafile items by name. For example:
%
%   meta.fileCreateTime  // file create date and time
%   meta.nSavedChans     // channels per timepoint
%
% All of the values are MATLAB strings, but you can
% obtain a numeric value using str2double(meta.nSavedChans).
% More complicated parsing of values is demonstrated in the
% utility functions below.
%
function [meta] = ReadMeta(binName, path)

    % Create the matching metafile name
    [dumPath,name,dumExt] = fileparts(binName);
    metaName = strcat(name, '.meta');

    % Parse ini file into cell entries C{1}{i} = C{2}{i}
    fid = fopen(fullfile(path, metaName), 'r');
% -------------------------------------------------------------
%    Need 'BufSize' adjustment for MATLAB earlier than 2014
%    C = textscan(fid, '%[^=] = %[^\r\n]', 'BufSize', 32768);
    C = textscan(fid, '%[^=] = %[^\r\n]');
% -------------------------------------------------------------
    fclose(fid);

    % New empty struct
    meta = struct();

    % Convert each cell entry into a struct entry
    for i = 1:length(C{1})
        tag = C{1}{i};
        if tag(1) == '~'
            % remake tag excluding first character
            tag = sprintf('%s', tag(2:end));
        end
        meta = setfield(meta, tag, C{2}{i});
    end
    
end % ReadMeta



% =========================================================
% Return sample rate as double.
%
function srate = SampRate(meta)
    if strcmp(meta.typeThis, 'imec')
        srate = str2double(meta.imSampRate);
    else
        srate = str2double(meta.niSampRate);
    end
end % SampRate