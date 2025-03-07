binw = .01;
minW = -.2;
maxW = .4;
SD = 10;
counter = 1;
counterLM = 1;
peakfinderWindow = [-.1 .1];
shiftWindow = (peakfinderWindow(2) - peakfinderWindow(1))/binw;

figure

for n = 1:length(SS)
         %   if MLIsA(n).MLI_PC_Summary(k).inhEnd > .002 %remove this to remove chemical-only
        
         [Npc, edges] = OneUnitHistStructTimeLimLineINDEX([RecordingList(SS(n).RecorNum).EpochOnsets], n, SS, minW, maxW, binw, [0 inf], SD, 'm', NaN, 0, 0);
        %plot(edges(1:end-1), Npc, 'b');
         [~,startI] = ismembertol(peakfinderWindow(1),edges,0.0001);
        [~, endI] = ismembertol(peakfinderWindow(2),edges,0.0001);
        [~, zeroI] = ismembertol(0,edges,0.0001);
         Npc = smoothdata(Npc, 'sgolay', 7);
        %plot(edges(1:end-1), Npc, 'm');
        [Peak, PeakI] = max(Npc(startI:endI));
        PeakI = PeakI+startI-1; %adjust into corrdinates for the plot
        indexShift = PeakI - zeroI;
        scatter(edges(PeakI), Peak, 'x')
        plot(edges(1:end-1)-indexShift*binw, Npc, 'k', 'Linewidth', 2);
%         LickCycleModAct(counterLM).Nmli = Nmli;
%         LickCycleModAct(counterLM).Npc = Npc;
%         LickCycleModAct(counterLM).edges = edges;
%         LickCycleModAct(counterLM).PCpeakI = PeakI;
%         LickCycleModAct(counterLM).MLIindex = MLIsA(n).PC_MLI(1).MLIindex;
%         LickCycleModAct(counterLM).PCindex = MLIsA(n).PC_MLI(k).SSindex;
%         LickCycleModAct(counterLM).RecorNum = MLIsA(n).RecorNum;
%         LickCycleModAct(counterLM).channel = MLIsA(n).channel;
%         LickCycleModAct(counterLM).BrReg = MLIsA(n).BrReg;
%         LickCycleModAct(counterLM).indexShift = indexShift;
        

        
% [c, lags] = xcorr(Nmli, Npc, 'normalized');
% [~, i] = max(c);
% Lag = lags(i)*binw;
% Cr = c(i);
% [c_inv, lags_inv] = xcorr(Nmli, -Npc, 'normalized');
% [~, i_inv] = max(c_inv);
% Lag_inv = lags(i_inv)*binw;
% Cr_inv = c(i_inv);
% legend({['lag is ' (num2str(Lag)) ', c=' (num2str(Cr))]})
% Lags(counter) = Lag;
% counter = counter +1;
% 
%         LickCycleModAct(counterLM).Lag = Lag;

Fs = 1/binw;            % Sampling frequency                    
T = 1/Fs;             % Sampling period       
L = length(Npc);             % Length of signal
t = (0:L-1)*T;        % Time vector
Y = fft(Npc);

P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);

f = Fs*(0:(L/2))/L;
        

        LickCycleModAct(counterLM).SingleSideAmpSpect_pc = P1;
        LickCycleModAct(counterLM).SingleSideAmpSpect_edges_pcn = f;
        counterLM = counterLM + 1;

nexttile
plot(f,P1) 
 
if P1(6) < 10 
     close
     SS(n).LickCycleMod = false;
else
    SS(n).LickCycleMod = true;
end
            %end %remove one of these if removing chemical or ephaptic only criteria
end
