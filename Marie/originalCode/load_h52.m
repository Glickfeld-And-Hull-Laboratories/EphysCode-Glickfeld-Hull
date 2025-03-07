function [data] = load_h5(file)
% LOAD_H5 loads all of the datasets in an HDF5 file
%   [output] = load_h5(file) loads the contents of the HDF5 file
%   passed by `file.' Each of the datasets is output as a field whose
%   name is equal to the name of the field in the HDF5 file.
%
%   Note: In the current version, the parameters for each of the fields
%   are not loaded. 
%

info = h5info(file);

% Create an empty output structure
data = [];

% Recursively load all groups under the root path
data = load_group(file, info, data);

end

function [name] = clean_var_name(name)
% Clean up variable names (making them valid variable names if they are
% not)
    if ~isvarname(name)
        warning(['Renaming invalid variable name ', name]);
        name = regexprep(name, '^([0-9])', 'p\1'); % Replace strings starting with a number
        name = regexprep(name, '\W', '_'); % Any character not alphaetic numeric or underscore
    end
end

function [data] = load_group(file, group, data)
% Recursively load all groups under the current group
    % Load all datasets from this group
    data = load_datasets(file, group, data);
    data = load_attributes(file, group, data);
    % Load all groups
    for i = 1:length(group.Groups)
        group_name = strsplit(group.Groups(i).Name, '/');
        group_name = clean_var_name(group_name{end});
        
        data.(group_name) = [];
        data.(group_name) = load_group(file, group.Groups(i), data.(group_name));
    end
end

function [data] = load_datasets(file, group, data)
    % Load all data sets under the current group  
    for i = 1:length(group.Datasets)
        data.(clean_var_name(group.Datasets(i).Name)) = h5read(file, [group.Name '/' group.Datasets(i).Name]);
        if ~isempty(group.Datasets(i).Attributes)
            % TODO: Load dataset attributes
        end
    end
end

function [data] = load_attributes(file, group, data)
    % Load all attributes under the current group
    for i = 1:length(group.Attributes)
        data.(clean_var_name(group.Attributes(i).Name)) = h5readatt(file, ['/' group.Name], group.Attributes(i).Name);
    end
end