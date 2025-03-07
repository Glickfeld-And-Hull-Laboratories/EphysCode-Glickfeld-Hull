function LaserTimes = LaserONOFF(Trigger)
trigger = Trigger.data(3,:); %get laser channel from trigger file
SampRate = 30000;
counter = 1;
index = 1;
while ~isempty(find(trigger(index:end)>10000,1))
index = index + find(trigger(index:end)>10000,1);
if counter ==1
    index = index-1; %we had to start at 1 since it's 1 indexed
end
LaserTimes(counter,1) = double(index)/SampRate;
index = index + find(trigger(index:end)<10000,1);
LaserTimes(counter,2) = double(index)/SampRate;
counter = counter + 1;
end
if ~exist('LaserTimes', 'var')
    LaserTimes = [NaN NaN];
end