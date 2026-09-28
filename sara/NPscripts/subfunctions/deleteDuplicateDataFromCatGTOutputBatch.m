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

    % One recursive scan for every *ap.bin under parentPath, at any depth
    files = dir(fullfile(parentPath, '**', '*ap.bin'));
    files = files(~[files.isdir]);
    
    for f = files'
        % Only delete if some folder in the file's path starts with 'catgt'
        parts = strsplit(f.folder, filesep);
        if ~any(startsWith(lower(parts), 'catgt'))
            continue
        end
    
        target = fullfile(f.folder, f.name);
        delete(target);
        if ~isfile(target)
            fprintf('%s deleted. From %s\n', f.name, f.folder);
        else
            fprintf('%s COULD NOT be deleted. From %s\n', f.name, f.folder);
        end
    end

end