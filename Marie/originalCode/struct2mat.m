function [array] = struct2mat(struct, field)

for n = 1:length(struct)
    array(n,:) = struct(n).(field);
end