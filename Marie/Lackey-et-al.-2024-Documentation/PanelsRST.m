binwidth = .01;

for n = 1:length(MLIs)
for k = 1:length(MLIs(n).MLI_PC_Summary)
if isempty([RecordingList(MLIs(n).RecorNum).LaserStimAdj])
[N, edges] = XcorrFastINDEX(SumSt, -.02, .02, binwidth, MLIs(n).MLI_PC_Summary(k).SSindex, MLIs(n).MLI_PC_Summary(k).MLIindex, 0, inf, 'k', 0, SD, 0);
else
[N, edges] = XcorrFastINDEX(SumSt, -.02, .02, binwidth,  MLIs(n).MLI_PC_Summary(k).SSindex, MLIs(n).MLI_PC_Summary(k).MLIindex, 0, RecordingList(MLIs(n).RecorNum).LaserStimAdj(1), 'k', 0, SD, 0);
end
MLIs(n).PC_MLI(k).MLIindex = MLIs(n).MLI_PC_Summary(k).MLIindex;
MLIs(n).PC_MLI(k).SSindex = MLIs(n).MLI_PC_Summary(k).SSindex;
MLIs(n).PC_MLI(k).MLIs_dist = MLIs(n).MLI_PC_Summary(k).MLI_PC_dist;
MLIs(n).PC_MLI(k).N = N;
MLIs(n).PC_MLI(k).edges = edges;

end
end

MLIsA = MLIs(strcmp({MLIs.Type}, 'A'));
MLIsB = MLIs(strcmp({MLIs.Type}, 'B'));



for n = 1:length(MLIsA)
    if ~isempty(MLIsA(n).AllLicksAdj)
    [MLIsA(n).LickingOnset_three MLIsA(n).LickingEpoch_second] = FindLickOnsets_epochs(MLIsA(n).AllLicksAdj, 1, .3, 3);
    end
end
for n = 1:length(MLIsB)
    if ~isempty(MLIsB(n).AllLicksAdj)
    MLIsB(n).LickingOnset_three = FindLickOnsets_epochs(MLIsB(n).AllLicksAdj, 1, .3, 3);
    end
end



close all
cA = 1;
for n = 1:length(MLIsA)
    figure
    hold on
    for k = 1:length(MLIsA(n).MLI_PC_Summary)
        [N, edges] = OneUnitHistStructTimeLimLineINDEX([MLIsA(n).LickingOnset_three], MLIsA(n).PC_MLI(k).MLIindex, SumSt, -.2, 1, .01, [0 inf], SD, 'm', NaN, 1, 0);
        if MLIsA(n).MLI_PC_Summary(k).MLI_PC_dist < 125
            [N, edges] = OneUnitHistStructTimeLimLineINDEX([MLIsA(n).LickingOnset_three], MLIsA(n).PC_MLI(k).SSindex, SumSt, -.2, 1, .01, [0 inf], SD, 'b', NaN, 1, 0);
            cA = cA + 1;
            % else
            %     [N, edges] = OneUnitHistStructTimeLimLineINDEX([MLIsA(n).LickingOnset_three], MLIsA(n).PC_MLI(k).SSindex, SumSt, -.2, 1, .01, [0 inf], SD, 'y', NaN, 1, 0);
        end
    end
end
close all

cA = 1;
for n = 1:length(MLIsB)
    figure
    hold on
    for k = 1:length(MLIsB(n).MLI_PC_Summary)
        [N, edges] = OneUnitHistStructTimeLimLineINDEX([MLIsB(n).LickingOnset_three], MLIsB(n).PC_MLI(k).MLIindex, SumSt, -.2, 1, .01, [0 inf], SD, 'g', NaN, 1, 0);
        if MLIsB(n).MLI_PC_Summary(k).MLI_PC_dist < 125
            [N, edges] = OneUnitHistStructTimeLimLineINDEX([MLIsB(n).LickingOnset_three], MLIsB(n).PC_MLI(k).SSindex, SumSt, -.2, 1, .01, [0 inf], SD, 'b', NaN, 1, 0);
            cA = cA + 1;
            % else
            %     [N, edges] = OneUnitHistStructTimeLimLineINDEX([MLIsB(n).LickingOnset_three], MLIsB(n).PC_MLI(k).SSindex, SumSt, -.2, 1, .01, [0 inf], SD, 'y', NaN, 1, 0);
        end
    end
end


clear LickModAct_UpDown
clear Mod
clear ModUniquePC
clear ModUniqueMLI
clear N_lick

%delete LickModAct_UpDown and Mod and ModUniquePC, ModUniqueMLI, N_lick, 
%in this file, PC is MLIA and MLIA is MLIB. <-- I don't think this is
%right, but leaving it here just in case

for n = 1:length(MLIsA)
if ~isempty(MLIsA(n).AllLicksAdj)
[MLIsA(n).LickingOnset_three, MLIsA(n).LickingSecond, MLIsA(n).LickingThird] = FindLickOnsets_epochs(MLIsA(n).AllLicksAdj, 1, .3, 3);
MLIsA(n).LickingFirst = [MLIsA(n).LickingOnset_three] - [MLIsA(n).LickingOnset_three];
% MLIsA(n).LickingSecond = [MLIsA(n).LickingSecond] - [MLIsA(n).LickingOnset_three];
% MLIsA(n).LickingThird = [MLIsA(n).LickingThird] - [MLIsA(n).LickingOnset_three];
end
end


binw = .01;
minW = -.2;
maxW = .4;
SD = 11;
counter = 1;
counterLM = 1;
peakfinderWindow = [-.1 .1];
minInh = 25;
shiftWindow = (peakfinderWindow(2) - peakfinderWindow(1))/binw;
minProm = 30;
maxpeakWidth = 15;
close all
counterLM = 1;
for n = 1:length(MLIsA)
    if isempty([MLIsA(n).LaserStimAdj])
        for k = 1:length(MLIsA(n).PC_MLI)
            if MLIsA(n).MLI_PC_Summary(k).inhBoo4SD == 1
                %if MLIsA(n).MLI_PC_Summary(k).inhEnd > .002
                %if MLIsA(n).MLI_PC_Summary(k).lat < .001
                %if MLIsA(n).MLI_PC_Summary(k).SpPerSecInh > 25
                [Nmli, edges] = OneUnitHistStructTimeLimLineINDEX([MLIsA(n).LickingOnset_three], MLIsA(n).PC_MLI(1).MLIindex, SumSt, minW, maxW, binw, [0 inf], SD, 'm', NaN, 0, 0);
                [~,startI] = ismembertol(peakfinderWindow(1),edges,0.0001);
                [~, endI] = ismembertol(peakfinderWindow(2),edges,0.0001);
                [~, zeroI] = ismembertol(0,edges,0.0001);
%                 figure
%                 nexttile
%                 hold on
%                 plot(edges(1:end-1), Nmli, 'm');
                Nmli = smoothdata(Nmli, 'sgolay', 7);
%                 plot(edges(1:end-1), Nmli, 'm');
                [Npc, edges] = OneUnitHistStructTimeLimLineINDEX([MLIsA(n).LickingOnset_three], MLIsA(n).PC_MLI(k).SSindex, SumSt, minW, maxW, binw, [0 inf], SD, 'm', NaN, 0, 0);
%                 plot(edges(1:end-1), Npc, 'b');
                Npc = smoothdata(Npc, 'sgolay', 7);
%                 plot(edges(1:end-1), Npc, 'b');
               
                %compute single side amp spect of fft
                Fs = 1/binw;            % Sampling frequency
                T = 1/Fs;             % Sampling period
                L = length(Npc);             % Length of signal
                t = (0:L-1)*T;        % Time vector
                Y = fft(Npc);
                P2 = abs(Y/L);
                P1 = P2(1:L/2+1);
                P1(2:end-1) = 2*P1(2:end-1);
                f = Fs*(0:(L/2))/L;
                
                if P1(6) > 10
                %if P1(6)/sum(P1) > .05
                    LickModAct_UpDown(counterLM).SingleSideAmpSpect_pc = P1;
                    LickModAct_UpDown(counterLM).SingleSideAmpSpect_edges_pcn = f;
                    
%                     [UpDownN, UpDownEdges] = OneUnitHistStructTimeLimLineINDEX([MLIsA(n).LickingOnset_three], MLIsA(n).PC_MLI(k).SSindex, SumSt, -1.5, .5, binw, [0 inf], SD, 'm', NaN, 0, 0);
%                     UpDownN = smoothdata(UpDownN, 'sgolay', 7);
                    %testing here
                    UpDownN = Npc;
                    UpDownEdges = edges;
                    [pks, locs, wid, prom] = findpeaks(UpDownN, 'MinPeakProminence', minProm, 'MaxPeakWidth', maxpeakWidth);
                    [pks_ng, locs_ng, wid_ng, prom_ng] = findpeaks(-UpDownN, 'MinPeakProminence', minProm, 'MaxPeakWidth', maxpeakWidth);
                    
                    locs = locs(locs > startI);
                    locs = locs(locs < endI);
                    if ~isempty(locs)
                    LickModAct_UpDown(counterLM).PeakI = locs(1);
                    end
                    locs_ng = locs_ng(locs_ng > startI);
                    locs_ng = locs_ng(locs_ng < endI);
                    if ~isempty(locs_ng)
                    LickModAct_UpDown(counterLM).TroughI = locs_ng(1);
                    end
%                     figure
%                     hold on
%                      plot(UpDownEdges(1:end-1), UpDownN, 'k');
%                      scatter(UpDownEdges(locs), UpDownN(locs))
%                      scatter(UpDownEdges(locs_ng), UpDownN(locs_ng))
                     
                     if isempty(locs) & ~isempty(locs_ng)
                         LickModAct_UpDown(counterLM).UpDown = 'down';
                     end
                     if isempty(locs_ng) & ~isempty(locs)
                         LickModAct_UpDown(counterLM).UpDown = 'up';
                     end
                     
                     if ~isempty(locs) & ~isempty(locs_ng)
                         LickModAct_UpDown(counterLM).PeakI = locs(1);
                         LickModAct_UpDown(counterLM).TroughI = locs_ng(1);
                     if locs(1) < locs_ng(1)
                         LickModAct_UpDown(counterLM).UpDown = 'up';
                     elseif locs(1) > locs_ng(1)
                        LickModAct_UpDown(counterLM).UpDown = 'down';
                     end
                     end
%                      title([LickModAct_UpDown(counterLM).UpDown]);
                     
                     
                     
                     
                     

                indexShiftPeak = LickModAct_UpDown(counterLM).PeakI - zeroI;
                indexShiftTrough = LickModAct_UpDown(counterLM).TroughI - zeroI;
%                 scatter(edges(PeakI), Peak, 'x')
%                 plot(edges(1:end-1)-indexShift*binw, Npc, 'k', 'Linewidth', 2);
                LickModAct_UpDown(counterLM).Nmli = Nmli;
                LickModAct_UpDown(counterLM).Npc = Npc;
                %[LickModAct_UpDown(counterLM).XcorrC, LickModAct_UpDown(counterLM).XcorrLags] = xcorr(Nmli, Npc);
                LickModAct_UpDown(counterLM).Nmli_z = zscore(Nmli);
                LickModAct_UpDown(counterLM).Npc_z = zscore(Npc);
                LickModAct_UpDown(counterLM).Nmli_normPeak = Nmli/max(Nmli);
                LickModAct_UpDown(counterLM).Npc_normPeak = Npc/max(Npc);
                LickModAct_UpDown(counterLM).Nmli_norm = Nmli/mean(Nmli(1:10));
                LickModAct_UpDown(counterLM).Npc_norm = Npc/mean(Npc(1:10));
                LickModAct_UpDown(counterLM).Norm_PC_minus_MLI = LickModAct_UpDown(counterLM).Npc_norm -  LickModAct_UpDown(counterLM).Nmli_norm;
                LickModAct_UpDown(counterLM).PC_minus_MLI = LickModAct_UpDown(counterLM).Npc - LickModAct_UpDown(counterLM).Nmli;
                LickModAct_UpDown(counterLM).z_PC_minus_MLI = LickModAct_UpDown(counterLM).Npc_z -  LickModAct_UpDown(counterLM).Nmli_z;
                LickModAct_UpDown(counterLM).edges = edges;
                LickModAct_UpDown(counterLM).MLIindex = MLIsA(n).PC_MLI(1).MLIindex;
                LickModAct_UpDown(counterLM).PCindex = MLIsA(n).PC_MLI(k).SSindex;
                LickModAct_UpDown(counterLM).RecorNum = MLIsA(n).RecorNum;
                LickModAct_UpDown(counterLM).channel = MLIsA(n).channel;
%                 LickModAct_UpDown(counterLM).BrReg = MLIsA(n).BrReg;
                LickModAct_UpDown(counterLM).indexShiftPeak = indexShiftPeak;
                LickModAct_UpDown(counterLM).indexShiftTrough = indexShiftTrough;
                LickModAct_UpDown(counterLM).AllLicksAdj = MLIsA(n).AllLicksAdj;
                LickModAct_UpDown(counterLM).LickingOnset_three = MLIsA(n).LickingOnset_three;
                LickModAct_UpDown(counterLM).LickingSecond = MLIsA(n).LickingSecond;
                LickModAct_UpDown(counterLM).LickingThird = MLIsA(n).LickingThird;
                LickModAct_UpDown(counterLM).LickingFirst = MLIsA(n).LickingFirst;




                [c, lags] = xcorr(Nmli(20:60), Npc(20:60), 'normalized');
                [~, i] = max(c);
                Lag = lags(i)*binw;
%                 Cr = c(i);
%                 [c_inv, lags_inv] = xcorr(Nmli, -Npc, 'normalized');
%                 [~, i_inv] = max(c_inv);
%                 Lag_inv = lags(i_inv)*binw;
%                 Cr_inv = c(i_inv);
% %                 legend({['lag is ' (num2str(Lag)) ', c=' (num2str(Cr))]})
% %                 Lags(counter) = Lag;
% %                 counter = counter +1;

                [c, lags] = xcorr(Nmli(20:60)/mean(Nmli(1:10)), Npc(20:60)/mean(Npc(1:10)), 'normalized');
                [~, i] = max(c);
                Lag_norm = lags(i)*binw;
                
                [c, lags] = xcorr(zscore(Nmli(20:60)), zscore(Npc(20:60)), 'normalized');
                [~, i] = max(c);
                Lag_z = lags(i)*binw; 
                
                LickModAct_UpDown(counterLM).Lag = Lag;
                LickModAct_UpDown(counterLM).Lag_norm = Lag_norm;
                LickModAct_UpDown(counterLM).Lag_z = Lag_z;
                
                % nexttile
                % plot(f,P1)
                
                   counterLM = counterLM + 1; 
               % end
            end
        end
        end
    end

end
    
%unique Run these top four lines again
[C, ia, ic] = unique([LickModAct_UpDown.PCindex]);
ModUniquePC_UpDown = LickModAct_UpDown(ia);
 [C, ia, ic] = unique([LickModAct_UpDown.MLIindex]);
ModUniqueMLI_UpDown = LickModAct_UpDown(ia);

figure
nexttile
hold on
shadedErrorBar2([ModUniquePC_UpDown(1).edges(1:end-1)], nanmean(cell2mat({ModUniquePC_UpDown.Npc_norm}.')), std(cell2mat({ModUniquePC_UpDown.Npc_norm}.'))/sqrt(size(cell2mat({ModUniquePC_UpDown.Npc_norm}.'),1)), 'lineProp', 'k');
shadedErrorBar2([ModUniquePC_UpDown(1).edges(1:end-1)], nanmean(cell2mat({ModUniqueMLI_UpDown.Nmli_norm}.')), std(cell2mat({ModUniqueMLI_UpDown.Nmli_norm}.'))/sqrt(size(cell2mat({ModUniqueMLI_UpDown.Nmli_norm}.'),1)), 'lineProp', 'm');
xlabel('time from lick onset')
ylabel('norm');
% FigureWrap('ModPC withMLIA lickOnset', 'ModPC_withMLIA_lickOnset_norm', NaN, NaN, NaN, NaN);


%add licking psth
N_lick = [];
for n = 1:length(LickModAct_UpDown)
    [N_lick(n,:), edges_lick]= LickHist(LickModAct_UpDown(n).LickingOnset_three, LickModAct_UpDown(n).AllLicksAdj, [-.2 .4], .01, 'k', 0);
end
nexttile
hold on
shadedErrorBar2([edges_lick(1:end-1)], nanmean([N_lick])./100, std(N_lick)/sqrt(size(N_lick,1))./100, 'lineProp', 'c');
% FigureWrap('Lick Detection APC', 'Lick_Detection_APC', NaN, NaN, NaN, NaN);



% delete LickModAct and Mod and ModUniquePC, ModUniqueMLI
clear LickModAct
clear Mod
clear ModUniqueMLI
clear ModUniquePC

for n = 1:length(MLIsB)
if ~isempty(MLIsB(n).AllLicksAdj)
[MLIsB(n).LickingOnset_three, MLIsB(n).LickingSecond, MLIsB(n).LickingThird] = FindLickOnsets_epochs(MLIsB(n).AllLicksAdj, 1, .3, 3);
MLIsB(n).LickingFirst = [MLIsB(n).LickingOnset_three] - [MLIsB(n).LickingOnset_three];
% MLIsB(n).LickingSecond = [MLIsB(n).LickingSecond] - [MLIsB(n).LickingOnset_three];
% MLIsB(n).LickingThird = [MLIsB(n).LickingThird] - [MLIsB(n).LickingOnset_three];
end
end


binw = .01;
minW = -.2;
maxW = .4;
SD = 4;
counter = 1;
counterLM = 1;
peakfinderWindow = [-.1 .1];
close all
for n = 1:length(MLIsB)
    if isempty([MLIsB(n).LaserStimAdj])
    for k = 1:length(MLIsB(n).MLI_MLI_InhSummary)
        if MLIsB(n).MLI_MLI_InhSummary(k).inhBoo4SD == 1
        [Nmli, edges] = OneUnitHistStructTimeLimLineINDEX([MLIsB(n).LickingOnset_three], MLIsB(n).MLI_MLI_InhSummary(1).indexDrive, SumSt, minW, maxW, binw, [0 inf], SD, 'm', NaN, 0, 0);
        [~,startI] = ismembertol(peakfinderWindow(1),edges,0.0001);
        [~, endI] = ismembertol(peakfinderWindow(2),edges,0.0001);
        [~, zeroI] = ismembertol(0,edges,0.0001);
%          figure
%          nexttile
%          hold on
%         plot(edges(1:end-1), Nmli, 'm');
        Nmli = smoothdata(Nmli, 'sgolay', 7);
%          plot(edges(1:end-1), Nmli, 'm');
         [Npc, edges] = OneUnitHistStructTimeLimLineINDEX([MLIsB(n).LickingOnset_three], MLIsB(n).MLI_MLI_InhSummary(k).indexFollow, SumSt, minW, maxW, binw, [0 inf], SD, 'm', NaN, 0, 0);
%          plot(edges(1:end-1), Npc, 'b');
         Npc = smoothdata(Npc, 'sgolay', 7);
%          plot(edges(1:end-1), Npc, 'b');
        [Peak, PeakI] = max(Npc(startI:endI));
        PeakI = PeakI+startI-1; %adjust into corrdinates for the plot
        indexShift = PeakI - zeroI;
%          scatter(edges(PeakI), Peak, 'x')
%         plot(edges(1:end-1)-indexShift*binw, Npc, 'k', 'Linewidth', 2);

        
[c, lags] = xcorr(Nmli(20:60), Npc(20:60), 'normalized');
[~, i] = max(c);
Lag = lags(i)*binw;

[c, lags] = xcorr(Nmli(20:60)/mean(Nmli(1:10)), Npc(20:60)/mean(Npc(1:10)), 'normalized');
[~, i] = max(c);
Lag_norm = lags(i)*binw;

[c, lags] = xcorr(zscore(Nmli(20:60)), zscore(Npc(20:60)), 'normalized');
[~, i] = max(c);
Lag_z = lags(i)*binw;



Fs = 1/binw;            % Sampling frequency                    
T = 1/Fs;             % Sampling period       
L = length(Npc);             % Length of signal
t = (0:L-1)*T;        % Time vector
Y = fft(Npc);

P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);

f = Fs*(0:(L/2))/L;
        

        
        if P1(6)/sum(P1) > .05
            
        LickModAct(counterLM).Lag = Lag;
        LickModAct(counterLM).Lag_norm = Lag_norm;
        LickModAct(counterLM).Lag_z = Lag_z;
        LickModAct(counterLM).Nmli = Nmli;
        LickModAct(counterLM).Npc = Npc;
        LickModAct(counterLM).Nmli_z = zscore(Nmli);
        LickModAct(counterLM).Npc_z = zscore(Npc);
        LickModAct(counterLM).Nmli_norm = Nmli/mean(Nmli(1:10));
        LickModAct(counterLM).Npc_norm = Npc/mean(Npc(1:10));
        LickModAct(counterLM).Norm_PC_minus_MLI = LickModAct(counterLM).Npc_norm - LickModAct(counterLM).Nmli_norm;
        LickModAct(counterLM).z_PC_minus_MLI = LickModAct(counterLM).Npc_z - LickModAct(counterLM).Nmli_z;
        LickModAct(counterLM).edges = edges;
        LickModAct(counterLM).LickingOnset_three = MLIsB(n).LickingOnset_three;
        LickModAct(counterLM).AllLicksAdj = MLIsB(n).AllLicksAdj;
        LickModAct(counterLM).PCpeakI = PeakI;
        LickModAct(counterLM).indexDrive = MLIsB(n).MLI_MLI_InhSummary(1).indexDrive;
        LickModAct(counterLM).PCindex = MLIsB(n).MLI_MLI_InhSummary(k).indexFollow;
        LickModAct(counterLM).RecorNum = MLIsB(n).RecorNum;
        LickModAct(counterLM).channel = MLIsB(n).channel;
%         LickModAct(counterLM).BrReg = MLIsB(n).BrReg;
        LickModAct(counterLM).indexShift = indexShift;
        LickModAct(counterLM).SingleSideAmpSpect_pc = P1;
        LickModAct(counterLM).SingleSideAmpSpect_edges_pcn = f;
        counterLM = counterLM + 1;

%  nexttile
%  plot(f,P1/sum(P1)) 
%  
% if P1(6)/sum(P1) <= .05
%      close
%  end
       end
        end
    end
    end
end
   

maxShift = max([LickModAct.indexShift]);
minShift = min([LickModAct.indexShift]);
maxShift = max([maxShift, abs(minShift)]);


counter = 1;
for n = 1:length(LickModAct)
   % if LickModAct(n).SingleSideAmpSpect_pc(6) > 10
        LickModAct(n).edgesShift = LickModAct(n).edges(1:end-1)-LickModAct(n).indexShift*binw;
        delta1 = [shiftWindow - LickModAct(n).indexShift];
        delta2 = [shiftWindow + LickModAct(n).indexShift];
        %if indexShift > 0
        LickModAct(n).Npc_shift = [zeros(1,delta1).'; LickModAct(n).Npc.'; zeros(1,delta2).'];
        LickModAct(n).Nmli_shift = [zeros(1,delta1).'; LickModAct(n).Nmli.'; zeros(1,delta2).'];
         LickModAct(n).Npc_shift =  LickModAct(n).Npc_shift((shiftWindow + maxShift):(end - shiftWindow - maxShift));
         LickModAct(n).Nmli_shift = LickModAct(n).Nmli_shift((shiftWindow + maxShift):(end - shiftWindow - maxShift));
%         end
%         if indexShift < 0
%         LickModAct(n).Npc_shift = [LickModAct(n).Npc.'; zeros(1,LickModAct(n).indexShift).'];
%         end
        counter = counter + 1;
%        plot([LickModAct(n).edges(maxShift:end-1-maxShift)], LickModAct(n).Npc_shift, 'k', 'Linewidth', 2);
%         plot([LickModAct(n).edges(maxShift:end-1-maxShift)], LickModAct(n).Nmli_shift, 'm', 'Linewidth', 2);
%    %plot(LickModAct(n).edges(1:end-1)-LickModAct(n).indexShift*binw, LickModAct(n).Npc, 'k', 'Linewidth', 2);
  %end
end

%unique 
[C, ia, ic] = unique([LickModAct.PCindex]);
ModUniquePC = LickModAct(ia);
 [C, ia, ic] = unique([LickModAct.indexShift]);
ModUniqueMLI = LickModAct(ia);

%  figure
% hold on
% shadedErrorBar2([ModUniquePC(1).edges(1:end-1)], nanmean(cell2mat({ModUniquePC.Npc}.')), std(cell2mat({ModUniquePC.Npc}.'))/sqrt(size(cell2mat({ModUniquePC.Npc}.'),1)), 'lineProp', 'm');
% shadedErrorBar2([ModUniquePC(1).edges(1:end-1)], nanmean(cell2mat({ModUniqueMLI.Nmli}.')), std(cell2mat({ModUniqueMLI.Nmli}.'))/sqrt(size(cell2mat({ModUniqueMLI.Nmli}.'),1)), 'lineProp', 'g');
% xlabel('time from lick onset')
% ylabel('sp/');
% figure
% hold on
% shadedErrorBar2([ModUniquePC(1).edges(1:end-1)], nanmean(cell2mat({ModUniquePC.Npc_z}.')), std(cell2mat({ModUniquePC.Npc_z}.'))/sqrt(size(cell2mat({ModUniquePC.Npc_z}.'),1)), 'lineProp', 'm');
% shadedErrorBar2([ModUniquePC(1).edges(1:end-1)], nanmean(cell2mat({ModUniqueMLI.Nmli_z}.')), std(cell2mat({ModUniqueMLI.Nmli_z}.'))/sqrt(size(cell2mat({ModUniqueMLI.Nmli_z}.'),1)), 'lineProp', 'g');
% xlabel('time from lick onset')
% ylabel('z-score');
% % FigureWrap('ModMLIA withMLIB lickOnset', 'ModMLIA_withMLIB_lickOnset', 'time from lick onset (s)', 'zscore', NaN, NaN);
% 
figure
nexttile
hold on
shadedErrorBar2([ModUniquePC(1).edges(1:end-1)], nanmean(cell2mat({ModUniquePC.Npc_norm}.')), std(cell2mat({ModUniquePC.Npc_norm}.'))/sqrt(size(cell2mat({ModUniquePC.Npc_norm}.'),1)), 'lineProp', 'm');
shadedErrorBar2([ModUniquePC(1).edges(1:end-1)], nanmean(cell2mat({ModUniqueMLI.Nmli_norm}.')), std(cell2mat({ModUniqueMLI.Nmli_norm}.'))/sqrt(size(cell2mat({ModUniqueMLI.Nmli_norm}.'),1)), 'lineProp', 'g');
xlabel('time from lick onset')
ylabel('norm');
% FigureWrap('ModMLIA withMLIB lickOnset', 'ModMLIA_withMLIB_lickOnset_norm', NaN, NaN, NaN, NaN);

N_lick = [];
for n = 1:length(LickModAct)
    [N_lick(n,:), edges_lick]= LickHist(LickModAct(n).LickingOnset_three, LickModAct(n).AllLicksAdj, [-.2 .4], .01, 'k', 0);
end
nexttile
hold on
shadedErrorBar2([edges_lick(1:end-1)], nanmean([N_lick])./100-1, std(N_lick)/sqrt(size(N_lick,1))./100, 'lineProp', 'c');
% FigureWrap('lick detection frequency AB', 'lick_detection_liklihood_AB', NaN, NaN, NaN, NaN);







% figure
% hold on
% % plot(ModUniqueMLI(3).edges(1:end-1), ModUniqueMLI(3).Nmli_n, 'g')
% plot(ModUniqueMLI(3).edges(1:end-1), ModUniqueMLI(3).Npc_z, 'm')
% plot(ModUniqueMLI_UpDown(2).edges(1:end-1), ModUniqueMLI_UpDown(2).Nmli_z, 'm')
% plot(ModUniqueMLI_UpDown(2).edges(1:end-1), ModUniqueMLI_UpDown(2).Npc_z, 'k')
% % FigureWrap('MLIB, MLIA, and PC lickOnset', 'MLIB_MLIA_PC_lickOnset', 'time from lick onset (s)', 'zscore', NaN, NaN);
% 

figure
nexttile
hold on
plot(ModUniqueMLI(3).edges(1:end-1), ModUniqueMLI(3).Nmli_norm, 'g')
plot(ModUniqueMLI(3).edges(1:end-1), ModUniqueMLI(3).Npc_norm, 'm')
plot(ModUniqueMLI_UpDown(2).edges(1:end-1), ModUniqueMLI_UpDown(2).Nmli_norm, 'm')
plot(ModUniqueMLI_UpDown(2).edges(1:end-1), ModUniqueMLI_UpDown(2).Npc_norm, 'k')
% FigureWrap('MLIB, MLIA, and PC lickOnset norm', 'MLIB_MLIA_PC_lickOnset_norm', 'time from lick onset (s)', 'norm', NaN, NaN);

N_lick = [];
    [N_lick(1,:), edges_lick]= LickHist(ModUniqueMLI_UpDown(2).LickingOnset_three, ModUniqueMLI_UpDown(2).AllLicksAdj, [-.2 .4], .01, 'k', 0);
nexttile
hold on
plot(edges_lick(1:end-1), N_lick(1,:), 'c');
% FigureWrap('Lick Detection 3 cell', 'Lick_Detection_3cell', NaN, NaN, NaN, NaN);

