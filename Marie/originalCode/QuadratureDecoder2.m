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

counter = 1;
for n = 1:length(iXD_6)
   rotaryList(counter).time = iXD_6(n);
   rotaryList(counter).chan= 'iXD_6';
   counter = counter + 1;
end
for n = 1:length(iXD_7)
   rotaryList(counter).time = iXD_7(n);
   rotaryList(counter).chan = 'iXD_7';
   counter = counter + 1;
end
for n = 1:length(XD_6)
   rotaryList(counter).time = XD_6(n);
   rotaryList(counter).chan = 'XD_6';
   counter = counter + 1;
end
for n = 1:length(XD_7)
      rotaryList(counter).time = XD_7(n);
   rotaryList(counter).chan = 'XD_7';
   counter = counter + 1;
end
 rotaryList = SortStruct(rotaryList, 'time', 'ascend');
 XD6state = NaN;
 XD7state = NaN;
for n = 1:length(rotaryList)
if strcmp(rotaryList(n).chan, 'iXD_6')
XD6state = 0;
end
if strcmp(rotaryList(n).chan, 'iXD_7')
XD7state = 0;
end
if strcmp(rotaryList(n).chan, 'XD_7')
XD7state = 1;
end
if strcmp(rotaryList(n).chan, 'XD_6')
XD6state = 1;
end
rotaryList(n).XD6state = XD6state;
rotaryList(n).XD7state = XD7state;
end


for n = 1:length(rotaryList)
if rotaryList(n).XD6state == 0
if rotaryList(n).XD7state == 0
rotaryList(n).State = 0;
else
rotaryList(n).State = 3;
end
end
if rotaryList(n).XD6state == 1
if rotaryList(n).XD7state == 0
rotaryList(n).State = 1;
else
rotaryList(n).State = 2;
end
end
if (isnan(rotaryList(n).XD6state) || isnan(rotaryList(n).XD7state))
rotaryList(n).State = NaN;
end
end

for n = 2:length(rotaryList)
State = rotaryList(n).State;
if ((rotaryList(n-1).State-rotaryList(n).State == 1) || (rotaryList(n-1).State-rotaryList(n).State == -3));
rotaryList(n).Dir = 1;
else
rotaryList(n).Dir = 0;    
end
end

for n = 2:length(rotaryList)
rotaryList(n).TimeSinceTic = (rotaryList(n).time-rotaryList(n-1).time);
if strcmp(rotaryList(n).chan, 'XD_7')
rotaryList(n).PulseBinary = 1;
else
rotaryList(n).PulseBinary = 0;
end
end

binW = .1;
RunningTPlist = [0:binW:rotaryList(end).time];
 for n = 1:length(RunningTPlist)
     RunningTP(n).time = RunningTPlist(n);
 end
for n =1:length(RunningTP)
    Index = find([rotaryList.time]>RunningTP(n).time & [rotaryList.time]<RunningTP(n+1).time);
    Window = [rotaryList(Index).Dir].*[rotaryList(Index).PulseBinary];
    Dist = (sum(Window)/pulsePerRev)*2*pi*7;
    RunningTP(n).speed = Dist/binW;
end
 %runRate(f) = (((PulsesSinceRev/pulsePerRev)*2*pi*7)/TimeSinceRev); % convert ticks/bin to running rate based on particular metrics of the wheen (2000 ticks/rev, radius = 7 cm)
