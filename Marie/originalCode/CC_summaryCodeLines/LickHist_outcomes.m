C = colororder;

for k = 1:length(RecordingList)
    figure
[N, edges] = LickHist([RecordingList(k).LickOnsetReact.RecordTime].', RecordingList(k).AllLicks, [-1 1], .05, C(1,:), 1);
hold on
[N, edges] = LickHist([RecordingList(k).LickOnsetPred.RecordTime].', RecordingList(k).AllLicks, [-1 1], .05, C(2,:), 1);
[N, edges] = LickHist([RecordingList(k).LickOnsetEmpty.RecordTime].', RecordingList(k).AllLicks, [-1 1], .05, C(3,:), 1);
legend({'predict'; 'react'; 'unrewarded'}, 'Location', 'northeast');
legend('boxoff')
title(num2str(k));
end