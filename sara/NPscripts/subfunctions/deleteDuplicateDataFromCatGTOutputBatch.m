%% Delete CatGT duplicated spike bin files - SMG 9/28/2026
%  After running CatGT to align stimulus and behavior signals to the neural
%  data, CatGT outputs a copy of the spiking data. To save space on
%  Isilon, we don't want many copies of the same data. 
%  This function deletes the CatGT duplicated .bin file.
%  
%  This function is designed to be used once to batch search a parent
%  directory to look for all CatGT folders and delete corresponding ap.bin
%  spiking files.

function deleteDuplicateDataFromCatGTOutputBatch(parentPath)
    fprintf('Scanning %s\n', parentPath);
    scanDir(parentPath);
    fprintf('Done.\n');
end

function scanDir(folder)
    
    entries = dir(folder);
    entries = entries([entries.isdir] & ~ismember({entries.name}, {'.', '..'}));
    
    for k = 1:numel(entries)
        sub = fullfile(entries(k).folder, entries(k).name);
    
        if startsWith(entries(k).name, 'catgt', 'IgnoreCase', true)
            fprintf('Found %s\n', sub);
            files = dir(fullfile(sub, '**', '*ap.bin'));
            files = files(~[files.isdir]);
            for f = files'
                target = fullfile(f.folder, f.name);
                delete(target);
                if ~isfile(target)
                    fprintf('%s deleted. From %s\n', f.name, f.folder);
                else
                    fprintf('%s COULD NOT be deleted. From %s\n', f.name, f.folder);
                end
            end
        else
            scanDir(sub);   % keep looking for catgt folders deeper
        end
    end

end