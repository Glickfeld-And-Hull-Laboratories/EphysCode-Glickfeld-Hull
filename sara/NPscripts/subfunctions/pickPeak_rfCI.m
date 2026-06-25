function idx = pickPeak_rfCI(x)

    % Find local peaks
    [pks, locs] = findpeaks(x);
    
    if isempty(locs)
        % fallback: no clear peaks → take global max
        [~, idx] = max(x);
        
    elseif length(locs) == 1
        % only one peak
        idx = locs(1);
        
    else
        % multiple peaks → take the later one
        idx = locs(end);
    end

    % --- Custom override logic ---
    % Bias timepoint selection closer to spike time if STA at consequtive 
    % timepoints are comparable.
    
    if idx == 2 && length(x) >= 3
        val2 = x(2);
        val3 = x(3);
        
        % If 4th is within 5% of 2nd, choose 4th instead
        if val3 >= 0.95 * val2
            idx = 3;
        end
    end

    if idx == 3 && length(x) >= 4
        val3 = x(3);
        val4 = x(4);
        
        % If 4th is within 5% of 2nd, choose 4th instead
        if val4 >= 0.95 * val3
            idx = 4;
        end
    end

    % This condition is meant to catch reversing RFs where 2 and 4 have
    % comparable contrast intensities, but timepoint 3 is weak because of
    % switch.
    
    if idx == 2 && length(x) >= 4
        val2 = x(2);
        val4 = x(4);
        
        % If 4th is within 5% of 2nd, choose 4th instead
        if val4 >= 0.95 * val2
            idx = 4;
        end
    end
end