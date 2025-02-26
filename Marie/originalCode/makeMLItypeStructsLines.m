for n = 1:length(MLI_MLI)
if MLI_MLI(n).inhSD4_4ms ==1
MLI_inhibitED_MLI_index(counter) = MLI_MLI(n).indexFollow;
counter = counter + 1;
end
end
for n = 1:length(SumSt)
if SumSt(n).MLI_PC_4SDinh ==1
end
end
counter = 1;
for n = 1:length(SumSt)
if SumSt(n).MLI_PC_4SDinh ==1
MLI_inhibit_PC_index(counter) = n;
end
end
MLI_inhibit_PC = SumSt(MLI_inhibit_PC_index);
counter = 1;
for n = 1:length(SumSt)
if SumSt(n).MLI_PC_4SDinh ==1
MLI_inhibit_PC_index(counter) = n;
counter = counter + 1;
end
end
MLI_inhibit_PC = SumSt(MLI_inhibit_PC_index);
MLI_inhibit_MLI = SumSt(MLI_inhibits_MLI_index);
MLI_inhibitED_MLI = SumSt(MLI_inhibitED_MLI_index);