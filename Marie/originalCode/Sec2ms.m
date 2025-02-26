function MSlabels = Sec2ms(xl)
 for n = 1:length(xl)
     MSlabels(n,1) = str2num(cell2mat(xl(n)));
 end
 MSlabels = round(MSlabels*1000); %actual converstion
MSlabels = num2str(MSlabels);
MSlabels = cellstr(MSlabels);
for n = 1:length(MSlabels)
    tester = MSlabels{n,1};
    MSlabels{n,1} = tester(~isspace(tester));
end

%LimitMSlabels(1,1) = MSlabels(1,1);
%if mod(length(MSlabels),2)
%    LimitMSlabels(2,1) = MSlabels((end-1)/2,1);
%    LimitMSlabels(3,1) = MSlabels((end-1),1);
%else
%    LimitMSlabels(2,1) = MSlabels((end)/2,1);
%    LimitMSlabels(3,1) = MSlabels((end),1);
end