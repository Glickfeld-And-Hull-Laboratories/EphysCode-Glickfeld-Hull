function out = cell2mat_doubles(c)
    % Convert all elements to double if mixed or int64, then cell2mat
    if iscell(c)
        c = cellfun(@(x) double(x), c, 'UniformOutput', false);
    end
    out = cell2mat(c);
end