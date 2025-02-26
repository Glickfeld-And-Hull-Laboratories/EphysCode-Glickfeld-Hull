rotaryDecoder(iXD_6, iXD_7, XD_6, XD_7)

pulsePerRev = 1024;
fid = fopen('1674_230214_g1_tcat.nidq.XD_2_7_0.txt');
XD_7 = fscanf(fid, '%f');
fclose(fid);
fid = fopen('1674_230214_g1_tcat.nidq.XD_2_6_0.txt');
XD_6 = fscanf(fid, '%f');
fclose(fid);
fid = fopen('1674_230214_g1_tcat.nidq.iXD_2_6_0.txt');
iXD_6 = fscanf(fid, '%f');
fclose(fid);
fid = fopen('1674_230214_g1_tcat.nidq.iXD_2_7_0.txt');
iXD_7 = fscanf(fid, '%f');
fclose(fid);


 rotaryList = SortStruct(rotaryList, 'time', 'ascend');
 toc
 
 tic
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
toc

rotaryList = [rotaryList_iXD_6; rotaryList_iXD_7; rotaryList_XD_6; rotaryList_XD_7];
rotaryList = sortrows(rotaryList, 1);


tic
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
toc



tic
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
toc

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
 RunningTPlist = [0:binW:rotaryList(end).time];
 RunningTPlist(end+1) = RunningTPlist(end) + binW;
 
 
 %too slow
 tic
for n =1:length(RunningTPlist)
    Index = find(cell2mat(tester(:,1))>RunningTPlist(n) & cell2mat(tester(:,1))<RunningTPlist(n+1));
    if ~isempty(Index)
    Window = sum(cell2mat([tester(Index, 2)]));
    RunningTP_tics(n) = Window;
    else
        RunningTP_tics(n) = 0;
    end
end
toc
Dist = (RunningTP_tics/pulsePerRev)*2*pi*7;

tic
TicsInUse = cell2mat(tester(:,1));
WindowInUse = cell2mat(tester(:, 2));
for n =1:length(RunningTPlist)-1
    if n == 1
    IndexL = find(TicsInUse>RunningTPlist(n),1);
    else
        IndexL = IndexH +1;
    end
    TicsInUse = TicsInUse(IndexL:end);
    WindowInUse = WindowInUse(IndexL:end);
    IndexH = find(TicsInUse>RunningTPlist(n+1), 1)-1;
    if ~(IndexH == 0)
    Window = sum(WindowInUse(1:IndexH));
    RunningTP_tics_tester(n) = Window;
    else
        RunningTP_tics_tester(n) = 0;
    end
end
toc
Dist = (RunningTP_tics/pulsePerRev)*2*pi*7;

 %runRate(f) = (((PulsesSinceRev/pulsePerRev)*2*pi*7)/TimeSinceRev); % convert ticks/bin to running rate based on particular metrics of the wheen (2000 ticks/rev, radius = 7 cm)
tic
counter = 1;
for n = 1:length(rotaryList)
if strcmp(rotaryList{n,2}, 'XD_7')
XD7_dir(counter).Dir = rotaryList(n).Dir;
XD7_dir(counter).time = rotaryList(n).time;
counter = counter + 1;
end
end
toc

binW = .1;
RunningTPlist = [0:binW:XD7_dir(end).time];
for n = 1:length(RunningTPlist)
RunningTP(n).time = RunningTPlist(n);
end
tic
for n =1:length(RunningTP)-1
    Index = find([XD7_dir.time]>RunningTP(n).time & [XD7_dir.time]<RunningTP(n+1).time);
    Dist = (sum([XD7_dir(Index).Dir])/pulsePerRev)*2*pi*7;
    RunningTP(n).speed = ((sum([XD7_dir(Index).Dir])/pulsePerRev)*2*pi*7)/binW;
end
toc