function plotPSTH_WRTResponseTypesForAHFM(recordingDay, neuronType, responseTypeAll, spikeRatesAll, responseTypeHFM, spikeRatesHFM, ...
    preTime, postTime, edges, sFileName, sGlobal, trialCount)

        globalsAll;
        hasAnyNonEmpty = ~isempty(responseTypeAll) | ~isempty(spikeRatesAll) | ~isempty(responseTypeHFM) | ~isempty(spikeRatesHFM);

        if hasAnyNonEmpty
            %%%%%%%%%%%% ALL %%%%%%%%%%%%%%%%%%%
            indexInc = cell2mat(cellfun(@(x) x==RESPONSE_INCREASING, responseTypeAll, 'UniformOutput', false));
            indexDec = cell2mat(cellfun(@(x) x==RESPONSE_DECREASING, responseTypeAll, 'UniformOutput', false));
            indexNoCh = cell2mat(cellfun(@(x) x==RESPONSE_NO_CHANGE_OR_MIXED, responseTypeAll, 'UniformOutput', false));
        
            spikeRatesAllInc = spikeRatesAll(indexInc);
            spikeRatesAllDec = spikeRatesAll(indexDec);
            spikeRatesAllNoCh = spikeRatesAll(indexNoCh);
            
            if ~isempty(spikeRatesAllInc) || ~isempty(spikeRatesAllDec) || ~isempty(spikeRatesAllNoCh)
                spikeRatesGrouped = {{spikeRatesAllInc}, {spikeRatesAllDec}, {spikeRatesAllNoCh}};
                sGlobalTitle = [recordingDay ' ' sGlobal ' ALL ' neuronType ' n=' num2str(length(spikeRatesAll)) ' trials=' num2str(trialCount)];
                sFullFileName = [pathToFigureFolder RESPONSE_TYPES_FOLDER recordingDay '_' neuronType '_psth_' sFileName '_All_IncDecMixed_xlim_' num2str(preTime) '_' num2str(postTime) '.tif'];
                plotPSTHs(spikeRatesGrouped, {}, {}, preTime, postTime, edges, ...
                    {['Increasing response (n=' num2str(size(spikeRatesAllInc,1)) ')'], ['Decreasing response (n=' num2str(size(spikeRatesAllDec,1)) ')'], ['No change or Mixed response (n=' num2str(size(spikeRatesAllNoCh,1)) ')']}, ...
                    sGlobalTitle, sFullFileName, {{'Inc'},{'Dec'},{'Mixed'}}, {{'r'}, {'b'}, {'k'}}, {'r'}, 0);
            end
    
            %%%%%%%%%%%% HIT %%%%%%%%%%%%%%%%%%%
            responseTypeHit = cellfun(@(x)x(:,1),responseTypeHFM,'UniformOutput',false);
            spikeRatesHit = cellfun(@(x)x(1,:),spikeRatesHFM,'UniformOutput',false);
            indexInc = cell2mat(cellfun(@(x) x==RESPONSE_INCREASING, responseTypeHit, 'UniformOutput', false));
            indexDec = cell2mat(cellfun(@(x) x==RESPONSE_DECREASING, responseTypeHit, 'UniformOutput', false));
            indexNoCh = cell2mat(cellfun(@(x) x==RESPONSE_NO_CHANGE_OR_MIXED, responseTypeHit, 'UniformOutput', false));
        
            spikeRatesHitInc = spikeRatesHit(indexInc);
            spikeRatesHitDec = spikeRatesHit(indexDec);
            spikeRatesHitNoCh = spikeRatesHit(indexNoCh);
            
            if ~isempty(spikeRatesHitInc) || ~isempty(spikeRatesHitDec) || ~isempty(spikeRatesHitNoCh)
                spikeRatesGrouped = {{spikeRatesHitInc}, {spikeRatesHitDec}, {spikeRatesHitNoCh}};
                sGlobalTitle = [recordingDay ' ' sGlobal ' HIT ' neuronType ' n=' num2str(length(spikeRatesHit)) ' trials=' num2str(trialCount)];
                sFullFileName = [pathToFigureFolder RESPONSE_TYPES_FOLDER recordingDay '_' neuronType '_psth_' sFileName '_Hit_IncDecMixed_xlim_' num2str(preTime) '_' num2str(postTime) '.tif'];
                plotPSTHs(spikeRatesGrouped, {}, {}, preTime, postTime, edges, ...
                    {['Increasing response (n=' num2str(size(spikeRatesHitInc,1)) ')'], ['Decreasing response (n=' num2str(size(spikeRatesHitDec,1)) ')'], ['No change or Mixed response (n=' num2str(size(spikeRatesHitNoCh,1)) ')']}, ...
                    sGlobalTitle, sFullFileName, {{'Inc'},{'Dec'},{'Mixed'}}, {{'r'}, {'b'}, {'k'}}, {'r'}, 0);
            end
    
            %%%%%%%%%%%% FA %%%%%%%%%%%%%%%%%%%
            spikeRatesFaInc={};
            spikeRatesFaDec={};
            spikeRatesFaNoCh={};
    
            if length(responseTypeHFM{1})==3 % Hold/Release calling: HFM                
    
                responseTypeFa = cellfun(@(x)x(:,2),responseTypeHFM,'UniformOutput',false);
                spikeRatesFa = cellfun(@(x)x(2,:),spikeRatesHFM,'UniformOutput',false);
                indexInc = cell2mat(cellfun(@(x) x==RESPONSE_INCREASING, responseTypeFa, 'UniformOutput', false));
                indexDec = cell2mat(cellfun(@(x) x==RESPONSE_DECREASING, responseTypeFa, 'UniformOutput', false));
                indexNoCh = cell2mat(cellfun(@(x) x==RESPONSE_NO_CHANGE_OR_MIXED, responseTypeFa, 'UniformOutput', false));
            
                spikeRatesFaInc = spikeRatesFa(indexInc);
                spikeRatesFaDec = spikeRatesFa(indexDec);
                spikeRatesFaNoCh = spikeRatesFa(indexNoCh);
                
                if ~isempty(spikeRatesFaInc) || ~isempty(spikeRatesFaDec) || ~isempty(spikeRatesFaNoCh)
                    spikeRatesGrouped = {{spikeRatesFaInc}, {spikeRatesFaDec}, {spikeRatesFaNoCh}};
                    sGlobalTitle = [recordingDay ' ' sGlobal ' FA ' neuronType ' n=' num2str(length(spikeRatesFa)) ' trials=' num2str(trialCount)];
                    sFullFileName = [pathToFigureFolder RESPONSE_TYPES_FOLDER recordingDay '_' neuronType '_psth_' sFileName '_Fa_IncDecMixed_xlim_' num2str(preTime) '_' num2str(postTime) '.tif'];
                    plotPSTHs(spikeRatesGrouped, {}, {}, preTime, postTime, edges, ...
                        {['Increasing response (n=' num2str(size(spikeRatesFaInc,1)) ')'], ['Decreasing response (n=' num2str(size(spikeRatesFaDec,1)) ')'], ['No change or Mixed response (n=' num2str(size(spikeRatesFaNoCh,1)) ')']}, ...
                        sGlobalTitle, sFullFileName, {{'Inc'},{'Dec'},{'Mixed'}}, {{'r'}, {'b'}, {'k'}}, {'r'}, 0);
                end
        
                %%%%%%%%%%%% MISS %%%%%%%%%%%%%%%%%%%
                responseTypeMiss = cellfun(@(x)x(:,3),responseTypeHFM,'UniformOutput',false);
                spikeRatesMiss = cellfun(@(x)x(3,:),spikeRatesHFM,'UniformOutput',false);
                indexInc = cell2mat(cellfun(@(x) x==RESPONSE_INCREASING, responseTypeMiss, 'UniformOutput', false));
                indexDec = cell2mat(cellfun(@(x) x==RESPONSE_DECREASING, responseTypeMiss, 'UniformOutput', false));
                indexNoCh = cell2mat(cellfun(@(x) x==RESPONSE_NO_CHANGE_OR_MIXED, responseTypeMiss, 'UniformOutput', false));
            
                spikeRatesMissInc = spikeRatesMiss(indexInc);
                spikeRatesMissDec = spikeRatesMiss(indexDec);
                spikeRatesMissNoCh = spikeRatesMiss(indexNoCh);
                
                if ~isempty(spikeRatesMissInc) || ~isempty(spikeRatesMissDec) || ~isempty(spikeRatesMissNoCh)
                    spikeRatesGrouped = {{spikeRatesMissInc}, {spikeRatesMissDec}, {spikeRatesMissNoCh}};
                    sGlobalTitle = [recordingDay ' ' sGlobal ' MISS ' neuronType ' n=' num2str(length(spikeRatesMiss)) ' trials=' num2str(trialCount)];
                    sFullFileName = [pathToFigureFolder RESPONSE_TYPES_FOLDER recordingDay '_' neuronType '_psth_' sFileName '_Miss_IncDecMixed_xlim_' num2str(preTime) '_' num2str(postTime) '.tif'];
                    plotPSTHs(spikeRatesGrouped, {}, {}, preTime, postTime, edges, ...
                        {['Increasing response (n=' num2str(size(spikeRatesMissInc,1)) ')'], ['Decreasing response (n=' num2str(size(spikeRatesMissDec,1)) ')'], ['No change or Mixed response (n=' num2str(size(spikeRatesMissNoCh,1)) ')']}, ...
                        sGlobalTitle, sFullFileName, {{'Inc'},{'Dec'},{'Mixed'}}, {{'r'}, {'b'}, {'k'}}, {'r'}, 0);
                end
    
            elseif length(responseTypeHFM{1})==2 % Target calling: HM
                %%%%%%%%%%%% MISS %%%%%%%%%%%%%%%%%%%
                responseTypeMiss = cellfun(@(x)x(:,2),responseTypeHFM,'UniformOutput',false);
                spikeRatesMiss = cellfun(@(x)x(2,:),spikeRatesHFM,'UniformOutput',false);
                indexInc = cell2mat(cellfun(@(x) x==RESPONSE_INCREASING, responseTypeMiss, 'UniformOutput', false));
                indexDec = cell2mat(cellfun(@(x) x==RESPONSE_DECREASING, responseTypeMiss, 'UniformOutput', false));
                indexNoCh = cell2mat(cellfun(@(x) x==RESPONSE_NO_CHANGE_OR_MIXED, responseTypeMiss, 'UniformOutput', false));
            
                spikeRatesMissInc = spikeRatesMiss(indexInc);
                spikeRatesMissDec = spikeRatesMiss(indexDec);
                spikeRatesMissNoCh = spikeRatesMiss(indexNoCh);
                
                if ~isempty(spikeRatesMissInc) || ~isempty(spikeRatesMissDec) || ~isempty(spikeRatesMissNoCh)
                    spikeRatesGrouped = {{spikeRatesMissInc}, {spikeRatesMissDec}, {spikeRatesMissNoCh}};
                    sGlobalTitle = [recordingDay ' ' sGlobal ' MISS ' neuronType ' n=' num2str(length(spikeRatesMiss)) ' trials=' num2str(trialCount)];
                    sFullFileName = [pathToFigureFolder RESPONSE_TYPES_FOLDER recordingDay '_' neuronType '_psth_' sFileName '_Miss_IncDecMixed_xlim_' num2str(preTime) '_' num2str(postTime) '.tif'];
                    plotPSTHs(spikeRatesGrouped, {}, {}, preTime, postTime, edges, ...
                        {['Increasing response (n=' num2str(size(spikeRatesMissInc,1)) ')'], ['Decreasing response (n=' num2str(size(spikeRatesMissDec,1)) ')'], ['No change or Mixed response (n=' num2str(size(spikeRatesMissNoCh,1)) ')']}, ...
                        sGlobalTitle, sFullFileName, {{'Inc'},{'Dec'},{'Mixed'}}, {{'r'}, {'b'}, {'k'}}, {'r'}, 0);
                end
            end
            close all;
        end
end