BasicLoopLine
figure

for k = 1:length(CSlist)
plot(edges, RespLines(k,:),'color', [.85 .85 .85]);
hold on
end
meanResp = mean(RespLines);
plot(edges, meanResp,'color', 'r');
