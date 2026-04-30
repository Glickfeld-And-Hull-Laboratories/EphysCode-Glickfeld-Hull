function [laserOnsetTimes, laserOffsetTimes] = init()

        globals;
        %%%%%%%%%%%% Read Behavioral measures %%%%%%%%%%
        
        fLaserOnsetId = fopen([pathTPrime LASER_ONSET_TXT]);
        if fLaserOnsetId~=-1
            laserOnsetTimesGLX = fscanf(fLaserOnsetId, '%f')'; % seconds
            fclose(fLaserOnsetId);
        else
            laserOnsetTimesGLX = [];
        end
        
        fLaserOffsetId = fopen([pathTPrime LASER_OFFSET_TXT]);
        if fLaserOffsetId~=-1
            laserOffsetTimesGLX = fscanf(fLaserOffsetId, '%f')'; % seconds
            fclose(fLaserOffsetId);
        else
            laserOffsetTimesGLX = [];
        end

        laserStartMoments = [];
        laserEndMoments = [];
        GAIN_CHANGE_MOMENTS = [GAIN_CHANGE_MOMENTS_BASELINE; GAIN_CHANGE_MOMENTS_1; GAIN_CHANGE_MOMENTS_2];
        laserStartMoments = [laserStartMoments GAIN_CHANGE_MOMENTS(1,3)];
        indTurnOff = find(GAIN_CHANGE_MOMENTS(:,1)==0);
        for indTO = 1:length(indTurnOff)
            laserEndMoments = [laserEndMoments GAIN_CHANGE_MOMENTS(indTurnOff(indTO),3)]; % turned-off moment
            if indTurnOff(indTO)+1<=size(GAIN_CHANGE_MOMENTS,1)
                laserStartMoments = [laserStartMoments GAIN_CHANGE_MOMENTS(indTurnOff(indTO)+1,3)]; % next first moment should be turned-on moment
            end
        end
        
        laserOnsetTimes = [];
        laserOffsetTimes = [];
        for ind=1:length(laserStartMoments)
            actualLaserOnsetTimes = laserOnsetTimesGLX(laserOnsetTimesGLX>laserStartMoments(ind) & laserOnsetTimesGLX<laserEndMoments(ind));
            laserOnsetTimes = [laserOnsetTimes actualLaserOnsetTimes];

            actualLaserOffsetTimes = laserOffsetTimesGLX(laserOffsetTimesGLX>laserStartMoments(ind) & laserOffsetTimesGLX<laserEndMoments(ind));
            laserOffsetTimes = [laserOffsetTimes actualLaserOffsetTimes];
        end
end