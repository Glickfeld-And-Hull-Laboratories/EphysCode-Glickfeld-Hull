function colorCodes = getColorCodesForTrialTypes(trialType, withAlpha)
    globals;
    colorCodes = cell(1,length(trialType));
    if ~withAlpha
        for i=1:length(trialType)
            if strcmp(trialType{i},TRIAL_TONE_CLICK_JUICE) % 'b'        = both click
                colorCodes{i} = 'k';
            elseif strcmp(trialType{i},TRIAL_TONE_JUICE)   % 'b_s'      = both silent
                colorCodes{i} = 'r';
            elseif strcmp(trialType{i},TRIAL_TONE)         % 't'        = tone alone
                colorCodes{i} = 'c';
            elseif strcmp(trialType{i},TRIAL_CLICK_JUICE)  % 'j'        = juice click
                colorCodes{i} = 'b';
            elseif strcmp(trialType{i},TRIAL_JUICE)        % 'j_s'      = juice silent
                colorCodes{i} = 'g';
            elseif strcmp(trialType{i},TRIAL_CLICK)        % 'eCl'      = click without juice
                colorCodes{i} = 'y';
            elseif strcmp(trialType{i},TRIAL_TONE_CLICK)   % 't_eCl'    = tone with empty click
                colorCodes{i} = 'm';
            else
                colorCodes{i} = 'r';
            end        
        end
    else
        for i=1:length(trialType)
            if strcmp(trialType{i},TRIAL_TONE_CLICK_JUICE) % 'b'        = both click
                colorCodes{i} = COLORS(8,:); % 'k';
            elseif strcmp(trialType{i},TRIAL_TONE_JUICE)   % 'b_s'      = both silent
                colorCodes{i} = COLORS(7,:); % 'r';
            elseif strcmp(trialType{i},TRIAL_TONE)         % 't'        = tone alone
                colorCodes{i} = COLORS(6,:); % 'c';
            elseif strcmp(trialType{i},TRIAL_CLICK_JUICE)  % 'j'        = juice click
                colorCodes{i} = COLORS(11,:); % 'b';
            elseif strcmp(trialType{i},TRIAL_JUICE)        % 'j_s'      = juice silent
                colorCodes{i} = COLORS(5,:); % 'g';
            elseif strcmp(trialType{i},TRIAL_CLICK)        % 'eCl'      = click without juice
                colorCodes{i} = COLORS(3,:); % 'y';
            elseif strcmp(trialType{i},TRIAL_TONE_CLICK)   % 't_eCl'    = tone with empty click
                colorCodes{i} = COLORS(4,:); % 'm';
            else
                colorCodes{i} = COLORS(7,:);
            end   
        end
    end
    
end