figure
tiledlayout('flow');
%for %n=1:length([GoodUnitStruct.unitID])%length(AboutOneHz)%length([GoodUnitStruct.unitID])
 for   n = 1:length(AllUnits)
    if find(divisors(n) == 50)
       figure
        tiledlayout('flow');
    
    end
    nexttile
    %unitIN = n;
    unit = AllUnits(n,1);
    %unit = granUnsort(n,1);
    unitIN = find([AllUnitStruct.unitID] == unit);
    %Hz = GeneralHistForStructTimeLim(LaserStimAdj, unitIN, AllUnitStructUnSort, -.2, .2, .001, 'k');
 
    Hz = GeneralHistForStructTimeLim(LaserStim1, unitIN, AllUnitStruct, -.05, .05, [0 inf], .001, 'k');
    %[FRate, FRrun, FRstop, r[clueporter] = FRstructRunNorun(ifrun, GoodUnitStruct, unit);
    hold on
    stunit = num2str(unit);                    % extract name/number of unit at index n (string that will be used in title of histogram)                         
    %stHz = num2str(Hz, '%.0f');
    channel_ = num2str(AllUnitStruct(unitIN).channel);
    %Depth = shallowToDeepGood(n,4);
    %stDepth = num2str(Depth);
    %title_ = strcat(stunit,', ', stDepth, ' deep, ', ',', stHz, ' Hz');   % make the title (can't get a space to show up after the comma)
    title_ = ['Unit ', stunit, ' on CH ', channel_];   % make the title (can't get a space to show up after the comma)
    title(title_);
    FormatFigure
    %GeneralHistForStruct(FirstJuiceAdj, unit, GoodUnitStruct, -5, 5, .1, 'b');
    %GeneralHistForStruct(NoJuiceAdj, unit, GoodUnitStruct, -5, 5, .1, 'r');
end
