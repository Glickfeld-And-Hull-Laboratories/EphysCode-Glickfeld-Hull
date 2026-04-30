function [interrupted, interruptionMoments] = isUniformlyDistributed(data, roiStartTimeSec, roiEndTimeSec) %, trialCount) % [ksResult, chiResult, interrupted] 
    globals;
%     chiResult = 0;
    interrupted = 1; % By default, it should be interrupted
    interruptionMoments = -1;
    
%     % data is an N x 1 vector of observations    
%     % Ensure the data is a column vector
%     data = data(:);
% 
%     % Number of observations
%     N = length(data);
% 
%     % Sort the data
%     sorted_data = sort(data);
% 
%     % Compute the empirical CDF
%     empirical_cdf = (1:N) / N;
% 
%     % Theoretical CDF for uniform distribution is the data values
%     theoretical_cdf = ((sorted_data - min(sorted_data)) / (max(sorted_data) - min(sorted_data)))';
% 
%     % Compute the Kolmogorov-Smirnov statistic
%     D = max(abs(empirical_cdf - theoretical_cdf));
%     
%     % Compute the p-value using the KS distribution approximation
%     % D critical value approximation
%     p_value = exp(-2 * N * D.^2);
% 
%     % Display results
% %     fprintf('Kolmogorov-Smirnov test statistic: %f\n', D);
% %     fprintf('p-value: %f\n', p_value);
% 
%     % Interpret the result
%     if p_value < 0.05
%         ksResult = 0;
% %         disp('The data is not uniformly distributed (p < 0.05).');
%     else
%         ksResult = 1;
% %         disp('The data is uniformly distributed (p >= 0.05).');
%     end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      
    edges = roiStartTimeSec:BIN_SIZE_CONTINUITY:roiEndTimeSec;
    if length(edges)>2
        %edgesPlt = edges(1:end-1)+(edges(2)-edges(1))/2;
        binCounts = histcounts(data,edges);
        spikeRates = binCounts/BIN_SIZE_CONTINUITY; %trialCount*
        
%%%%%%%%% CHI2GOF RESULT  %%%%%%%%%%    
%         expCounts = repmat(length(data)/length(binCounts),[1,length(binCounts)]);    
%         [h,p,stats]=chi2gof(data,'Ctrs',edgesPlt,'Expected',expCounts); %, 'NParams',1); 'Frequency',binCounts, 
%         chiResult = ~h;
%     
        %%%%%%%%%%%%%%%%%% MY CRITERIA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        interrupted = any(spikeRates<mean(spikeRates)/25); % If there is any interruption in the spiking for 10 sec (BIN_SIZE_CONTINUITY)
        interruptionInds = find(spikeRates<mean(spikeRates)/25);
        interruptionMoments = edges(interruptionInds);
    end
end