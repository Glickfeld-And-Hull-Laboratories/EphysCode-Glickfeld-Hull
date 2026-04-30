function [h_half, p_half, h_normal, p_normal, chiResult, skewnessResult, kurtosisResult, ksResult, lilliesResult, hSmaller, hLarger, skewData, skewNormal] = isNormallyDistributed(data)
    
    h_half = 0;
    p_half = 0;
    h_normal = 0;
    p_normal = 0;
    chiResult = 0;
    skewnessResult = 0;
    kurtosisResult = 0;
    ksResult = 0;
    lilliesResult = 0;
    hSmaller = 0;
    hLarger = 0;
    skewData = 0;
    skewNormal = 0;

    if length(data)>50        
        pd_half_normal = fitdist(data, 'HalfNormal');  % Fit a half-normal distribution        
        pd_normal = fitdist(data, 'Normal');    % Compare with a normal distribution
        x = linspace(min(data), max(data), 100);
        y_half_normal = pdf(pd_half_normal, x);
        y_normal = pdf(pd_normal, x);
        % Kolmogorov-Smirnov test for half-normal fit
        [h_half, p_half] = kstest(data, 'CDF', pd_half_normal);
        
        % Kolmogorov-Smirnov test for normal fit
        [h_normal, p_normal] = kstest(data, 'CDF', pd_normal);

        [hSmaller,pSmaller] = kstest(data,'Tail','smaller');
        [hLarger,pLarger] = kstest(data,'Tail','larger');
        skewData = skewness(data);        
        skewNormal = skewness(y_normal);

        [hLil,p] = lillietest(data);
        lilliesResult = ~hLil;
        [hKs,p] = kstest(data); %,'Tail','smaller')
        ksResult = ~hKs;

        pd = fitdist(data,'Normal');
        h = chi2gof(data,'CDF',pd);
        chiResult = ~h; % h=0 means cannot reject the null hypothesis that data comes from normal distribution
    
        [N, D] = size(data);
        
        % Ensure data is centered
        data = data - mean(data);
    
        % Compute the covariance matrix
        Sigma = cov(data);
    
        % Compute the Mahalanobis distance for each data point
        invSigma = inv(Sigma);
        mahalanobisDist = sum((data * invSigma) .* data, 2);
    
        % Mardia's skewness test
        skewnessValue = mean(mahalanobisDist.^2) / (D - 1);
        skewness_p = 1 - chi2cdf(skewnessValue, D * (D + 1) / 2);
    
        % Mardia's kurtosis test
        kurtosisValue = mean(mahalanobisDist.^4) / (D * (D + 2) * (D + 4));
        kurtosis_p = 1 - chi2cdf(kurtosisValue, D * (D + 2) * (D + 4) / 2);
    
    %     fprintf('Mardia''s skewness test p-value: %f\n', skewness_p);
    %     fprintf('Mardia''s kurtosis test p-value: %f\n', kurtosis_p);
    
        if skewness_p < 0.05
            skewnessResult = 0;
            %disp('The data is not normally distributed (based on skewness).');
        else
            skewnessResult = 1;
            %disp('The data is normally distributed (based on skewness).');
        end
    
        if kurtosis_p < 0.05
            kurtosisResult = 0;
            %disp('The data is not normally distributed (based on kurtosis).');
        else
            kurtosisResult = 1;
            %disp('The data is normally distributed (based on kurtosis).');
        end
    
    %         [h,p] = lillietest(unit.amplitudes,'Distribution','exponential');
    %         [h,p] = lillietest(unit.spikeTimesSecs);
    % 
    %         f = figure;
    %         ampl = unit.amplitudes - mean(unit.amplitudes);
    %         [yEmpirical,x_values] = ecdf(ampl);
    %         J = plot(x_values,yEmpirical);
    %         yStandartNormalDistr = normcdf(x_values);
    %         hold on;
    %         K = plot(x_values, yStandartNormalDistr, 'r--');
    %         set(J,'LineWidth',2);
    %         set(K,'LineWidth',2);
    %         legend([J K],'Empirical CDF','Standard Normal CDF','Location','SE');

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         data = unit.amplitudes;
%         
%         % Fit a half-normal distribution
%         pd_half_normal = fitdist(data, 'HalfNormal');
%         
%         % Compare with a normal distribution
%         pd_normal = fitdist(data, 'Normal');
%         
%         % Compare with a normal distribution
%         pd_wb = fitdist(data, 'Weibull');
%         
%         % Plot fitted distributions
%         x = linspace(min(data), max(data), 100);
%         y_half_normal = pdf(pd_half_normal, x);
%         y_normal = pdf(pd_normal, x);
%         y_wb = pdf(pd_wb, x);
%         
%         plot(x, y_half_normal, 'b', 'LineWidth', 2);
%         hold on;
%         plot(x, y_normal, 'r--', 'LineWidth', 2);
%         plot(x, y_wb, 'k--', 'LineWidth', 2);
%         %hold off;
%         %histogram(data);
%         legend('Half-Normal Fit', 'Normal Fit','Weibull','data');
%         
%         % Kolmogorov-Smirnov test for half-normal fit
%         [h_half, p_half] = kstest(data, 'CDF', pd_half_normal)
%         
%         % Kolmogorov-Smirnov test for normal fit
%         [h_normal, p_normal] = kstest(data, 'CDF', pd_normal)
%         
%         % Kolmogorov-Smirnov test for normal fit
%         [h_wb, p_wb] = kstest(data, 'CDF', pd_wb)
%         
%         % Display results
%         fprintf('KS Test p-value for Half-Normal: %f %f\n', h_half, p_half);
%         fprintf('KS Test p-value for Normal: %f %f\n', h_normal, p_normal);
%         fprintf('KS Test p-value for Weibull: %f %f\n', h_wb, p_wb);
% 
%         [h, p] = lillietest(data)                
%         % Display results
%         fprintf('lillietest Test p-value for Normal: %f %f\n', h, p);
%         %%%%%%%%%%%%%%%%%%%%%% PLOTS %%%%%%%%%%%%%%%%%%%%%%%%%%%
%         close all
%         [empPdf,xi] = ksdensity(data); 
%         figure
%         hold on;
%         J = plot(xi,empPdf, 'b--');
%         pd_normal = fitdist(data, 'Normal');
%         x = linspace(min(data), max(data), 100);
%         y_normal = pdf(pd_normal, x);
%         K = plot(x, y_normal, 'r--', 'LineWidth', 2);
%         set(J,'LineWidth',2);
%         set(K,'LineWidth',2);
%         legend([J K],'Empirical CDF','Standard Normal CDF','Location','SE','Color','none');
% 
%         figure;        
%         [f,x_values] = ecdf(data);
%         J = plot(x_values,f, 'b--');
%         hold on;
%         K = plot(x_values,normcdf(x_values),'r--');
%         set(J,'LineWidth',2);
%         set(K,'LineWidth',2);
%         legend([J K],'Empirical CDF','Standard Normal CDF','Location','SE','Color','none');
%         

    end
end