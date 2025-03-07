figure
%tiledlayout('flow');
%for %n=1:length([GoodUnitStruct.unitID])%length(AboutOneHz)%length([GoodUnitStruct.unitID])

 for   n = 1:length(CSlist)
   % if find(divisors(n) == 50)
   %    figure
   %     tiledlayout('flow');
    
   % end
   % nexttile
    %unitIN = n;
    hold on
    unit = CSlist(n,1);
    %unit = granUnsort(n,1);
    unitIN = find([AllUnitStruct.unitID] == unit);
    %Hz = GeneralHistForStructTimeLim(LaserStimAdj, unitIN, AllUnitStructUnSort, -.2, .2, .001, 'k');
 %color = distinguishable_colors(15);
    [meanline, N, edges, stdevLine] =GeneralLineForStruct(RUNtoSTOP, unitIN, AllUnitStruct, -10, 20, TimeLim, .5, color(n,1:3));
%find mean baseline firing- number of bins to look at is pre-trigger time /
%binsize
    binNumsForMean = 10/.5;
    meanBaseline = mean(N(1:(binNumsForMean-1)));
    %normalN = ((N+1)/mean((N(1:19))+1)); %normalize firing
    changeFromBaselineInHz = N - meanBaseline;
    %RespLines(n, :) = normalN;
    RespLines(n, :) = changeFromBaselineInHz;
    %[FRate, FRrun, FRstop, r[clueporter] = FRstructRunNorun(ifrun, GoodUnitStruct, unit);
    hold on
    %stunit = num2str(unit);                    % extract name/number of unit at index n (string that will be used in title of histogram)                         
    %stHz = num2str(Hz, '%.0f');
    %Depth = shallowToDeepGood(n,4);
    %stDepth = num2str(Depth);
    %title_ = strcat(stunit,', ', stDepth, ' deep, ', ',', stHz, ' Hz');   % make the title (can't get a space to show up after the comma)
   % title_ = ['Unit ', stunit];   % make the title (can't get a space to show up after the comma)
    %title(title_);
    title('RUNtoSTOP')
    %GeneralHistForStruct(FirstJuiceAdj, unit, GoodUnitStruct, -5, 5, .1, 'b');
    %GeneralHistForStruct(NoJuiceAdj, unit, GoodUnitStruct, -5, 5, .1, 'r');
    
end
