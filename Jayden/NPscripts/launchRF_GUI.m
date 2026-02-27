function launchRF_GUI(STA, initParams)

    %% Build coordinate system
    [ny,nx] = size(STA);
    x = (1:nx) - mean(1:nx);
    y = (1:ny) - mean(1:ny);
    [X,Y] = meshgrid(x,y);
    XY = [X(:) Y(:)];

    params = initParams(:);
    nParams = numel(params);

    paramNames = {'Ac','As','sigmaC','deltaSigma', ...
                  'tau','theta','x0','y0', ...
                  'f','phi','dx','dy'};

    if nParams > numel(paramNames)
        paramNames = arrayfun(@(k) sprintf('p%d',k),1:nParams,'UniformOutput',false);
    else
        paramNames = paramNames(1:nParams);
    end

    %% Main figure
    fig = uifigure('Name','RF Model Explorer', ...
                   'Position',[100 100 1300 800]);

    % 2 columns: Left plots, Right controls
    mainGrid = uigridlayout(fig,[1 2]);
    mainGrid.ColumnWidth = {'1x','2x'};  % right side larger
    mainGrid.RowHeight = {'1x'};

    %% ===============================
    % LEFT SIDE (vertical plots)
    %% ===============================

    leftGrid = uigridlayout(mainGrid,[3 1]);
    leftGrid.Layout.Column = 1;
    leftGrid.RowHeight = {'1x','1x','1x'};

    axData  = uiaxes(leftGrid);
    axModel = uiaxes(leftGrid);
    axRes   = uiaxes(leftGrid);

    imagesc(axData, STA);
    axis(axData,'image');
    colormap(axData,'gray');
    title(axData,'STA');

    %% ===============================
    % RIGHT SIDE (Scrollable Parameters)
    %% ===============================

    paramPanel = uipanel(mainGrid, ...
        'Title','Parameters', ...
        'Scrollable','on');
    paramPanel.Layout.Column = 2;

    rowHeight = 60;

    paramGrid = uigridlayout(paramPanel,[nParams 3]);
    paramGrid.ColumnWidth = {120,'1x',80};
    paramGrid.RowHeight = repmat({rowHeight},1,nParams);
    paramGrid.Padding = [10 10 10 10];
    paramGrid.RowSpacing = 8;

    sliders = gobjects(nParams,1);
    edits   = gobjects(nParams,1);

    for i = 1:nParams

        val = params(i);
        range = max(abs(val),1e-3);
        low = val - range;
        high = val + range;
        if low == high
            low = val - 1;
            high = val + 1;
        end

        uilabel(paramGrid,'Text',paramNames{i});

        sliders(i) = uislider(paramGrid,'slider', ...
            'Limits',[low high], ...
            'Value',val);

        edits(i) = uieditfield(paramGrid,'numeric', ...
            'Value',val);

        sliders(i).ValueChangedFcn = @(src,~) sliderChanged(i,src.Value);
        edits(i).ValueChangedFcn   = @(src,~) editChanged(i,src.Value);
    end

    %% Initial render
    updateModel();

    %% ===============================
    % Nested functions
    %% ===============================

    function sliderChanged(idx,val)
        params(idx) = val;
        edits(idx).Value = val;
        updateModel();
    end

    function editChanged(idx,val)
        params(idx) = val;
        sliders(idx).Value = val;
        updateModel();
    end

    function updateModel()

        modelVec = nonConcentricDoGCosineModel(params, XY, 'unnormalized');
        modelRF  = reshape(modelVec, ny, nx);

        imagesc(axModel, modelRF);
        axis(axModel,'image');
        colormap(axModel,'gray');
        title(axModel,'Model');

        residual = STA - modelRF;

        imagesc(axRes, residual);
        axis(axRes,'image');
        colormap(axRes,'gray');
        title(axRes,'Residual');
    end

end