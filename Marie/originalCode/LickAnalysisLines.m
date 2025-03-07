for n = 1:length(GoodUnitsDepthorder)
figure
tiledlayout('flow');
nexttile
OneUnitHistStructTimeLim(tone, GoodUnitsDepthorder(n), AllUnitStruct, -1, 2, .01, [0 inf], 'k');
xline(.699, 'b');
nexttile
OneUnitHistStructTimeLim(FirstLicksEpochsAdj - .5, GoodUnitsDepthorder(n), AllUnitStruct, -1, 2, .01, [0 inf], 'k');
xline(.5, 'm');
nexttile
OneUnitHistStructTimeLim(AllLicksAdj - .5, GoodUnitsDepthorder(n), AllUnitStruct, -1, 2, .01, [0 inf], 'k');
xline(.5, 'm');
nexttile
RasterMatrix = OrganizeRasterSpikesNew(AllUnitStruct, JuiceByReaction, GoodUnitsDepthorder(n), 1, 3);
hold on
plot(B,trials);
xline(0,'b')
saveas(gca, num2str(GoodUnitsDepthorder(n)))
saveas(gca, num2str(GoodUnitsDepthorder(n)), 'epsc')
end