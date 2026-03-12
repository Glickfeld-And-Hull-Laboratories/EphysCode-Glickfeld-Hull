% built to compare layer stats from mouse ephys experiments
% wrapper, loadMouseMarmData.m
%
% example line to call function:
% runLayerStats({meanZp(indL23), meanZp(indL4), meanZp(indL56)})

function [p, p12, p13, p23] = runLayerStats_SG(data)

y = [data{1}(:); data{2}(:); data{3}(:)];

g = [ ...
    ones(length(data{1}),1); ...
    2*ones(length(data{2}),1); ...
    3*ones(length(data{3}),1) ...
];

valid = ~isnan(y);
y = y(valid);
g = g(valid);

[p,~,stats] = kruskalwallis(y,g,'off');

pairwise = multcompare(stats,'Display','off');

p12 = pairwise(1,6);   % L2/3 vs L4
p13 = pairwise(2,6);   % L2/3 vs L5/6
p23 = pairwise(3,6);   % L4 vs L5/6

end