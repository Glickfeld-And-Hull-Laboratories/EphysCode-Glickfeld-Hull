%% Delete CatGT duplicated spike bin files - SMG 9/28/2026
%  After running CatGT to align stimulus and behavior signals to the neural
%  data, CatGT outputs a copy of the spiking data. To save space on
%  Isilon, we don't want many copies of the same data. 
%  This function deletes the CatGT duplicated .bin file.
%  
%  This function is designed to be placed within your runCatGT.m function
%  so that the duplicate file is deleted immediately following creation. The 
%  'path' string input is the same as the output directory you gave to 
%  CatGT.
%
%   Inputs
%       path            - (string) path to the directory that contains the CatGT output folder
%
%
% ==== THIS FUNCTION IS SHARED ACROSS THE LAB ====
%  PLEASE **DO NOT** MAKE A COPY OF THIS FUNCTION WITHOUT
%  RENAMING IT 
%

function deleteDuplicateDataFromCatGTOutput(path)
    
    patterns = {'*ap.bin'};   % look for spike bin files
    
    catDirs = dir(fullfile(path, 'catgt*'));
    catDirs = catDirs([catDirs.isdir]);
    
    for i = 1:numel(catDirs)
        root = fullfile(catDirs(i).folder, catDirs(i).name);
        for p = 1:numel(patterns)
            files = dir(fullfile(root, '**', patterns{p}));
            for f = files'
                delete(fullfile(f.folder, f.name));
                fprintf('%s deleted. From %s\n', f.name, f.folder);
            end
        end
    end
end