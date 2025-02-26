function BiggestWFstruct = multiWFPlotterOnlyPPI_2(structstruct, string, figboo, chan)
%intended to be used for only one channel

figure
hold on

for m = 1:length([structstruct.WFstruct])%length(structstruct)
    %struct = structstruct(m).TGlim1WFs;
    %struct = structstruct(m).wfStructStruct;
    %struct = structstruct(m).MultiChanWFStruct;
    struct = structstruct.WFstruct(m).SpikeNum;
    
    if isnan(chan)
    One = 1;
    ChanLength = length(struct);
    else
        ChanIndex = find([struct.Chan] == chan);
        One = ChanIndex;
        ChanLength = ChanIndex;
    end
    for s = 1:length(struct)
            Sizer(1,s) = max(struct(s).AvgWf) - min(struct(s).AvgWf);
    end
    color = ['k';  'b'; 'g'; 'm'; 'c'; 'y'];
    
    [Dist, I] = max(Sizer);
    BiggestChan = struct(I).Chan;
    BiggestWF = struct(I).AvgWf;
      [MAX ,MAXi] = max(BiggestWF);
      [MIN, MINi] = min(BiggestWF);
    if MAXi < MINi
        %struct(I).AvgWf = -struct(I).AvgWf;
        %BiggestWFstruct(m).flipped = 1;
        %BiggestWFstruct(m).MAXIMINI = [MAXi, MINi];
    end
    NormalBiggestWF = struct(I).AvgWf/(MAX-MIN);
    
    [minFlip, ~] = min(struct(I).AvgWf);
    NormalminBiggestWF = struct(I).AvgWf/-minFlip;
    
    %halfWidthcalcmin
    halfW1 = find(NormalminBiggestWF<-.3, 1);
    halfW2= find(NormalminBiggestWF(halfW1:end)>-.3,1);
    halfWidth = (halfW2-halfW1)/30; %halfwidth in msec
    
    %maxloc
    [maxFlip, ~] = max(struct(I).AvgWf);
    NormalmaxBiggestWF = struct(I).AvgWf/-maxFlip;
     halfW1m = find(NormalmaxBiggestWF>.3, 1);
     halfW2m= find(NormalmaxBiggestWF(halfW1m:end)<.3,1);
     halfWidthm = (halfW2m-halfW1m)/30; %halfwidth in msec
     
     %halfWdh
     HalfWidthBoth = (halfW2m-halfW1)/30;
    
   
    
    
    BiggestWFstruct(m).unit = structstruct.unit;
    BiggestWFstruct(m).spikeNum = m;
    BiggestWFstruct(m).chan = BiggestChan;
    BiggestWFstruct(m).WF = BiggestWF;
    BiggestWFstruct(m).NormWF = NormalBiggestWF;
    BiggestWFstruct(m).NormMinWF = NormalminBiggestWF;
    BiggestWFstruct(m).halfWidth = halfWidth;
    %BiggestWFstruct(n).MaxTime = NMi/30; %time of max in ms
    BiggestWFstruct(m).HalfWidthMax = halfWidthm;
     BiggestWFstruct(m).HalfWidthBoth = HalfWidthBoth;
     
     
     if length(struct(I).AvgWf)>1
    [maxBase, ~] = max(struct(I).AvgWf(1:10));
    [minBase, ~] = min(struct(I).AvgWf(1:10));
    Base = maxBase-minBase;
   
    BiggestWFstruct(m).SizeReBase = Sizer/Base;
     end
     for n = One:ChanLength
    [EarlyPeak, Peakloc] = max(struct(n).AvgWf(1:34));
    
    [AHP, AHPloc] = min(struct(n).AvgWf(40:50));
    AHPloc = AHPloc + 39;
    BiggestWFstruct(m).EarlyPeak = EarlyPeak;
    BiggestWFstruct(m).Peakloc = Peakloc;
    BiggestWFstruct(m).AHP = AHP;
    BiggestWFstruct(m).AHPloc = AHPloc;
     end

    
    if figboo == 1
    
    hold on
    time = [0:(1/30000):.003];
    time = time(1:end-1);
    if m == 1
    Scale = struct.Scale;
    for n = One:ChanLength
        
        %plot(time+ struct(n).X/4000, struct(n).AvgWf+struct(n).Y*Scale/30, color(m));
        textx = time(end/3) + struct(n).X/4000;
        texty = max(struct(n).AvgWf + struct(n).Y*Scale/30)+.00005;
        text(textx, texty, [num2str(struct(n).Chan)]); 
        scatter(time(AHPloc)+ struct(n).X/4000, struct(n).AvgWf(AHPloc)+struct(n).Y*Scale/30, 'k*')
        scatter(time(Peakloc)+ struct(n).X/4000, struct(n).AvgWf(Peakloc)+struct(n).Y*Scale/30, 'k*')
    end
    end
    end


    
     
      if figboo == 1
    %struct = structstruct(m).TGlim1WFs;
    %struct = structstruct(m).wfStructStruct;
    %struct = structstruct(m).MultiChanWFStruct;
    %color = 'k';
     %AHP = 32;
    for n = One:ChanLength
        if struct(n).N_wf > 20
        plot(time+ struct(n).X/4000, struct(n).AvgWf+struct(n).Y*Scale/30, color(m));
        scatter(time(AHPloc)+ struct(n).X/4000, struct(n).AvgWf(AHPloc)+struct(n).Y*Scale/30, 'k*');
        %BiggestWFstruct(m).AHP = struct(n).AvgWf(AHP);
        %BiggestWFstruct(m).AHPindex = AHP;
        %scatter(time(120)+ struct(n).X/4000, struct(n).AvgWf(120)+struct(n).Y*Scale/30, 'k*');
        end
        if (struct(n).N_wf > 3 & struct(n).N_wf <= 20)
        plot(time+ struct(n).X/4000, struct(n).AvgWf+struct(n).Y*Scale/30, [color(m) ':']);
        scatter(time(AHPloc)+ struct(n).X/4000, struct(n).AvgWf(AHPloc)+struct(n).Y*Scale/30, 'k*');
        %BiggestWFstruct(m).AHP = struct(n).AvgWf(AHP);
        %BiggestWFstruct(m).AHPindex = AHP;
        %scatter(time(120)+ struct(n).X/4000, struct(n).AvgWf(120)+struct(n).Y*Scale/30, 'k*');
        end
    end
      end
   
      if m == 1
f = gca;
Xzero = f.XLim(1);
Yzero = f.YLim(1);
plot([Xzero, Xzero+.003], [Yzero, Yzero], 'k', 'LineWidth', 1); %3 ms line
plot([Xzero, Xzero], [Yzero, Yzero + .0005], 'k', 'LineWidth', 1); %1/2 mV line
text(Xzero + .0005, Yzero - .0001, '3 msec');
h = text(Xzero - .0003, Yzero + .00015, '0.5 mV');
set(h,'Rotation',90);

axis off;
FormatFigure;

    
end
title(num2str(structstruct.unit));  
      end
saveas(gca,[num2str(structstruct.unit) string]);   
print([num2str(structstruct.unit) string], '-dpsc', '-append');

    


end
