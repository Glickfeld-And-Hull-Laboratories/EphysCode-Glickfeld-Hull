function createFolders(singleUnitIds, singleUnitTypes, multiUnitIds, multiUnitTypes, noiseUnitIds, noiseUnitTypes, unprocessedUnitIds, unprocessedUnitTypes)
    globals;
    for uid=1:length(singleUnitIds)        
        type = singleUnitTypes{uid};
        sFolder = [pathToFigureFolder SINGLE_UNIT '/' num2str(singleUnitIds(uid))];
        if ~isempty(type)
            sFolder = [sFolder '_' type];
        end
        if ~exist(sFolder)
            mkdir(sFolder);
        end
    end

    for uid=1:length(multiUnitIds)        
        type = multiUnitTypes{uid};
        sFolder = [pathToFigureFolder MULTI_UNIT '/' num2str(multiUnitIds(uid))];
        if ~isempty(type)
            sFolder = [sFolder '_' type];
        end
        if ~exist(sFolder)
            mkdir(sFolder);
        end
    end

    for uid=1:length(noiseUnitIds)        
        type = noiseUnitTypes{uid};
        sFolder = [pathToFigureFolder NOISE_UNIT '/' num2str(noiseUnitIds(uid))];
        if ~isempty(type)
            sFolder = [sFolder '_' type];
        end
        if ~exist(sFolder)
            mkdir(sFolder);
        end
    end

    for uid=1:length(unprocessedUnitIds)        
        type = unprocessedUnitTypes{uid};
        sFolder = [pathToFigureFolder UNPROCESSED_UNIT '/' num2str(unprocessedUnitIds(uid))];
        if ~isempty(type)
            sFolder = [sFolder '_' type];
        end
        if ~exist(sFolder)
            mkdir(sFolder);
        end
    end
    
    % Also create folders for interaction between cell types
%     sFolder = [pathToFigureFolder ACG];
%     if ~exist(sFolder)
%         mkdir(sFolder);
%     end

    sFolder = [pathToFigureFolder CS_SS];
    if ~exist(sFolder)
        mkdir(sFolder);
    end

    sFolder = [pathToFigureFolder MF_SS];
    if ~exist(sFolder)
        mkdir(sFolder);
    end

    sFolder = [pathToFigureFolder MF_GO];
    if ~exist(sFolder)
        mkdir(sFolder);
    end

    sFolder = [pathToFigureFolder GO_SS];
    if ~exist(sFolder)
        mkdir(sFolder);
    end

    sFolder = [pathToFigureFolder MLI_SS];
    if ~exist(sFolder)
        mkdir(sFolder);
    end

    sFolder = [pathToFigureFolder SS_DCN];
    if ~exist(sFolder)
        mkdir(sFolder);
    end

    sFolder = [pathToFigureFolder SS_SS];
    if ~exist(sFolder)
        mkdir(sFolder);
    end

    sFolder = [pathToFigureFolder MLI_MLI];
    if ~exist(sFolder)
        mkdir(sFolder);
    end

    sFolder = [pathToFigureFolder GO_GO];
    if ~exist(sFolder)
        mkdir(sFolder);
    end

    sFolder = [pathToFigureFolder OTHER_SS];
    if ~exist(sFolder)
        mkdir(sFolder);
    end

    sFolder = [pathToFigureFolder OTHER_CS];
    if ~exist(sFolder)
        mkdir(sFolder);
    end

    sFolder = [pathToFigureFolder OTHER_MF];
    if ~exist(sFolder)
        mkdir(sFolder);
    end

    sFolder = [pathToFigureFolder OTHER_GO];
    if ~exist(sFolder)
        mkdir(sFolder);
    end

    sFolder = [pathToFigureFolder OTHER_MLI];
    if ~exist(sFolder)
        mkdir(sFolder);
    end

    sFolder = [pathToFigureFolder OTHER_OTHER];
    if ~exist(sFolder)
        mkdir(sFolder);
    end
end