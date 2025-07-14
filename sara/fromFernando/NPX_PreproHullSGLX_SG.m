function NPX_PreproHullSGLX(FileName,MainDir)

npxid = 't0.imec0.ap.bin';
nidaqid = 't0.nidq.bin';
npxmetaid = 't0.imec0.ap.meta';
nidaqmetaid = 't0.nidq.meta';


base = '\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\sara\Data\neuropixel\250211\i2746-250211-12DirTest-1sOn1sOff_g0\i2746-250211-12DirTest-1sOn1sOff_g0_imec0';
cd(base)

fnames = dir;
fnames = {fnames.name};

for ii = 1:length(fnames)
    if contains(fnames{ii},npxid)
       syncNPX = NPX_GetSGLXSync_SG(fnames{ii});        
    elseif contains(fnames{ii},nidaqid)
       syncNidaq = NPX_GetSGLXSync_SG(fnames{ii}); 
    elseif contains(fnames{ii},npxmetaid)
       metanpx = importdata(fnames{ii});
       %metanpx = metanpx.textdata;
    elseif contains(fnames{ii},nidaqmetaid)
       metanidaq = importdata(fnames{ii});
       metanidaq = metanidaq.textdata;
    end
end

if length(unique(syncNPX)) ~= 2
    error('syncNPX is not binary. It has elements:')
end

firstNPX = metanpx{contains(metanpx,'firstSample=')};
firstNPX = str2double(firstNPX(strfind(firstNPX,'=')+1:end));
FsNPX = metanpx{contains(metanpx,'imSampRate=')};
FsNPX = str2double(FsNPX(strfind(FsNPX,'=')+1:end));


firstNidaq = metanidaq{contains(metanidaq,'firstSample=')};
firstNidaq = str2double(firstNidaq(strfind(firstNidaq,'=')+1:end));
FsNidaq = metanidaq{contains(metanidaq,'niSampRate=')};
FsNidaq = str2double(FsNidaq(strfind(FsNidaq,'=')+1:end));

offset = firstNPX/FsNPX - firstNidaq/FsNidaq;

if(offset > 0.02)
    warning('big offset in meta file. check traces. You can ignore this') %You can ignore this warning as long as the second warning is not met.
end
FsNidaq = 25000; %Make sure the sampling rate of nidaq is correct.
FsNPX = 30000;

syncNPX_d1 = diff(syncNPX);
syncNidaq_d1 = diff(syncNidaq,[],2);

tnidaq = (1/FsNidaq:1/FsNidaq:size(syncNidaq_d1,2)/FsNidaq);
tnpx = 1/FsNPX:1/FsNPX:size(syncNPX_d1,2)/FsNPX;

syncNPX_bool = syncNPX_d1~=0;
syncNidaq_bool = syncNidaq_d1~=0;

ts_NPX = tnpx(syncNPX_bool);
ts_Nidaq = [];
st_Nidaq = [];

for NidaqChans = 1:size(syncNidaq_bool,1)

    temp = tnidaq(syncNidaq_bool(NidaqChans,:));
    ts_Nidaq = [ts_Nidaq,temp];
    st_Nidaq = [st_Nidaq,zeros(1,length(temp))+NidaqChans]

end


ts_Nidaq2fit = tnidaq(st_Nidaq == 1);

[ts_Nidaq,idx] = sort(ts_Nidaq);
st_Nidaq = st_Nidaq(idx);

if(abs(ts_NPX(1) - ts_Nidaq2fit(1)) > 0.02)
    warning('IMPORTANT: big offset in traces. check traces. Dont ignore')
end

c = polyfit(ts_Nidaq2fit,ts_Nidaq2fit - ts_NPX,1);
ts_Nidaq = ts_Nidaq - ([1:length(ts_Nidaq)] * (c(1)/2)); %This only works cause the sync pulse is 0.5secs. 1/0.5sec = 2.

ts_Nidaq2fit = ts_Nidaq(st_Nidaq == 1);
offset = round(mean(ts_Nidaq2fit(ts_Nidaq2fit>0) - ts_NPX));

ts_Nidaq = ts_Nidaq - offset;

ts_Nidaq = ts_Nidaq';
st_Nidaq = st_Nidaq';
ts_NPX = ts_NPX';

save(FileName,'ts_Nidaq','st_Nidaq','ts_NPX');