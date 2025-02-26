function respCells = BasicLoopFunction(list, struct, trigger,  xmin, xmax, TimeLim, binsize, color, basename) %B, trials); %trigger2,
%basename is a string

saveBoo = 1;

respCells = [];
respLats = [];
origColor = color;
%for
%%n=1:length([GoodUnitStruct.unitID])%length(AboutOneHz)%length([GoodUnitStruct.unitID])%
%n = length(list);
figurecounter = 1;
figure

unitCounter = 1;
set(gcf,'Position',[50 50 1800 1100])
tiledlayout('flow');
hold on
 for   n = 1:length(list)

    if find(divisors(n) == 9)
       
      counterStr = num2str(figurecounter);
      filename_ = [basename counterStr];
      
      saveas(gca, filename_);
     %saveas(gca, filename_, 'epsc');
      print(filename_, '-dpdf');
      figure
      set(gcf,'Position',[50 50 1800 1100])
      tiledlayout('flow');
      figurecounter = figurecounter +1;
    end
    
    nexttile
    hold on  
    %unitIN = n;
    unit = list(n,1);
    %unit = granUnsort(n,1);
    unitIN = find([struct.unitID] == unit);
   
    if strcmp(struct(unitIN).group, 'mua')
        color = 'b';
    end
    if strcmp(struct(unitIN).group, 'good')
        color = origColor;
    end
   
    struct(unitIN).FR
    if (((struct(unitIN).FR > .0))) %%&& struct(unitIN).channel < 92) && struct(unitIN).channel > 29)
      
    
        %FRstructLimits(struct, 30, [0 6500], unit);
        %xline(3108, 'b');
        %xline(3840, 'r');
        %xline(5338, 'm');
        
 % RasterMatrix = OrganizeRasterSpikesNew(struct, trigger, unit, -(xmin), xmax);
 %   xlim([xmin, xmax]);
    
   % fr = FRstruct(unit, struct, 30);
   % xline(1623, 'r');
    
   %[meanLine, EXClatency, INHlatency, respType] = GeneralHistForStructTimeLim1(trigger2, unitIN, struct, xmin, xmax, TimeLim, binsize, 'm');
    [meanLine, EXClatency, INHlatency, respType] = GeneralHistForStructTimeLim1(trigger, unitIN, struct, xmin, xmax, TimeLim, binsize, color);
 %RasterMatrix = OrganizeRasterSpikesNew(struct, trigger, unit, .2, 5);
   if ((~(isnan(EXClatency))) | (~(isnan(INHlatency))))
      respCells((unitCounter),1) =  struct(unitIN).unitID;
     respCells((unitCounter), 2) = struct(unitIN).channel;
     respCells((unitCounter), 3) = INHlatency;
     
       unitCounter = unitCounter + 1;
   end
       
  % if INHlatency < 5
    %   respCells = [respCells; unit]
   %    respLats = [respLats; EXClatency]
  % end
   
    %[FRate, FRrun, FRstop, r[clueporter] = FRstructRunNorun(ifrun, GoodUnitStruct, unit);
    hold on
    stunit = num2str(unit);                    % extract name/number of unit at index n (string that will be used in title of histogram)                         
   
    
    
    %stHz = num2str(Hz, '%.0f');
    channel_ = num2str(struct(unitIN).channel);
    %Depth = shallowToDeepGood(n,4);
    %stDepth = num2str(Depth);
    %title_ = strcat(stunit,', ', stDepth, ' deep, ', ',', stHz, ' Hz');   % make the title (can't get a space to show up after the comma)
    title_ = [stunit, ' on ', channel_];   % make the title (can't get a space to show up after the comma)
     if strcmp(struct(unitIN).group, 'mua')
        title_ = [stunit, ' on ', channel_, '; mua'];
     end

    if strcmp(struct(unitIN).group, 'good')
        title_ = [stunit, ' on ', channel_, '; good'];
    end
    if ~isnan(INHlatency)
        title_ = [title_ 'inhibited at' num2str(int16(INHlatency*1000))];
    end
    title(title_);
    
    %plot(B,trials, 'g');
    
    lineACSF = 200;
lineBlocker1 = 194;
%LaserPower1_5 = 84;
lineBlocker2 =283;
lineBlocker4 = 283;
Stim15ms = 309;
Stim50ms = 353;
    
    %yline(lineACSF, 'k');
    %yline(lineBlocker1, 'r');
    %yline(lineBlocker2, 'r');
    %yline(LaserPower1_5, 'm');
    %yline(lineBlocker4, 'k');
    %yline(Stim50ms, 'k');
    %yline(Stim15ms, 'k');
    xline(0, 'g');
    %xline(.699, 'b');
    FormatFigure
    hold off
    end
    
 
    %GeneralHistForStruct(FirstJuiceAdj, unit, GoodUnitStruct, -5, 5, .1, 'b');
    %GeneralHistForStruct(NoJuiceAdj, unit, GoodUnitStruct, -5, 5, .1, 'r');
    
    counterStr = num2str(figurecounter);
      filename_ = [title_ basename ];
      
      if saveBoo == 1
      saveas(gca, filename_);
      print(filename_, '-dpdf');
      end
     %saveas(gca, filename_, 'epsc');
    
     %respCells = [respCells respLats];
end
