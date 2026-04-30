function [spikeTimeAlignedToLaserOnset] = chunkAlignSpikeTimes(spikeTimesSec, laserOnsetTimesGLX, laserOffsetTimesGLX)
        globals;

        spikeTimeAlignedToLaserOnset = cell(1,length(laserOnsetTimesGLX));
        for indLaser=1:length(laserOnsetTimesGLX)
            spikesOfTrial = spikeTimesSec(spikeTimesSec>(laserOnsetTimesGLX(indLaser)-PRE_TIME_LASER) & spikeTimesSec<(laserOnsetTimesGLX(indLaser)+POST_TIME_LASER)); 
            spikeTimeAlignedToLaserOnset(indLaser) = {spikesOfTrial - laserOnsetTimesGLX(indLaser)}; % align according to Lever Hold
        end
end