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

    % Perform linear regression: y = X*b + e
    b = X \ y;                      
    y_pred = X * b;

    % Compute regression R^2
    ss_res = sum((y - y_pred).^2);
    ss_tot = sum((y - mean(y)).^2);
    rsq = 1 - (ss_res / ss_tot);
end