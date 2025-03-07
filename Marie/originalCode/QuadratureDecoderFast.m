function [SpeedTimes, SpeedValues] = QuadratureDecoderFast()

pulsePerRev = 1024;
dia = 14.8; %diameter in cm
binW = .1; %bin width for speed calculations in sec

tic
X7_folder = dir('*nidq.XD_2_7_0.txt');
fid = fopen(X7_folder(1).name);
XD_7 = fscanf(fid, '%f');
fclose(fid);

X6_folder = dir('*nidq.XD_2_6_0.txt');
fid = fopen(X6_folder(1).name);
XD_6 = fscanf(fid, '%f');
fclose(fid);

iX6_folder = dir('*nidq.iXD_2_6_0.txt');
if isempty(iX6_folder)
    iX6_folder = dir('*nidq.xid_2_6_0.txt');
end
fid = fopen(iX6_folder(1).name);
iXD_6 = fscanf(fid, '%f');
fclose(fid);

iX7_folder = dir('*nidq.iXD_2_7_0.txt');
if isempty(iX7_folder)
    iX7_folder = dir('*nidq.xid_2_7_0.txt');
end
fid = fopen(iX7_folder(1).name);
iXD_7 = fscanf(fid, '%f');
fclose(fid);

iXD_6 = num2cell(iXD_6);
label = repmat('iXD_6', length(iXD_6), 1);
label = cellstr(label);
rotaryList_iXD_6 = [iXD_6 label];

iXD_7 = num2cell(iXD_7);
label = repmat('iXD_7', length(iXD_7), 1);
label = cellstr(label);
rotaryList_iXD_7 = [iXD_7 label];

XD_6 = num2cell(XD_6);
label = repmat('XD_6', length(XD_6), 1);
label = cellstr(label);
rotaryList_XD_6 = [XD_6 label];

XD_7 = num2cell(XD_7);
label = repmat('XD_7', length(XD_7), 1);
label = cellstr(label);
rotaryList_XD_7 = [XD_7 label];

rotaryList = [rotaryList_iXD_6; rotaryList_iXD_7; rotaryList_XD_6; rotaryList_XD_7];
rotaryList = sortrows(rotaryList, 1);


 XD6state = NaN;
 XD7state = NaN;
for n = 1:length(rotaryList)
if strcmp(rotaryList{n,2}, 'iXD_6')
XD6state = 0;
end
if strcmp(rotaryList{n,2}, 'iXD_7')
XD7state = 0;
end
if strcmp(rotaryList{n,2}, 'XD_7')
XD7state = 1;
end
if strcmp(rotaryList{n,2}, 'XD_6')
XD6state = 1;
end
rotaryList{n,3} = XD6state; %column 3 = XD6 state
rotaryList{n,4} = XD7state; %column 4 = XD6 state
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

%cell2struct(rotaryList, {'time', 'chan', 'XD6_state', 'XD7_state', 'quadState', 'dir'}, 2); %slow

XD_7_dir = rotaryList(strcmp(rotaryList(:,2), 'XD_7'),:);
XD_7_dir = [XD_7_dir(:,1) XD_7_dir(:,6)];

binW = .1;
SpeedTimes = [0:binW:rotaryList{end,1}];
SpeedTimes(end+1) =SpeedTimes(end) + binW;
 
TicsInUse = cell2mat(XD_7_dir(:,1));
WindowInUse = cell2mat(XD_7_dir(:, 2));
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
    XD7ticsForward(n) = sum(WindowInUse(1:IndexH)); %sum direction info
    else
        XD7ticsForward(n) = 0;
    end
end

SpeedValues = ((XD7ticsForward/pulsePerRev)*pi*dia)/binW;
SpeedTimes = SpeedTimes(1:end-1);
toc
end
