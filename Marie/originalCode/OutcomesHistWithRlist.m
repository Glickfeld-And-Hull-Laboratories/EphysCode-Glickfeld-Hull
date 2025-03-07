
C = colororder;
for R = 1:length(Rlist)
f = figure;
nexttile % hist of lick times Naive
hold on
 Trials = Rlist(R).LickOnsets(strcmp({Rlist(R).LickOnsets.Outcome}, 'p'));
    if ~isempty(Trials)
histogram ([Trials.TrialTime], [-2.5:.05:2.5], 'FaceAlpha', .5, 'FaceColor', C(1,:))
    end
Trials = Rlist(R).LickOnsets(strcmp({Rlist(R).LickOnsets.Outcome}, 'r'));
    if ~isempty(Trials)
histogram ([Trials.TrialTime], [-2.5:.05:2.5], 'FaceAlpha', .5, 'FaceColor', C(2,:))
end
Trials = Rlist(R).LickOnsets(strcmp({Rlist(R).LickOnsets.Outcome}, 'o'));
    if ~isempty(Trials)
histogram ([Trials.TrialTime] , [-1:.05:2.5], 'FaceAlpha', .5, 'FaceColor', C(3,:))
    end
    Trials = Rlist(R).LickOnsets(strcmp({Rlist(R).LickOnsets.Outcome}, 'b'));
    if ~isempty(Trials)
histogram ([Trials.TrialTime] , [-1:.05:2.5], 'FaceAlpha', .5, 'FaceColor', C(4,:))
    end
xline(-.682, 'b', 'LineWidth', 1);
xline(0, 'c', 'LineWidth', 1);
xlim([-2.5 2.5])
title(['mouse:' num2str(Rlist(R).mouse) ' day:'  num2str(Rlist(R).day)]);
xlabel('time from reward (s)');
ylabel('n lick onsets');
FormatFigure(NaN, NaN);
legend({'Predict'; 'React'; 'Outside Trial'; 'cue'; 'reward'})
legend('boxoff')
FigureWrap(NaN, ['mouse_' num2str(Rlist(R).mouse) '_day_'  num2str(Rlist(R).day)], NaN, NaN, NaN, NaN, NaN, NaN);
end
% end
% end
% nexttile
% hold on
% plot([0:length(PredPerc)-1], PredPerc);
% plot([0:length(PredPerc)-1], ReactPerc);
% plot([0:length(PredPerc)-1], MissPerc);
% xticklabels({RecordingList.day})
% xlabel('day');
% ylabel('liklihood of response type');
% title('response type liklihood');
% xlim([0 length(PredPerc)-1]);
% FormatFigure(NaN, NaN)
C = colororder;
for R = 1:length(Rlist)
    N_p = [];
N_r = [];
N_o = [];
N_b = [];
f = figure;
nexttile % hist of lick times Naive
hold on
DayTrials = Rlist(R).TrialStruct;
DayTrials = DayTrials(strcmp({DayTrials.TrialType}, 'b'));
 Trials = DayTrials(strcmp({DayTrials.Outcome}, 'p'));
    if ~isempty(Trials)
[N_p, edges] = histcounts([Trials.RTj], [-2.5:.05:2.5]);
    end
Trials = DayTrials(strcmp({DayTrials.Outcome}, 'r'));
    if ~isempty(Trials)
[N_r, edges] = histcounts([Trials.RTj], [-2.5:.05:2.5]);
end
Trials = DayTrials(strcmp({DayTrials.Outcome}, 'o'));
    if ~isempty(Trials)
[N_o, edges] = histcounts([Trials.RTj] , [-2.5:.05:2.5]);
    end
    Trials = DayTrials(strcmp({DayTrials.Outcome}, 'b'));
    if ~isempty(Trials)
[N_b, edges] = histcounts([Trials.RTj] , [-2.5:.05:2.5]);
    end
    plot(edges(1:end-1), N_b/length([DayTrials]), 'Color', C(3,:));
    plot(edges(1:end-1), N_o/length([DayTrials]), 'Color', C(3,:));
    plot(edges(1:end-1), N_r/length([DayTrials]), 'Color', C(2,:));
    plot(edges(1:end-1), N_p/length([DayTrials]), 'Color', C(1,:));
xline(-.682, 'b', 'LineWidth', 1);
xline(0, 'c', 'LineWidth', 1);
xlim([-2.5 2.5])
title(['mouse:' num2str(Rlist(R).mouse) ' day:'  num2str(Rlist(R).day)]);
xlabel('time from reward (s)');
ylabel('liklihood of lick onset');
FormatFigure(NaN, NaN);
legend({'Predict'; 'React'; 'Outside Trial'; 'cue'; 'reward'})
legend('boxoff')
FigureWrap(NaN, ['mouse_' num2str(Rlist(R).mouse) '_day_'  num2str(Rlist(R).day )], NaN, NaN, NaN, NaN, NaN, NaN);


N_p = NaN;
N_r = NaN;
N_o = NaN;
N_b = NaN;
f = figure;
nexttile % hist of lick times Naive
hold on
DayTrials = Rlist(R).TrialStruct;
DayTrials = DayTrials(strcmp({DayTrials.TrialType}, 'j'));
 Trials = DayTrials(strcmp({DayTrials.Outcome}, 'p'));
    if ~isempty(Trials)
[N_p, edges] = histcounts([Trials.RTj], [-2.5:.05:2.5]);
    end
Trials = DayTrials(strcmp({DayTrials.Outcome}, 'r'));
    if ~isempty(Trials)
[N_r, edges] = histcounts([Trials.RTj], [-2.5:.05:2.5]);
end
Trials = DayTrials(strcmp({DayTrials.Outcome}, 'o'));
    if ~isempty(Trials)
[N_o, edges] = histcounts([Trials.RTj] , [-2.5:.05:2.5]);
    end
    Trials = DayTrials(strcmp({DayTrials.Outcome}, 'b'));
    if ~isempty(Trials)
[N_b, edges] = histcounts([Trials.RTj] , [-2.5:.05:2.5]);
    end
    plot(edges(1:end-1), N_b/length([DayTrials]), 'Color', C(3,:));
    plot(edges(1:end-1), N_o/length([DayTrials]), 'Color', C(3,:));
    plot(edges(1:end-1), N_r/length([DayTrials]), 'Color', C(2,:));
    plot(edges(1:end-1), N_p/length([DayTrials]), 'Color', C(1,:));
xline(-.682, 'b', 'LineWidth', 1);
xline(0, 'c', 'LineWidth', 1);
xlim([-2.5 2.5])
title(['mouse:' num2str(Rlist(R).mouse) ' day:'  num2str(Rlist(R).day) ' juice alone']);
xlabel('time from reward (s)');
ylabel('liklihood of lick onset');
FormatFigure(NaN, NaN);
legend({'Predict'; 'React'; 'Outside Trial'; 'cue'; 'reward'})
legend('boxoff')
FigureWrap(NaN, ['mouse_' num2str(Rlist(R).mouse) '_day_'  num2str(Rlist(R).day '_juiceAlone' )], NaN, NaN, NaN, NaN, NaN, NaN);

N_p = [];
N_r = [];
N_o = [];
N_b = [];
f = figure;
nexttile % hist of lick times Naive
hold on
DayTrials = Rlist(R).TrialStruct;
DayTrials = DayTrials(strcmp({DayTrials.TrialType}, 't'));
 Trials = DayTrials(strcmp({DayTrials.Outcome}, 'p'));
    if ~isempty(Trials)
[N_p, edges] = histcounts([Trials.RTj], [-2.5:.05:2.5]);
    end
Trials = DayTrials(strcmp({DayTrials.Outcome}, 'r'));
    if ~isempty(Trials)
[N_r, edges] = histcounts([Trials.RTj], [-2.5:.05:2.5]);
end
Trials = DayTrials(strcmp({DayTrials.Outcome}, 'o'));
    if ~isempty(Trials)
[N_o, edges] = histcounts([Trials.RTj] , [-2.5:.05:2.5]);
    end
    Trials = DayTrials(strcmp({DayTrials.Outcome}, 'b'));
    if ~isempty(Trials)
[N_b, edges] = histcounts([Trials.RTj] , [-2.5:.05:2.5]);
    end
    plot(edges(1:end-1), N_b/length([DayTrials]), 'Color', C(3,:));
    plot(edges(1:end-1), N_o/length([DayTrials]), 'Color', C(3,:));
    plot(edges(1:end-1), N_r/length([DayTrials]), 'Color', C(2,:));
    plot(edges(1:end-1), N_p/length([DayTrials]), 'Color', C(1,:));
xline(-.682, 'b', 'LineWidth', 1);
xline(0, 'c', 'LineWidth', 1);
xlim([-2.5 2.5])
title(['mouse:' num2str(Rlist(R).mouse) ' day:'  num2str(Rlist(R).day) 'laser alone']);
xlabel('time from reward (s)');
ylabel('liklihood of lick onset');
FormatFigure(NaN, NaN);
legend({'Predict'; 'React'; 'Outside Trial'; 'cue'; 'reward'})
legend('boxoff')
FigureWrap(NaN, ['mouse_' num2str(Rlist(R).mouse) '_day_'  num2str(Rlist(R).day ) '_laserAlone'], NaN, NaN, NaN, NaN, NaN, NaN);

end

