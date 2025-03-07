function struct = CellTypeSort(struct)

for n = 1:length(struct)
if (struct(n).FR < 2.5)
struct(n).CellType = 'CS';
end
if (struct(n).FR > 39 )
struct(n).CellType = 'SS';
end
if isempty(struct(n).paired)
    struct(n).paired = 0;
end
end