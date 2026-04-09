function replace_in_matlab_files(rootDir,oldWord,newWord)
% REPLACE_IN_MATLAB_FILES Recursively replaces a word in all .m files
%
% Usage:
%   replace_in_matlab_files('/path/to/scripts', 'repositories', 'Repositories')

    if nargin < 3
        rootDir = pwd;          % Default: current directory
        oldWord = 'repositories';
        newWord = 'Repositories';
    end

    % Get all .m files recursively
    fileList = dir(fullfile(rootDir, '**', '*.m'));

    changedCount = 0;
    skippedCount = 0;

    fprintf('Searching in: %s\n\n', rootDir);

    for i = 1:length(fileList)
        filepath = fullfile(fileList(i).folder, fileList(i).name);

        % Skip this script itself
        if strcmp(fileList(i).name, 'replace_in_matlab_files.m')
            continue;
        end

        try
            % Read file content
            fid = fopen(filepath, 'r', 'n', 'UTF-8');
            if fid == -1
                fprintf('  WARNING: Could not open %s\n', filepath);
                skippedCount = skippedCount + 1;
                continue;
            end
            content = fread(fid, '*char')';
            fclose(fid);

            % Check if old word exists
            if contains(content, oldWord)
                % Replace and write back
                newContent = strrep(content, oldWord, newWord);
                fid = fopen(filepath, 'w', 'n', 'UTF-8');
                if fid == -1
                    fprintf('  WARNING: Could not write %s\n', filepath);
                    skippedCount = skippedCount + 1;
                    continue;
                end
                fwrite(fid, newContent, 'char');
                fclose(fid);

                % Count replacements
                numReplacements = length(strfind(content, oldWord));
                fprintf('  UPDATED: %s  (%d replacement(s))\n', filepath, numReplacements);
                changedCount = changedCount + 1;
            end

        catch e
            fprintf('  ERROR in %s: %s\n', filepath, e.message);
            skippedCount = skippedCount + 1;
        end
    end

    % Summary
    fprintf('\n--- Summary ---\n');
    fprintf('Files updated : %d\n', changedCount);
    fprintf('Files skipped : %d\n', skippedCount);
    fprintf('Files scanned : %d\n', length(fileList));
end