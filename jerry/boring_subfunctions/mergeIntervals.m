function merged = mergeIntervals(intervals)
% intervals is given as nInterval x 2 matrix
    if isempty(intervals)
        merged = intervals;
    else
        intervals = sortrows(intervals, 1);
        merged = intervals(1,:);
        for i = 2:size(intervals, 1)
            if intervals(i,1) <= merged(end,2)
                % Merge overlapping/adjacent
                merged(end,2) = max(merged(end,2), intervals(i,2));
            else
                % Add non-overlapping
                merged(end+1,:) = intervals(i,:);
            end
        end
    end
end