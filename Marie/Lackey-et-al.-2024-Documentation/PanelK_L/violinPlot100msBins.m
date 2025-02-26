

fullRange = [testerA_far testerA_near testerB_far testerB_near];
support = [min(fullRange)-5 max(fullRange)+5];
[f,xi,bandw] = ksdensity(fullRange,  'support', support);
figure
violin([testerA_near].', support, 'x', [0 inf], {'testerA_far'}, 'facecolor', 'k', 'bw', bandw);
violin([testerB_near].', support, 'x', [.75 inf], {'testerA_far'}, 'facecolor', 'k', 'bw', bandw);
violin([testerA_far].', support, 'x', [1.5 inf], {'testerA_far'}, 'facecolor', 'k', 'bw', bandw);
violin([testerB_far].', support, 'x', [2.25 inf], {'testerA_far'}, 'facecolor', 'k', 'bw', bandw);
xlim([-.5 2.75]);
xticks([0 .75 1.5 2.25])
xticklabels({'A near','B near','A far', 'B far'})
% FigureWrap('violin 100ms bins', 'violinAll', NaN, 'delta sp/sec', NaN, [-65 85]);

% FigureWrap('violin 100ms bins', 'violinAll_zoom', NaN, 'delta sp/sec', NaN, [-50 50]);
