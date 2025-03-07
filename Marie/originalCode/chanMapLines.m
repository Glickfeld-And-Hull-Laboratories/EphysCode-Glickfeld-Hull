unitchan = 100;
chanindex = unitchan + 1;
counter = 1;
for n = 1:40
    delta = n - 20;
    if (((unitchan + delta) > 1) && ((unitchan + delta) < length(rez.ycoords)))
channelmap(counter,1) = unitchan + delta;
channelmap(counter,2) = rez.xcoords(chanindex + delta) - rez.xcoords(chanindex);
channelmap(counter,3) = rez.ycoords(chanindex + delta) - rez.ycoords(chanindex);
counter = counter + 1;
    end
end