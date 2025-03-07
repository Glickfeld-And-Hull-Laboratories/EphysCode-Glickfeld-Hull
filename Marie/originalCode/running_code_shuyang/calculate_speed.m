%calculate speed for moving dot experiments, used in
%behav_analysis_movingDots_WF

function speed = calculate_speed(input)
% before ziye updated the coding, qudrature times and value are only
% reported when there's move. so can't use qudrature times and values 
% to calculate speed, can only use wheelspeed values.
if sum(cellfun(@isempty, input.quadratureTimesUs))== 0
    quadTime = cell2mat(input.quadratureTimesUs);
    quadValue = cell2mat(input.quadratureValues);
    countTime = cell2mat(input.counterTimesUs);
    countValue = cell2mat(input.counterValues);
    %find the indexes of quadurature times that falls in the period between 2 camera triggers (100ms),
    %and the corresponding locations are the ones needed for calculating speed of each 100ms.
    %For each 100ms, speed = delta distances/frame duration
    %(end-first/time and sum(diff) gives the same result.)
    speed = [];
    nStart = find(countValue == 1, 1, 'last');
    for n = nStart:length(countTime)
        if countValue(n) == 1
            this_frame_quad_inx = find(quadTime > countTime (n) - 100*1000 & quadTime <= countTime(n));
        else
            this_frame_quad_inx = find(quadTime > countTime(n-1) & quadTime <= countTime(n));
        end
        this_frame_loc = quadValue(this_frame_quad_inx);
        this_frame_distance = this_frame_loc(end)-this_frame_loc(1);
        this_frame_time = quadTime(this_frame_quad_inx);
        this_frame_timelength = this_frame_time(end)-this_frame_time(1);
        this_frame_speed = (this_frame_distance)*1000000/(this_frame_timelength);
        % 1000000: us to s 
        speed = [speed this_frame_speed];
        
    end
else
    %use wheel speed values
    countValue = input.counterValues;
    wheelSpeedValues = input.wheelSpeedValues;
    for n = 1:size(wheelSpeedValues,2)
        %MWorks starts record wheelspeed before the camera starts taking photos every trial, so delete these ones.
        if n == 1
            start = find(countValue{n} == 1, 1,'last');
            wheelSpeedValues{n} = wheelSpeedValues{n}(end-(size(input.counterValues{n},2)-start):end);
        elseif size(wheelSpeedValues{n},2) > size(countValue{n},2)
            wheelSpeedValues{n} = wheelSpeedValues{n}(end-size(input.counterValues{n},2)+1:end);
        end
    end
    speed = cell2mat(wheelSpeedValues);
end

end

