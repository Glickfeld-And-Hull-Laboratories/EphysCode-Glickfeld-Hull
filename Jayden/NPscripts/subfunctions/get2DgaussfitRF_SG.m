% Taken from LG's script, Fit_2Dellpse_LG_Ret on 6/26/2025 -SG
% Previously called in wrapper script retAndRFfits.m
% Added comments and stuff
% ==============================
% Fit a 2D gaussian to spatial RF data
%
% INPUT: 
%   - 'data' (matrix), responses for 1 cell of size [xDim x yDim] 
%   
% OUTPUT: 
%   - 'gStruct' (structure) best-fit parameters 
%
% 
% Model params = [A, sigma_El, sigma_Az, El0, Az0, xi]
% - A: amplitude
% - sigma_Az, sigma_El: standard deviations (here, in space)
% - Az0, El0: center coordinates
% - xi: tilt
%

function [gStruct] = get2DgaussfitRF_SG(data)

    Azs = 1:size(data,2);
    Els = 1:size(data,1);

    [AzAz, ElEl]    = meshgrid(Azs,Els);    % Set up grids that report only azimuth or only elevation for all stimulus locations
    dAz             = median(diff(Azs));    % Find step size of azimuth presentations
    dEl             = median(diff(Els));
    Az_vec00        = Azs(1):(dAz/10):Azs(end); % Set up oversampled grid 
    El_vec00        = Els(1):(dEl/10):Els(end);
    [AzAz00,ElEl00] = meshgrid(Az_vec00,El_vec00);

    grid.AzAz       = AzAz;
    grid.ElEl       = ElEl;
    grid.AzAz00     = AzAz00;
    grid.ElEl00     = ElEl00;

% Initalization
    gStruct       = struct;
    gStruct.data  = data;  % Observed data
    gStruct.orig  = reshape(data',size(data,1)*size(data,2),1); 
    
% Define gaussian model function temporary name
    modelfun   = @(pars,sftf) Gauss2D_ellipseMA(pars,sftf);
    gStruct.modelfun = func2str(modelfun);  % Store model as a string

% Prepare input grid (coordinates)
    [m2,n2] = size(grid.AzAz); % I think grid2 is probably what I want to replace with xDim yDim

% Flatten azimuth and elevation grids
    x       = [grid.AzAz(:) grid.ElEl(:)];
    uvar.Az = unique(x(:,1)); 
    uvar.El = unique(x(:,2));

% Prepare oversampled grid (used for cutoffs)
    xNperfreq   = size(grid.AzAz00,1);
    yNperfreq   = size(grid.AzAz00,2);
    xhigh       = reshape(grid.AzAz00, xNperfreq*yNperfreq, 1);
    yhigh       = reshape(grid.ElEl00, xNperfreq*yNperfreq, 1);
    xyhigh      = [xhigh yhigh];
    
    x_plot = x;     % Save for plotting

% Flatten observed data
    y = gStruct.data(:);   

% Compute center of mass (CM) of response
    CM      = zeros(1,2);
    CM_data = zeros(1,2);
    CM(1)   = sum(x(:,1).*gStruct.orig)/sum(gStruct.orig);
    CM(2)   = sum(x(:,2).*gStruct.orig)/sum(gStruct.orig);
    CM_data = CM;
    
% Remove NaNs from data    
    Mask_NaN    = isnan(y);
    ind_NaN     = find(isnan(y));
    ind_noNaN   = find(Mask_NaN == 0);
    if ~isempty(ind_NaN)
        x(ind_NaN,:)    = [];
        y(ind_NaN)      = [];
    end
    
% Set bounds for parameters [A, sigma_El, sigma_Az, El0, Az0, xi]
    lbAmp       = 0.001;
    lbSigmaEl   = 1;
    lbSigmaAz   = 1;
    lbEl0       = 4; %(min(x(:,2)));       % HARD CODING FOR NOW
    lbAz0       = 10; %(min(x(:,1)));    % HARD CODING FOR NOW
    lbXi        = -2; % tilt range set in radians

    ubAmp       = 10;
    ubSigmaEl   = 10;
    ubSigmaAz   = 12;
    ubEl0       = 20; %x(max(data(:),[],1));    % HARD CODING FOR NOW
    ubAz0       = 40; %x(max(data(:),[],2));    % HARD CODING FOR NOW
    ubXi        = 2;
    gStruct.lb =  [lbAmp lbSigmaEl lbSigmaAz lbEl0 lbAz0 lbXi];     % lower bounds
    gStruct.ub =  [ubAmp ubSigmaEl ubSigmaAz ubEl0 ubAz0 ubXi];     % upper bounds
    

% Grid initializations
    Nsamps = 2;     % Number of initial samples per parameter dimension
    dbin = [gStruct.ub(1) - gStruct.lb(1); ...  % Bin widths
        gStruct.ub(2) - gStruct.lb(2); ...
        gStruct.ub(3) - gStruct.lb(3); ...
        gStruct.ub(4) - gStruct.lb(4); ...
        gStruct.ub(5) - gStruct.lb(5); ...
        gStruct.ub(6) - gStruct.lb(6)] ./ (Nsamps-1);

% Create parameter sampling vectors
    sigmaGuessAz = (max(Azs) - min(Azs)) / 6;   
    sigmaGuessEl = (max(Els) - min(Els)) / 6;
    sigma_Az_vec = linspace(0.5*sigmaGuessAz, 2*sigmaGuessAz, Nsamps);
    sigma_El_vec = linspace(0.5*sigmaGuessEl, 2*sigmaGuessEl, Nsamps);
    % sigma_El_vec = gStruct.lb(2)+dbin(2)/2:dbin(2):gStruct.ub(2);
    % sigma_Az_vec = gStruct.lb(3)+dbin(3)/2:dbin(3):gStruct.ub(3);
    El_vec          = gStruct.lb(4)+dbin(4)/2:dbin(4):gStruct.ub(4);
    Az_vec          = gStruct.lb(5)+dbin(5)/2:dbin(5):gStruct.ub(5);
    xi_vec          = gStruct.lb(6)+dbin(6)/2:dbin(6):gStruct.ub(6);
 
% Fit loop (loop over initial parameters not to get stuck in local minimum)
    clear temp;
    index = 1;
    names = {'x2','resnorm'};   % Store parameters and residual error
    
    for iSigEl = 1:length(sigma_El_vec)
        for iSigAz = 1:length(sigma_Az_vec)
            for iEl = 1:length(El_vec)
                for iAz = 1:length(Az_vec)
                    for ixi = 1:length(xi_vec)
                    % Initialize parameter vector
                        gStruct.x0 =  [max(max(gStruct.data)) sigma_El_vec(iSigEl) sigma_Az_vec(iSigAz) El_vec(iEl) Az_vec(iAz) xi_vec(ixi)];
                    % Run least-squares optimization
                        options = optimset('Display', 'off');
                        [x2,Resnorm,FVAL,EXITFLAG,OUTPUT,LAMBDA,JACOB]  = lsqcurvefit(modelfun,gStruct.x0,x,y,gStruct.lb,gStruct.ub,options);
                    % Store result
                        temp(index) = cell2struct({x2,Resnorm},names,2);
                        index = index +1;
                    end
                end
            end
        end
    end
    
% Select best fit
    [val, ind]      = min([temp.resnorm]);  % Find minimum residual
    gStruct.fit     = temp(ind);  % Best fit parameter struct
    gStruct.x       = gStruct.fit.x2;     % Best fit parameter vector

% Model responses
    gStruct.k2            = zeros(m2*n2,1);
    gStruct.k2(ind_noNaN) = modelfun(gStruct.fit.x2,x);    % Fitted model on non-NaN points
    gStruct.k2_plot       = modelfun(gStruct.fit.x2,x_plot);     % Full grid

% Oversampled model   
    gStruct.k2_plot_oversamp0 = modelfun(gStruct.fit.x2,xyhigh);
    gStruct.k2_plot_oversamp  = reshape(gStruct.k2_plot_oversamp0,xNperfreq,yNperfreq);

% Reshape to image size    
    gStruct.k2b       = reshape(gStruct.k2,m2,n2);
    gStruct.k2b_plot  = reshape(gStruct.k2_plot,m2,n2);
    gStruct.res       = gStruct.data-gStruct.k2b;   % Residual image
    gStruct.Maxfit    = max(max(gStruct.k2b));
    gStruct.Maxdata   = max(max(gStruct.data));
    
% Compute high cutoffs (10% and 50%)
    x00         = [grid.ElEl00(:), grid.AzAz00(:)];
    k2b00       = modelfun(gStruct.x, x00);
    gStruct.Maxfit00  = max(k2b00);

    MaxEl00 = gStruct.x(4);
    MaxAz00 = gStruct.x(5);

% 50% cutoff (right side only)
    indEl50         = find(k2b00>.5*gStruct.Maxfit00 & x00(:,1)>MaxEl00);
    indAz50         = find(k2b00>.5*gStruct.Maxfit00 & x00(:,2)>MaxAz00);
    gStruct.Elhicut_50    = ~isempty(indEl50) * max(x00(indEl50,1));
    gStruct.Azhicut_50    = ~isempty(indAz50) * max(x00(indAz50,2));

% 10% cutoff (right side only)
    indEl10         = find(k2b00 > 0.1 * gStruct.Maxfit00 & x00(:,1) > MaxEl00);
    indAz10         = find(k2b00 > 0.1 * gStruct.Maxfit00 & x00(:,2) > MaxAz00);
    gStruct.Elhicut_10    = ~isempty(indEl10) * max(x00(indEl10,1));
    gStruct.Azhicut_10    = ~isempty(indAz10) * max(x00(indAz10,2));

end




