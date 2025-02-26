figure
hold on
TrainBoo = 0;
SeparateFigures = 1;
counter = 1;
    
for n = 1:length(TypeSort)
        if SeparateFigures == 1
            figure
            hold on
        end
    Trial = rmmissingStruct(SortStruct([TypeSort(1).TrialStructAdj], 'RTt'));
    %Top = Trial([Trial.RTt]>prctile([Trial.RTt],80));
    Eighty = prctile([Trial.RTt],80)
    Sixty = prctile([Trial.RTt],60)
    Fourty = prctile([Trial.RTt],40)
    Twenty = prctile([Trial.RTt],20)
    RT = [Trial.RTt].';
    ToneTimes = [Trial.ToneTime].';
    
    Tier1 = ToneTimes(RT >Eighty);
    Tier2 = ToneTimes(RT >Sixty & RT<Eighty);
    Tier3 = ToneTimes(RT >Fourty & RT<Sixty);
    Tier4 = ToneTimes(RT >Twenty & RT<Fourty);
    Tier5 = ToneTimes(RT<Twenty);
    
    
    
    
    [N(counter,:), edges, L1] = OneUnitHistStructTimeLimLineINDEX(Tier1+ .682, n, TypeSort, -1, 4, .05, [0 inf], 4, 'r', NaN, 0);
    [N(counter,:), edges, L1] = OneUnitHistStructTimeLimLineINDEX(Tier2+ .682, n, TypeSort, -1, 4, .05, [0 inf], 4, 'y', NaN, 0);
    [N(counter,:), edges, L1] = OneUnitHistStructTimeLimLineINDEX(Tier3+ .682, n, TypeSort, -1, 4, .05, [0 inf], 4, 'c', NaN, 0);
    [N(counter,:), edges, L1] = OneUnitHistStructTimeLimLineINDEX(Tier4+ .682, n, TypeSort, -1, 4, .05, [0 inf], 4, 'b', NaN, 0);
    [N(counter,:), edges, L1] = OneUnitHistStructTimeLimLineINDEX(Tier5+ .682, n, TypeSort, -1, 4, .05, [0 inf], 4, 'k', NaN, 0);
     xline(-.682,'g');
     xline(max(RT)-.682, 'r')
      xline(Eighty-.682, 'y')
       xline(Sixty-.682, 'c')
        xline(Fourty-.682, 'b')
         xline(Twenty-.682, 'k')
          xline(min(RT)-.682, 'k')

    title([TypeSort(n).handID ' Trained = ' num2str(TypeSort(n).TrainBoo) ' at TypeSort Index ' num2str(n)])
    saveas(gca, [TypeSort(n).handID ' Trained = ' num2str(TypeSort(n).TrainBoo) ' at TypeSort Index ' num2str(n)])
   print([TypeSort(n).handID ' Trained = ' num2str(TypeSort(n).TrainBoo) ' at TypeSort Index ' num2str(n)], '-dpdf','-painters');
   print('SortByRTt', '-dpsc', '-bestfit', '-append');
end

