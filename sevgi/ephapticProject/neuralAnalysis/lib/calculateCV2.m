%%%%%% SO Hull Lab 2/18/2025
%%%%%% Calculates CV2 based on the formula : CV2 = mean(2*(t2-t1)/(t2+t1)); 
% Robert A. Hensbroek et al (2014) "CV2 which is the mean of two times the absolute difference between two successive ISIs divided by the sum of both intervals (Holt
% et al., 1996) "
% https://www.sciencedirect.com/science/article/pii/S0165027014001472
%
% Also see Holt 1996
% (https://journals.physiology.org/doi/epdf/10.1152/jn.1996.75.5.1806?src=getftr&utm_source=sciencedirect_contenthosting&getft_integrator=sciencedirect_contenthosting)
% CV=1 is a Poisson process
% CV=0.5 is a gamma process with firing rate is modulated by a sinosoidal function
% CV=0 is fully regular

function cv2 = calculateCV2(arrSpikeTimes)

    isis = diff(arrSpikeTimes);
    arrCV2 = zeros(1,length(isis)-1);

    for i=1:length(isis)-1
        difference = abs(isis(i+1)-isis(i));
        div = isis(i+1)+isis(i);
        arrCV2(i) = 2*difference/div;
    end
    cv2 = mean(arrCV2);
end