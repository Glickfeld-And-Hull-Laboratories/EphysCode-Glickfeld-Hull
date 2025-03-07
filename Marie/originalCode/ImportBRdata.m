function [UnitStruct, LaserTimes] = ImportBRdata(depth, date, data_number, neurons, Trigger, varagin)
%depth, date, data_number are all strings, ie '1700', '220221', '002'.
%neurons is from Full Binary Persuit Sorting from David (in Julia)
%varagin is UnitStruct to add on to- concatenate across recordings

sampRate = 30000;

LaserTimes = LaserONOFF(Trigger);

if (nargin >5)
     counter = length(varagin)+1;
else
    counter = 1;
end

for n = 1:length(neurons)
    UnitStruct(n).unitID = counter;
    UnitStruct(n).timestamps = double(neurons{n,1}.spike_indices__)/sampRate;
    UnitStruct(n).channel = NaN;
    UnitStruct(n).depth = depth;
    UnitStruct(n).group = 'unsort';
    UnitStruct(n).FR = double(neurons{n,1}.mean_firing_rate);
    UnitStruct(n).Indentification = [date '_' data_number '_' num2str(n)];
    UnitStruct(n).LaserON = LaserTimes(:,1);
    UnitStruct(n).LaserOFF = LaserTimes(:,2);
    UnitStruct(n).template = neurons{n,1}.template;
    UnitStruct(n).snr = neurons{n,1}.snr;
    UnitStruct(n).CV2 = neurons{n,1}.cv2;
    UnitStruct(n).CV = neurons{n,1}.cv;
counter = counter + 1;
end
nargin
 if (nargin >5)
     UnitStruct = [varagin UnitStruct];
 end
end