function [INHcells, EXCcells, RespCellsStruct] = LoopPSTHresp(list, struct, trigger,  xmin, xmax, TimeLim, binsize, color, basename, StDev) %B, trials); %trigger2,
%basename is a string

MinFire =0;
saveBoo = 1;


INHcounter = 1;
EXCcounter = 1;

 for   n = 1:length(list)
      figure
      hold on
    unit = list(n,1);
    unitIN = find([struct.unitID] == unit)
    if strcmp(struct(unitIN).group, 'mua')
        color = 'b';
    end
   
    struct(unitIN).FR
    if (((struct(unitIN).FR > MinFire))) %%&& struct(unitIN).channel < 92) && struct(unitIN).channel > 29)
      
        %FRstructLimits(struct, 30, [0 6500], unit);
        %xline(3108, 'b');
        %xline(3840, 'r');
        %xline(5338, 'm');
        
 % RasterMatrix = OrganizeRasterSpikesNew(struct, trigger, unit, -(xmin), xmax);
 %   xlim([xmin, xmax]);
    
   % fr = FRstruct(unit, struct, 30);
   % xline(1623, 'r');
   %[meanLine, EXClatency, INHlatency, respType] = GeneralHistForStructTimeLim1(trigger2, unitIN, struct, xmin, xmax, TimeLim, binsize, 'm');
    [meanLine, EXClatency, INHlatency, respType] = GeneralHistForStructTimeLim1(trigger, unitIN, struct, xmin, xmax, TimeLim, binsize, color, StDev);
 %RasterMatrix = OrganizeRasterSpikesNew(struct, trigger, unit, .2, 5);
      struct(unitIN).LaserEXC = NaN;
      struct(unitIN).LaserINH = NaN;
     if ~isnan(INHlatency)
            INHcells((INHcounter),1) =  struct(unitIN).unitID;
            INHcells((INHcounter),2) =  INHlatency *1000;
            struct(unitIN).LaserINH = 1;
            INHcounter = INHcounter + 1;
      end
      if ~isnan(EXClatency)
          EXCcells((EXCcounter),1) =  struct(unitIN).unitID;
          EXCcells((EXCcounter),2) =  EXClatency*1000;
          struct(unitIN).LaserEXC = 1;
            EXCcounter = EXCcounter + 1;
      end
   end
      struct(unitIN).EXClatency = EXClatency;
      struct(unitIN).INHlatency = INHlatency;
   
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
        title_ = ['LaserResp ' stunit, ' on ch', channel_,];
    end
    if ~isnan(INHlatency)
        title_ = ['LaserRespINH ' stunit, ' on ch', channel_, '_lat_' num2str(int16(INHlatency*1000))];
    end
    if ~isnan(EXClatency)
        title_ = ['LaserRespEXC ' stunit, ' on ch', channel_, '_lat_' num2str(int16(INHlatency*1000))];
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
    ylabel('Hz');
    xlabel('sec');
    plot([0 .1], [0 0], 'b', 'LineWidth', 2);
    
    hold off
    
      filename_ = [title_ basename ];
      
      if saveBoo == 1
      saveas(gca, filename_);
      print(filename_, '-depsc');
      end
    end
    
 
   RespCellsStruct = struct;
   if ~exist('INHcells', 'var')
       INHcells = [];
   end
   if ~exist('EXCcells', 'var')
       EXCcells = [];
   end
   
end
