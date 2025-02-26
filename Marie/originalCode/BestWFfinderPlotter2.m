function BiggestWFstruct = BestWFfinderPlotter2(structstruct, figboo)

for n = 1:length(structstruct)
    %struct = structstruct(n).TGlim1WFs;
    struct = structstruct(n).wfStructStruct;
    for s = 1:length(struct)
            Sizer(1,s) = max(struct(s).AvgWf) - min(struct(s).AvgWf);
    end
  
    
    [Dist, I] = max(Sizer);
    BiggestChan = struct(I).Chan;
    BiggestWF = struct(I).AvgWf;
      [~ ,MAXi] = max(BiggestWF);
      [~, MINi] = min(BiggestWF);
    if MAXi < MINi
        if abs(max(BiggestWF)) > abs(min(BiggestWF))
        
        struct(I).AvgWf = -struct(I).AvgWf;
        BiggestWFstruct(n).flipped = 1;
        BiggestWFstruct(n).MAXIMINI = [MAXi, MINi];
        end
    end
    length(struct(I).AvgWf);
    NormalBiggestWF = normalize(struct(I).AvgWf);
    
    BiggestWFstruct(n).unit = structstruct(n).unitID;
    BiggestWFstruct(n).chan = BiggestChan;
    BiggestWFstruct(n).WF = BiggestWF;
    BiggestWFstruct(n).NormWF = NormalBiggestWF;
    
    [~, mini] = min(NormalBiggestWF);
    if mini <20 || mini > 40
        fprintf('error error error')
        NormalBiggestAligned = BiggestWF;
    else
        NormalBiggestAligned = NormalBiggestWF(mini-20:mini+50); %minimum of normalized waveform is at index 21
    end
    BiggestWFstruct(n).NormBiggestAligned = NormalBiggestAligned;
    
      %maxloc
    [maxNorm, maxIndex] = max(NormalBiggestAligned(21:end));
    [minNorm, ~] = min(NormalBiggestAligned);
   BiggestWFstruct(n).NormalSize = maxNorm-minNorm;
   BiggestWFstruct(n).MaxLoc = maxIndex;

    
     
 
    
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
