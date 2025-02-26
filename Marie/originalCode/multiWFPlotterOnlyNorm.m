function BiggestWFstruct = multiWFPlotterOnlyNorm(list, structstruct, figboo, fig2boo, fig3boo)

for m = 1:length(list)%length(structstruct)
    k = find([structstruct.unit] == list(m));
    %struct = structstruct(k).TGlim1WFs;
    struct = structstruct(k).wfStructStruct;
    %struct = structstruct(k).MultiChanWFStruct;
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
        BiggestWFstruct(k).flipped = 1;
        BiggestWFstruct(k).MAXIMINI = [MAXi, MINi];
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
    
   
    
    
    BiggestWFstruct(k).unit = structstruct(k).unit;
    BiggestWFstruct(k).chan = BiggestChan;
    BiggestWFstruct(k).WF = BiggestWF;
    BiggestWFstruct(k).NormWF = NormalBiggestWF;
    BiggestWFstruct(k).NormMinWF = NormalminBiggestWF;
    BiggestWFstruct(k).halfWidth = halfWidth;
    %BiggestWFstruct(n).MaxTime = NMi/30; %time of max in ms
    BiggestWFstruct(k).HalfWidthMax = halfWidthm;
     BiggestWFstruct(k).HalfWidthBoth = HalfWidthBoth;
     
    [maxBase, ~] = max(struct(I).AvgWf(1:10));
    [minBase, ~] = min(struct(I).AvgWf(1:10));
    Base = maxBase-minBase;
   
    BiggestWFstruct(k).SizeReBase = Sizer/Base;
   
    if figboo == 1
    figure
    hold on
    time = [0:(1/30000):.003];
    time = time(1:end-1);
    Scale = struct.Scale;
    color = 'k';
    for n = 1:length(struct)
        %plot(time+ struct(n).X/5000, struct(n).AvgWf+struct(n).Y*Scale/30, color);
        textx = time(end/3) + struct(n).X;
        texty = max(normalize(struct(n).AvgWf) + struct(n).Y+2.5);
        text(textx, texty, [num2str(struct(n).Chan)]); 
    end
    end
         if fig3boo == 1
     struct = structstruct(k).StimWFs;
     color = 'b';
     for n = 1:length(struct)
        plot(time+ struct(n).X/5000, struct(n).AvgWf+struct(n).Y*Scale/30, color);
     
     end
     end
     if fig2boo == 1
    %struct = structstruct(k).TGlim2WFs;
    struct= structstruct(k).MultiChanWFStruct_LateBlock;
    
    color = 'm';
    for n = 1:length(struct)
        plot(time+ struct(n).X/5000, struct(n).AvgWf+struct(n).Y*Scale/30, 'Color', color);
   
    end
     end
    
     
      if figboo == 1
    %struct = structstruct(k).TGlim1WFs;
    struct = structstruct(k).wfStructStruct;
    %struct = structstruct(k).MultiChanWFStruct;
    color = 'k';
    for n = 1:length(struct)
        plot((time+ struct(n).X/5000), normalize(struct(n).AvgWf)+struct(n).Y, 'Color', color);
        Norm =  normalize(struct(n).AvgWf);
        
        
        if  (max(Norm)-min(Norm))> 5*(max(Norm(1:15))-min(Norm(1:15)))
        plot((time+ struct(n).X/5000), normalize(struct(n).AvgWf)+struct(n).Y, 'Color', color, 'LineWidth', 2);
        plot((time(1:15)+ struct(n).X/5000), Norm(1:15,1)+struct(n).Y, 'Color', 'm', 'LineWidth', 2);
        end
        
    end
      end
    
f = gca;
Xzero = f.XLim(1);
Yzero = f.YLim(1);
plot([Xzero, Xzero+.003], [Yzero, Yzero], 'k', 'LineWidth', 1); %3 ms line
plot([Xzero, Xzero], [Yzero, Yzero + 1], 'k', 'LineWidth', 1); %1/2 mV line
text(Xzero + .0005, Yzero - .0001, '3 msec');
h = text(Xzero - .0007, Yzero + .00015, '1 sd');
set(h,'Rotation',90);

axis off;
FormatFigure;

    

title(num2str(structstruct(k).unit));  
saveas(gca,[num2str(structstruct(k).unit) 'MF_long']);   
print('MF_longWF', '-dpsc', '-append');
end
    


end