function AIC = computeAIC(RSS, n, k)
% RSS : residual sum of squares
% n   : number of data points
% k   : number of model parameters

    AIC = n * log(RSS / n) + 2 * k;
end
