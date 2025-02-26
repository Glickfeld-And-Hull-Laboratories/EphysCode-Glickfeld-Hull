% go to folder of interest!!!  & set these variables
function [struct] = RuigrokStats(struct, range, bwidth)
for index = 1:length(struct)
clust1 = [struct(index).timestamps];         %% Unit 1 is timestamps where unit one fires
clear useDeltas

%selectCL_ts = cast(selectCL_ts,'uint32');      % recast ts as a double instead of uint64
L1 = (length(clust1));                           % L = number of spikes




k = 1;                                              %create counter for output vector index
for i=1:(L1-1)                                           % for every element in the first spiketime vector
       test = clust1(i+1,:)- clust1(i,:);             % get difference between spiketimes
       useDeltas (k,1) = test;                  % If yes, add difference to vector that will create histogram
           k = k+1;                                 % update index
     
           
    
end
%figure
%histogram (useDeltas, 'BinLimits', range, 'Binwidth', bwidth)
%title([' ISI ' num2str(index)])

%average Frequency
struct(index).avgHz = (L1/(clust1(L1)-clust1(1)));

%median ISI
struct(index).medISI = median(useDeltas);

%CVlog ISI
%struct(index).msecISI = 100*useDeltas;
%struct(index).logISI = log(100*useDeltas);
struct(index).CVlog = std(log(100*useDeltas))/mean(log(100*useDeltas));

%CV2
L2 = length(useDeltas);
m = 1;
for j=1:(L2-1)
    CV2(m) = 2*(abs(useDeltas(j+1)-useDeltas(j)))/(useDeltas(j+1)+ useDeltas(j));
    m = m+1;
end
struct(index).meanCV2 = mean(CV2);

% Fifth percentile of the ISI distribution
struct(index).fvpctISI = prctile(useDeltas,5);




end
  
   
    
    

    

    



%tiledlayout(flow);


