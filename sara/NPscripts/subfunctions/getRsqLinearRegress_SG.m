%
%
%
%
%  Inputs
%       y - response variable (e.g., STA image)
%       X - predictor (e.g., binary mask / gabor RF fit)
%

function [rsq] = getRsqLinearRegress_SG(y,X)
    % Flatten data and mask for regression
    y = y(:);                     % response variable
    X = X(:);                   % predictor (binary mask)

    if ~any(X)
        rsq = NaN;
        return
    end

     % Add intercept
    Xreg = [ones(size(X)) X];

    % Perform linear regression: y = X*b + e
    beta = Xreg \ y;
    y_pred = Xreg * beta;

    % Compute regression R^2
    ss_res = sum((y - y_pred).^2);
    ss_tot = sum((y - mean(y)).^2);
    rsq = 1 - (ss_res / ss_tot);
end