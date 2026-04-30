function movingTimes = init()

        globals;

        movingTimes = [];
        %%%%%%%%%%%% Read Rotary Encoder for quiescence periods %%%%%%%%%%
        fRotEncA_ON = fopen([pathTPrime ROT_ENC_A_ON_TXT]);
        if fRotEncA_ON~=-1 
            rotEncA_ON = fscanf(fRotEncA_ON, '%f')'; % seconds
            fclose(fRotEncA_ON);
        else    % If you forgot to connect the rotary encoder before recording
            rotEncA_ON = [];
        end

        fRotEncA_OFF = fopen([pathTPrime ROT_ENC_A_OFF_TXT]);
        if fRotEncA_OFF~=-1 
            rotEncA_OFF = fscanf(fRotEncA_OFF, '%f')'; % seconds
            fclose(fRotEncA_OFF);
        else    % If you forgot to connect the rotary encoder before recording
            rotEncA_OFF = [];
        end

        fRotEncB_ON = fopen([pathTPrime ROT_ENC_B_ON_TXT]);
        if fRotEncB_ON~=-1 
            rotEncB_ON = fscanf(fRotEncB_ON, '%f')'; % seconds
            fclose(fRotEncB_ON);
        else    % If you forgot to connect the rotary encoder before recording
            rotEncB_ON = [];
        end

        fRotEncB_OFF = fopen([pathTPrime ROT_ENC_B_OFF_TXT]);
        if fRotEncB_OFF~=-1 
            rotEncB_OFF = fscanf(fRotEncB_OFF, '%f')'; % seconds
            fclose(fRotEncB_OFF);
        else    % If you forgot to connect the rotary encoder before recording
            rotEncB_OFF = [];
        end        
        %%%%%%%%%%%% Read Rotary Encoder for quiescence periods %%%%%%%%%%
            
        startTime = rotEncA_ON(1);
        movingStartTime = [];
        movingEndTime = [];
        while startTime<rotEncA_ON(end)     
            endTime = startTime+1; % check pulses within 1 sec
            pulsesA_ON = rotEncA_ON(find(rotEncA_ON>=startTime & rotEncA_ON<endTime));
            pulsesA_OFF = rotEncA_OFF(find(rotEncA_OFF>=startTime & rotEncA_OFF<endTime));
            pulsesB_ON = rotEncB_ON(find(rotEncB_ON>=startTime & rotEncB_ON<endTime));
            pulsesB_OFF = rotEncB_OFF(find(rotEncB_OFF>=startTime & rotEncB_OFF<endTime));
            maxTime = max([pulsesA_ON pulsesA_OFF pulsesB_ON pulsesB_OFF]);
            if length(pulsesA_ON)>=MIN_PULSE_THRESHOLD && length(pulsesA_OFF)>=MIN_PULSE_THRESHOLD && ...
                length(pulsesB_ON)>=MIN_PULSE_THRESHOLD && length(pulsesB_OFF)>=MIN_PULSE_THRESHOLD
                % Moving period found
                if isempty(movingStartTime)
                    movingStartTime = startTime;
                end
                movingEndTime = maxTime; % just in case properly walking period is over, save the timestamp. If it didn't, it will shift further timepoints during next iterations
            else % Not effectively moving, maybe the mouse is just wiggling/startling on the wheel                                
                if ~isempty(movingStartTime) && ~isempty(movingEndTime)
                    movingTimes = [movingTimes; movingStartTime movingEndTime];
                    movingStartTime = [];
                    movingEndTime = [];
                end
            end
            startTime = rotEncA_ON(find(rotEncA_ON>maxTime,1));
        end
end