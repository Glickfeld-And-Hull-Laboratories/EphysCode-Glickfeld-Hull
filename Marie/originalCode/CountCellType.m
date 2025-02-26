function n = CountCellType(struct, celltype, depth);
%celltype is a string
n = 0;
for m = 1:length(struct)
    if strcmp(struct(m).CellType, celltype)
        if struct(m).TrueDepth < depth
            n = n + 1;
        end
    end
end