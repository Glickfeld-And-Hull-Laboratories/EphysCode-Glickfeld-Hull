function [] = dump_struct_to_h5(filename, group_name, x, varargin)
% DUMP_STRUCT_TO_H5 dumps a MATLAB structure to an HDF5 file
%
% dump_struct_to_h5(filename, group_name, data) creates a new HDF5 file
% at the path pointed two by `filename'. By convention, this file should
% have a *.h5 extension (but this convention is not enforced by this function).
% If `filename' does not exist, then a new HDF5 file is created. However,
% if `filename' does exist, then it is opened for appending. This allows
% multiple calls to this function to continually append dataset to existing
% h5 files. The additional key-value pair, `overwrite', supercedes this behavior
% and will force a new file to be created.
%  
% The parameter `group_name' specifies the group-wise path of the current
% where the contents of the input `data' should be written. This path should
% be absolute (include the root of the HDF5 file). 
%
% The parameter `data' must be a matlab structure or an array of structures. 
% If data is an array of structures, each structure is written out in order
% with a group name equal to `group_name`_<index> (using 0-indexing). Each
% structure is written out such that each field of the structure is written
% to a separate dataset under the group. Nested structures are allowed.
%
% Additional key-value pairs can be supplied, including:
%  'overwrite': Do not attemp to open a file for appending. Always
%    create a new file.
%
% EXAMPLE:
%  Consider a call dump_to_struct_h5('my_file.h5', '/group', x) where
%  x is a matlab structure with the following fields:
%   x.my_string = 'hello';
%   x.my_int = 2;
%   x.my_vector = [1, 2, 3];
%   x.my_matrix = rand(5, 5);
%  After a call to dump_to_struct_h5, the contentsof the 'my_file.h5' would
%  be:
%   /group <- a group
%   /group/my_string <- a dataset with string contents
%   /group/my_int <- a dataset with integer contents
%   /group/my_vector <- a dataset with vector contents
%   /group/my_matrix <- a dataset with matrix contents
%
% notes 10/12/22 from DH:
%
% It's unhappy about your channel_noise_std field
% Which is an array of structs which is not supported by that reader.
% If you replace channel_noise_std with channel_noise_std.OneStDev so that it is an array, it will work
% or, alternatively, convert it to a struct

% so easiest solution is:
%for i = 1:length(C4struct_interim)
%C4struct_interim(i).channel_noise_std = [C4struct_interim(i).channel_noise_std.OneStDev]
%end
%
%dump_to_h5('hull_neurons_2022_10_11.h5', '/hull_neuron', C4struct_interim)

args = getopt(varargin, {'overwrite'});

% Ensure that x is a structure
if ~ isa(x, 'struct')
    error("Expected the input to be a structure");
end

% Ensure that group_name begins with a /
if (~isa(group_name, 'string') && ~isa(group_name, 'char')) || group_name(1) ~= "/"
    error("Group name should be a string listing the absolute group name (e.g., /group)")
end

if (exist(filename, 'file') && args.overwrite)
    delete(filename);
end

if exist(filename, 'file')
    fid = H5F.open(filename, 'H5F_ACC_RDWR', 'H5P_DEFAULT');
else
    fid = H5F.create(filename);
end

if length(x) == 1
    write_struct(fid, group_name, x)
else
    for i = 1:numel(x)
        write_struct(fid, [group_name, '_', num2str(i-1)], x(i));
    end
end

H5F.close(fid)

% Convert a Matlab type to the equivalent HDF5 type.
% Note that only certain conversions are possible
function [tid, x] = get_h5_type(x)
    if isa(x, 'single')
        tid = H5T.copy('H5T_NATIVE_FLOAT');
    elseif isa(x, 'double')
        tid = H5T.copy('H5T_NATIVE_DOUBLE');
    elseif isa(x, 'string') || isa(x, 'char')
        x = char(x);
        tid = H5T.copy('H5T_C_S1');
    elseif isa(x, 'logical')
        x = uint8(x);
        tid = H5T.copy('H5T_NATIVE_UCHAR');
    elseif isa(x, 'uint32')
        tid = H5T.copy('H5T_NATIVE_UINT32');
    elseif isa(x, 'uint64')
        tid = H5T.copy('H5T_NATIVE_UINT64');
    elseif isa(x, 'int')
        tid = H5T.copy('H5T_NATIVE_INT');
    else
        error("Unknown type")
    end
end

% Write a dataset with the passed name to the group
% (gid is the group identifier)
function write_dataset(gid, name, data)
    plist = 'H5P_DEFAULT';
    current_size = size(data);
    % Remove singleton dimensions so that we can get
    % the rank without Matlab's strange view that vectors
    % are 1xM (rank 2) rather than just M (rank 1)
    current_size = current_size(current_size ~= 1);
    if isempty(current_size)
        current_size = 1;
    end
    rank = length(current_size);
    % Get the associated type
    [type_id, data] = get_h5_type(data);
    if isscalar(data) 
        sid = H5S.create('H5S_SCALAR');
    elseif isa(data, 'char')
        sid = H5S.create('H5S_SCALAR');
        H5T.set_size(type_id, current_size);
    else
        sid = H5S.create_simple(rank, current_size, current_size);
    end
    
    did = H5D.create(gid, name, type_id, sid, plist);
    if isa(data, 'char')
        H5D.write(did, 'H5ML_DEFAULT', sid, H5D.get_space(did), plist, data)
    else
        H5D.write(did, 'H5ML_DEFAULT', 'H5S_ALL', 'H5S_ALL', plist, data)
    end
    H5D.close(did);
    H5S.close(sid);
end

% Write a structure to a given group, writing each field of
% the underlying structure to a different dataset underneight the
% group. Structures inside of structures recursively call this function.
function write_struct(fid, group_name, data)
    plist = 'H5P_DEFAULT';
    gid = H5G.create(fid, group_name, plist);
    names = fieldnames(data);
    for i = 1:length(names)
        if isa(data.(names{i}), 'struct')
            write_struct(fid, [group_name, '/', names{i}], data.(names{i}));
        else
            write_dataset(gid, names{i}, data.(names{i}));
        end
    end
    H5G.close(gid);
end

end
