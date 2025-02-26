%create boxplot from struct
function BoxFromStructNew(struct, TrueDepthLimit, char, color);
%color is a vector of colors (3 element)
%justdata is data from struct without labels or fields
%char is a character variable specifying cell type
%color is a vector of unique colors

clear justdata 
clear onevector
m = 1;
for n = 1:length(struct)
    if strcmp(struct(n).CellType, char)
        if struct(n).TrueDepth < TrueDepthLimit
    justdata(m,1) = struct(n).FRrun;
    justdata(m,2) = struct(n).FRstop;
    justdata(m,3) = struct(n).FRate;
    if struct(n).paired == 1
    paired(m,1) = 1;
    else 
        paired(m,1) = 0;
    end
    m = m+1;
        end
    end
end

%boxplot(justdata);
state = ['RUN '; 'STOP'; 'ALL '];
boxplot(justdata, state);
hold on
%onevector = justdata(:,1)./justdata(:,1);

for n = 1:length(justdata)
    scatter(1, justdata(n,1), 'MarkerEdgeColor', [color(n,1:3)]);
    scatter(2, justdata(n,2), 'MarkerEdgeColor', [color(n,1:3)]);
    scatter(3, justdata(n,3), 'MarkerEdgeColor', [color(n,1:3)]);
    if paired(n,1) == 1
    scatter(1, justdata(n,1), 'k', '*');
    scatter(2, justdata(n,2), 'k', '*');
    scatter(3, justdata(n,3), 'k', '*');
    end
end
end