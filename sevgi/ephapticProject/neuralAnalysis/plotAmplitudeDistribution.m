%%%% Amplitude distribution for continuity of the isolation %%%%%%%%%%%%
% unit: its amplitudes to be plotted
% 
% SO 4/29/2024 Hull Lab
function plotAmplitudeDistribution(unit, recordingLengthSecs, laserOnsetTimes, laserOffsetTimes)
    globals;

    if isfield(unit,'spikeTimesOfAmplitudes') % DartSorted Amplitudes
        spikeTimes = unit.spikeTimesOfAmplitudes;
    else                                        % KS Amplitudes
        spikeTimes = unit.spikeTimesSecs;
%         spikeTimesWhole = unit.spikeTimesSecs;
    
%         %%%%% Exclude the laser artifacted times  %%%%%%%%
%         startTimesSecLaser = [0 laserOffsetTimes+EXCLUDE_POST_LASER_EFFECT_DUR];
%         endTimesSecLaser = [laserOnsetTimes-EXCLUDE_PRE_LASER_EFFECT_DUR Inf];
%         limits = [startTimesSecLaser' endTimesSecLaser'];
%     
%         spikeTimes = [];        
%         for indLaser = 1:size(limits,1)
%             idMaster = find(limits(indLaser,1)<spikeTimesWhole & limits(indLaser,2)>spikeTimesWhole);
%             if ~isempty(idMaster)
%                 spikeTimes = [spikeTimes;spikeTimesWhole(idMaster)];
%             end
%         end
%         %%%%% Exclude the laser artifacted times  %%%%%%%%
    end


    if ~isempty(spikeTimes)
        f = figure;
        f.Position = [globalX globalY globalW globalH*.5];
        hold on
        
        h = scatterhist(spikeTimes,unit.amplitudes,'Location','SouthEast', 'Direction','out'); %, 'Kernel','on');
        xline(MOMENT_OF_1ST_DRUG_PUT_IN,'-', [FIRST_DRUG ' Put-In'],'LineWidth',3, 'FontWeight','bold', 'FontSize',PLOT_FONT_SIZE, 'Color', [1 0 0 0.9]);
        xline(MOMENT_OF_1ST_DRUG_WASH_IN,'-', [FIRST_DRUG ' Wash-In'],'LineWidth',3, 'FontWeight','bold', 'FontSize',PLOT_FONT_SIZE, 'Color', [1 0 0 0.9]);
    
        if ~isempty(MOMENT_OF_2ND_DRUG_PUT_IN)
            xline(MOMENT_OF_2ND_DRUG_PUT_IN,'-', [SECOND_DRUG ' Put-In'],'LineWidth',3, 'FontWeight','bold', 'FontSize',PLOT_FONT_SIZE, 'Color', [0 0 1 0.9]);
            xline(MOMENT_OF_2ND_DRUG_WASH_IN,'-', [SECOND_DRUG ' Wash-In'],'LineWidth',3, 'FontWeight','bold', 'FontSize',PLOT_FONT_SIZE, 'Color', [0 0 1 0.9]);
        end
    
        xlim([0 recordingLengthSecs]);    
        xlabel('Time (s)');
        title(['Unit=' num2str(unit.id)]);    
        set(gca,'FontName','Times New Roman','FontWeight','bold', 'FontSize',PLOT_FONT_SIZE,'LineWidth',1.5)
        set(gca,'TickDir','out');
        delete(h(2));
        %h(2).Visible='off';
        sFolder = [pathToFigureFolder num2str(unit.id)];
        print([sFolder '/' 'amplitudeDist_' num2str(unit.id) '.tif'], '-dtiff', '-r100');    
        exportgraphics(f,[sFolder '/' 'amplitudeDist_' num2str(unit.id) '.pdf'], 'ContentType', 'vector', 'Resolution', 1000);
        logger.info('plotAmplitudeDistribution',['Amplitude distribution is plotted for unit=' num2str(unit.id)]);
        close all;
    end
end