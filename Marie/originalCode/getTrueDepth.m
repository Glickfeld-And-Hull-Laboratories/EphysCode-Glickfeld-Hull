function struct = getTrueDepth(struct, surface, angle)
% 09/21/21 angle is usually 75 degrees- SSW
%assumes struct has a field, depth, that is the depth from
%Neurpixels/kilosort. Use the micromanipulator reading from insertion (a, the hypotenuse), the
%tip length is subtracted here. Micromanipulator reading should be entered
%as a positive number.

surface = surface - 175; % to account for 175 micron tip length

% used to do for the whole structure
% for n = 1:length(struct)
% descent = surface - struct(n).depth;
% TrueDepth = descent*sind(angle);
% TrueDepth = round(TrueDepth);
% struct(n).TrueDepth = TrueDepth;
% end
% 
% end


%shallowToDeepGood = 0;
% I must have pasted in cell ID and depth into 1 & 2
%shallowToDeepGood(:,3) = 2276-shallowToDeepGood(:,2);
%shallowToDeepGood(:,4) = shallowToDeepGood(:,3)*sind(75);
%shallowToDeepGood(:,4) = round(shallowToDeepGood(:,4));