function [SpeedTimes, SpeedValues] = QuadratureDecoderFast_xid()

pulsePerRev = 1024;
dia = 14.8; %diameter in cm
binW = .1; %bin width for speed calculations in sec

tic
X7_folder = dir('*nidq.xd_2_7_0.txt');
fid = fopen(X7_folder(1).name);
xd_7 = fscanf(fid, '%f');
fclose(fid);

X6_folder = dir('*nidq.xd_2_6_0.txt');
fid = fopen(X6_folder(1).name);
xd_6 = fscanf(fid, '%f');
fclose(fid);

iX6_folder = dir('*nidq.XiD_2_6_0.txt');
fid = fopen(iX6_folder(1).name);
ixd_6 = fscanf(fid, '%f');
fclose(fid);

iX7_folder = dir('*nidq.XiD_2_7_0.txt');
fid = fopen(iX7_folder(1).name);
ixd_7 = fscanf(fid, '%f');
fclose(fid);

ixd_6 = num2cell(ixd_6);
label = repmat('ixd_6', length(ixd_6), 1);
label = cellstr(label);
rotaryList_ixd_6 = [ixd_6 label];

ixd_7 = num2cell(ixd_7);
label = repmat('ixd_7', length(ixd_7), 1);
label = cellstr(label);
rotaryList_ixd_7 = [ixd_7 label];

xd_6 = num2cell(xd_6);
label = repmat('xd_6', length(xd_6), 1);
label = cellstr(label);
rotaryList_xd_6 = [xd_6 label];

xd_7 = num2cell(xd_7);
label = repmat('xd_7', length(xd_7), 1);
label = cellstr(label);
rotaryList_xd_7 = [xd_7 label];

rotaryList = [rotaryList_ixd_6; rotaryList_ixd_7; rotaryList_xd_6; rotaryList_xd_7];
rotaryList = sortrows(rotaryList, 1);


 xd6state = NaN;
 xd7state = NaN;
for n = 1:length(rotaryList)
if strcmp(rotaryList{n,2}, 'ixd_6')
xd6state = 0;
end
if strcmp(rotaryList{n,2}, 'ixd_7')
xd7state = 0;
end
if strcmp(rotaryList{n,2}, 'xd_7')
xd7state = 1;
end
if strcmp(rotaryList{n,2}, 'xd_6')
xd6state = 1;
end
rotaryList{n,3} = xd6state; %column 3 = xd6 state
rotaryList{n,4} = xd7state; %column 4 = xd6 state
end


for n = 1:length(rotaryList)
if rotaryList{n,3} == 0
if rotaryList{n,4} == 0
rotaryList{n,5} = 0; %colum 5 is QuadState
else
rotaryList{n,5} = 3;
end
end
if rotaryList{n,3} == 1
if rotaryList{n,4} == 0
rotaryList{n,5} = 1;
else
rotaryList{n,5} = 2;
end
end
if (isnan(rotaryList{n,3}) || isnan(rotaryList{n,4}))
rotaryList{n,5} = NaN;
end
end

for n = 2:length(rotaryList)
if ((rotaryList{n-1,5}-rotaryList{n,5} == 1) || (rotaryList{n-1,5}-rotaryList{n,5} == -3))
rotaryList{n,6} = 1; %colum 6 = dir
else
rotaryList{n,6} = -1;    
end
end

%cell2struct(rotaryList, {'time', 'chan', 'xd6_state', 'xd7_state', 'quadState', 'dir'}, 2); %slow

xd_7_dir = rotaryList(strcmp(rotaryList(:,2), 'xd_7'),:);
xd_7_dir = [xd_7_dir(:,1) xd_7_dir(:,6)];

binW = .1;
SpeedTimes = [0:binW:rotaryList{end,1}];
SpeedTimes(end+1) =SpeedTimes(end) + binW;
 
TicsInUse = cell2mat(xd_7_dir(:,1));
WindowInUse = cell2mat(xd_7_dir(:, 2));
for n =1:length(SpeedTimes)-1
    if n == 1
    IndexL = find(TicsInUse>SpeedTimes(n),1); 
    else
        IndexL = IndexH +1;
    end
    TicsInUse = TicsInUse(IndexL:end); %trim tic timepoints to unused ones every trial for speed
    WindowInUse = WindowInUse(IndexL:end); %trim corresponding direction info
    IndexH = find(TicsInUse>SpeedTimes(n+1), 1)-1; %find tic timepoints in window
    if ~(IndexH == 0)
    xd7ticsForward(n) = sum(WindowInUse(1:IndexH)); %sum direction info
    else
        xd7ticsForward(n) = 0;
    end
end

SpeedValues = ((xd7ticsForward/pulsePerRev)*pi*dia)/binW;
SpeedTimes = SpeedTimes(1:end-1);
toc
end
