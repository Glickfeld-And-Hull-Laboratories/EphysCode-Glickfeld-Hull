function BiggestWFstruct = BestWFfinderPlotter(structstruct, figboo)

for n = 1:length(structstruct)
    struct = structstruct(n).TGlim1WFs;
    for s = 1:length(struct)
            Sizer(1,s) = max(struct(s).AvgWf) - min(struct(s).AvgWf);
    end
  
    
    [Dist, I] = max(Sizer);
    BiggestChan = struct(I).Chan;
    BiggestWF = struct(I).AvgWf;
      [MAX ,MAXi] = max(BiggestWF);
      [MIN, MINi] = min(BiggestWF);
    if MAXi < MINi
        struct(I).AvgWf = -struct(I).AvgWf;
        BiggestWFstruct(n).flipped = 1;
        BiggestWFstruct(n).MAXIMINI = [MAXi, MINi];
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
    
   
    
    
    BiggestWFstruct(n).unit = structstruct(n).unit;
    BiggestWFstruct(n).chan = BiggestChan;
    BiggestWFstruct(n).WF = BiggestWF;
    BiggestWFstruct(n).NormWF = NormalBiggestWF;
    BiggestWFstruct(n).NormMinWF = NormalminBiggestWF;
    BiggestWFstruct(n).halfWidth = halfWidth;
    %BiggestWFstruct(n).MaxTime = NMi/30; %time of max in ms
    BiggestWFstruct(n).HalfWidthMax = halfWidthm;
     BiggestWFstruct(n).HalfWidthBoth = HalfWidthBoth;
     
    [maxBase, ~] = max(struct(I).AvgWf(1:10));
    [minBase, ~] = min(struct(I).AvgWf(1:10));
    Base = maxBase-minBase;
   
    BiggestWFstruct(n).SizeReBase = Sizer/Base;
    
    c = 1;
    for k = 1:length(Sizer)
        if Sizer(k)/Base > 20
            AllBigWF(c).wf = struct(k).AvgWf/(max(struct(k).AvgWf)-min(struct(k).AvgWf));
            AllBigWF(c).chan = struct(k).Chan;
            c = c +1;
        end
    end
    BiggestWFstruct(n).AllBigWF = AllBigWF;
    
    if figboo == 1
    figure
    hold on
    time = structstruct(1).time;
    Scale = struct.Scale;
    color = 'k';
    for n = 1:length(struct)
        plot(time+ struct(n).X/5000, struct(n).AvgWf+struct(n).Y*Scale/30, color);
        textx = time(end/3) + struct(n).X/5000;
        texty = max(struct(n).AvgWf + struct(n).Y*Scale/30)+.00005;
        text(textx, texty, [ num2str(Sizer(n)/Base)]); 
    end
    end
        
end
    
    
end
