function d = getDepthC4(channel, InDepth, angle, chanMap)
%first, draw a triangle to imagine the electrode coming in at an angle. The
%top is the brain surface and the top left angle is 90 degrees if the top right angle is 75 degrees. (If the
%electrose is straight down, the top right angle is 90 degrees and this calculation
%is trivial.

a = InDepth/sind(angle); %a is the total electrode in the brain, from the tip. If the angle is 90, this is just the depth.
aY = a - 175 + 20; % to account for 175 micron tip length and the fact that the channel map yscale is for some reason zeroed at 20
channelY = chanMap(channel + 1).ycoord;
a_ = abs(aY - channelY);   %distance along electrode from top channel to this channel. This draws the hypotenuse of the smaller triangle that only goes to the channel of interest.
d = a_ * sind(angle); % find how deep this channel is in the brain
end