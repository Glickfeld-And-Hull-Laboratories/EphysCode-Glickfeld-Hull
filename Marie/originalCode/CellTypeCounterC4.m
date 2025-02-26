function [CellTypeCounts, PkC_cs, PkC_ss, MFB, MLI, GoC, untyped] = CellTypeCounterC4(struct, threshold)

PkC_ss = [];
PkC_cs = [];
MFB =[];
MLI = [];
GoC = [];
untyped = [];



CellTypeCounts.PkC_ss = 0;
CellTypeCounts.PkC_cs = 0;
CellTypeCounts.MLI = 0;
CellTypeCounts.MFB = 0;
CellTypeCounts.GoC = 0;
CellTypeCounts.untyped = 0;

for n = 1:length(struct)
if strcmp(struct(n).c4_label, 'PkC_ss')
    if struct(n).c4_confidence > threshold
CellTypeCounts.PkC_ss = CellTypeCounts.PkC_ss +1;
PkC_ss = [PkC_ss; struct(n)];
else
  CellTypeCounts.untyped = CellTypeCounts.untyped +1;
untyped = [untyped; struct(n)]; 
    end
end

if strcmp(struct(n).c4_label, 'PkC_cs')
    if struct(n).c4_confidence > threshold
CellTypeCounts.PkC_cs = CellTypeCounts.PkC_cs +1;
PkC_cs = [PkC_cs; struct(n)];
else
  CellTypeCounts.untyped = CellTypeCounts.untyped +1;
untyped = [untyped; struct(n)]; 
    end
end

if strcmp(struct(n).c4_label, 'MLI')
    if struct(n).c4_confidence > threshold
CellTypeCounts.MLI = CellTypeCounts.MLI +1;
MLI = [MLI; struct(n)];
else
  CellTypeCounts.untyped = CellTypeCounts.untyped +1;
untyped = [untyped; struct(n)]; 
    end
end

if strcmp(struct(n).c4_label, 'MFB')
if struct(n).c4_confidence > threshold
    CellTypeCounts.MFB = CellTypeCounts.MFB +1;
MFB = [MFB; struct(n)];
else
  CellTypeCounts.untyped = CellTypeCounts.untyped +1;
untyped = [untyped; struct(n)]; 
end
end

if strcmp(struct(n).c4_label, 'GoC')
if struct(n).c4_confidence > threshold
    CellTypeCounts.GoC = CellTypeCounts.GoC +1;
GoC = [GoC; struct(n)];
else
  CellTypeCounts.untyped = CellTypeCounts.untyped +1;
untyped = [untyped; struct(n)];  
end
end

if isnan(struct(n).c4_label)
CellTypeCounts.untyped = CellTypeCounts.untyped +1;
untyped = [untyped; struct(n)];
end

end
end

% X = categorical(fieldnames(CellTypeCounts_1));
% X = reordercats(X,{'Small','Medium','Large','Extra Large'});
% figure
% bar(X, [cell2mat(struct2cell(CellTypeCounts_1)) cell2mat(struct2cell(CellTypeCounts_2)) cell2mat(struct2cell(CellTypeCounts_3))]);
% sum(cell2mat(struct2cell(CellTypeCounts_2)))
% sum(cell2mat(struct2cell(CellTypeCounts_1)))
% sum(cell2mat(struct2cell(CellTypeCounts_3)))
% legend({'Threshold = 1'; 'Threshold = 2'; 'Threshold = 3'});
% legend('boxoff');
% FigureWrap('C4 classified', 'C4_classified', NaN, NaN, NaN, NaN, NaN, NaN);