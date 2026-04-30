% Phase-Locking Value formula from : Rezayat 2021 (https://www.nature.com/articles/s41467-021-21151-1)
% Ensure phases are radyan values within the range [0, 2*pi]
%
% z=rho*exp(i*theta)
% Euler's formula: exp(i*theta)=cos(theta)+i*sin(theta)

function [rho, theta] = calculatePLV(phases)

    globals;

    % Plot phase distribution as a circular histogram
    %{
    figure;
    polarhistogram(phases, 24, 'Normalization', 'probability');
    title('Spike Phase Distribution');
    %}

    % Mean resultant vector (measure of phase locking)
    z = mean(exp(1i * phases));
    theta = angle(z);
    rho = abs(z);   % PLV value ==> r = 0 (uniform) to 1 (perfect locking)
    
    logger.info('calculatePLV',...
        ['Mean phase: ' num2str(theta,'%.2f') ' rad, Resultant length r = ' num2str(rho, '%.2f')]);
end