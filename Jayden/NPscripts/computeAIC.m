function AIC = computeAIC(RSS, n, k)
% RSS : residual sum of squares
% n   : number of data points
% k   : number of model parameters

    AIC = n * log(RSS / n) + 2 * k + ((2*k*(k+1))/(n-k-1));
end
