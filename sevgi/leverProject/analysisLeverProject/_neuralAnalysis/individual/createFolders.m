function createFolders(ids, types)
    globals;
    for uid=1:length(ids)        
        type = types{uid};
        sFolder = [pathToFigureFolder num2str(ids(uid))];
        if ~isempty(type)
            sFolder = [sFolder '_' type];
        end
        if ~exist(sFolder)
            mkdir(sFolder);
        end
    end
    
    % Also create folders for interaction between cell types
    sFolder = [pathToFigureFolder ACG];
    if ~exist(sFolder)
        mkdir(sFolder);
    end

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