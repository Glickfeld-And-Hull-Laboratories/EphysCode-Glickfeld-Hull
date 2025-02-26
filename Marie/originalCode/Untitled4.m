figure
hold on
for n = 1:length(MF_vs_DE)
if strcmp(MF_vs_DE(n).handID,'MF')
plot(MF_vs_DE(n).BiggestWFstruct.NormBiggestAligned, 'g');
%plot(SummaryStruct_mli(n).BiggestWFstruct.NormWF, 'r');
end
end
hold on
for n = 1:length(MF_vs_DE)
if strcmp(MF_vs_DE(n).handID,'DE')
plot(MF_vs_DE(n).BiggestWFstruct.NormBiggestAligned, 'b');
%plot(SummaryStruct_Pc(n).BiggestWFstruct.NormWF, 'k');
end
end

figure
hold on
for n = 1:length(MLI_vs_PC)
if strcmp(MLI_vs_PC(n).handID,'MLI_laser')
    plot(MLI_vs_PC(n).BiggestWFstruct.alignedWF, 'r');
%plot(MLI_vs_PC(n).BiggestWFstruct.alignedWF/abs((MLI_vs_PC(n).BiggestWFstruct.alignedWF(30))), 'r');
end
end
hold on
for n = 1:length(MLI_vs_PC)
if strcmp(MLI_vs_PC(n).handID,'PC')
    plot(MLI_vs_PC(n).BiggestWFstruct.alignedWF, 'k');
%plot(MLI_vs_PC(n).BiggestWFstruct.alignedWF/abs((MLI_vs_PC(n).BiggestWFstruct.alignedWF(30))), 'k');
end
end
FormatFigure

figure
hold on
for n = 1:length(SummaryStruct_mli)
if strcmp(SummaryStruct_mli(n).handID,'MLI_laser')
plot(SummaryStruct_mli(n).edgesACG_long, SummaryStruct_mli(n).Nacg_long/mean(SummaryStruct_mli(n).Nacg_long(1:5)), 'r');
end
end
hold on
for n = 1:length(SummaryStruct_Pc)
if strcmp(SummaryStruct_Pc(n).handID,'PC')
plot(SummaryStruct_Pc(n).edgesACG_long, SummaryStruct_Pc(n).Nacg_long/mean(SummaryStruct_Pc(n).Nacg_long(1:5)), 'k');
end
end
FormatFigure

figure
hold on
for n = 1:length(SummaryStruct)
if strcmp(SummaryStruct(n).handID,'MLI_laser')
plot(SummaryStruct(n).edgesACG, SummaryStruct(n).Nacg/max(SummaryStruct(n).Nacg), 'r');
end
end
hold on
for n = 1:length(SummaryStruct)
if ~strcmp(SummaryStruct(n).handID,'MLI_laser')
plot(SummaryStruct(n).edgesACG, SummaryStruct(n).Nacg/max(SummaryStruct(n).Nacg), 'k');
end
end
FormatFigure


figure
hold on
for n = 1:length(SummaryStruct_Pc)
plot(SummaryStruct_Pc(n).edgesACG, SummaryStruct_Pc(n).Nacg/max(SummaryStruct_Pc(n).Nacg), 'r');
end

hold on


figure
hold on
for n = 1:length(MLI_vsPC)
if strcmp(MLI_vsPC(n).handID, 'MLI_laser')
scatter(MLI_vsPC(n).WFw, MLI_vsPC(n).WFh, 'r');
end
if strcmp(MLI_vsPC(n).handID, 'PC')
scatter(MLI_vsPC(n).WFw, MLI_vsPC(n).WFh, 'k');
end
end
xlabel('WF width');
ylabel('WF height')
title('WF characteristics');
FormatFigure



for n = 1:length(SummaryStruct)
SummaryStruct(n).forPCA = [SummaryStruct(n).BiggestWFstruct.NormBiggestAligned; [normalize(SummaryStruct(n).Nacg)].'];
end
[coeff,score,latent,tsquared,explained,mu] = pca([SummaryStruct_MLI_PC]);
figure
plot(explained)
title('Component contribution to PCA analysis WFacg')
ylabel('explained')
xlabel('PC')
saveas(gca, 'NormWFacg C contribution')
print('NormWFacg C contribution', '-depsc','-painters')
figure

for n = 1:18
scatter3(score_wfacg(n,1),score_wfacg(n,2),score_wfacg(n,3), 'g')
hold on
end

for n = 19:28
scatter3(score_wfacg(n,1),score_wfacg(n,2),score_wfacg(n,3), 'k')
end

xlabel('1st Principal Component')
ylabel('2nd Principal Component')
zlabel('3rd Principal Component')
title('NormWFacg PCA')
FormatFigure
saveas(gca, 'NormWFacg PCA')
print('NormWF PCAacg', '-depsc','-painters')
