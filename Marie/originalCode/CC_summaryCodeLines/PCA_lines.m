%trigger = JuiceTimesAdj;
%xlabel_ = 'time from epoch onset (s)';
xmin = -.1;
xmax = .2;
binvalue0 = 100;
bwidth = .001;
smoothVal = 51;

% all cells
clear N_all
for n = 1:length(Summary)
    [N_all(n,:), edges] = OneUnitHistStructTimeLimLineINDEX(RecordingList(Summary(n).RecorNum).JuiceTimes, n, Summary, xmin, xmax, bwidth, [0 inf], 4, 'k', NaN, 0, 0);
    N_all(n,:) = smoothdata([N_all(n,:)], 'sgolay', smoothVal);
    N_all(n,:) = (N_all(n,:) - mean(N_all(n,1:binvalue0)))/std(N_all(n,1:binvalue0));
end
[U_all, S_all, V_all] = svd(N_all, 'econ');
for n = 1:3
    V_all(:,n) = (V_all(:,n) - mean(V_all(:,n)));
    V_all(:,n) = V_all(:,n)*sqrt(100*length(V_all))*S_all(n,n)/sum(S_all, 'all');
end   

figure
plot3(V_all(:,1), V_all(:,2), V_all(:,3), 'k');
hold on


clear N_CS
for n = 1:length(CS)
    [N_CS(n,:), edges] = OneUnitHistStructTimeLimLineINDEX(RecordingList(CS(n).RecorNum).JuiceTimes, n, CS, xmin, xmax, bwidth, [0 inf], 4, 'k', NaN, 0, 0);
    %N_CS(n,:) = smoothdata([N_CS(n,:)], 'sgolay', smoothVal);
    N_CS(n,:) = (N_CS(n,:) - mean(N_CS(n,1:binvalue0)))/std(N_CS(n,1:binvalue0));
end
[U_ss, S_ss, V_ss] = svd(N_CS, 'econ');
for n = 1:3
    V_ss(:,n) = (V_ss(:,n) - mean(V_ss(:,n)));
    V_ss(:,n) = V_ss(:,n)*sqrt(100*length(V_ss))*S_ss(n,n)/sum(S_ss, 'all');
end    
H = V_all(:,1:3)' * V_ss(:,1:3); % H (should be a 3 x 3, covariance matrix)
[U, S, Vt] = svd(H); % Confirm that the output of whatever SVD you are using is the transpose of V (sometimes denoted Vh) rather than just V
R = U * Vt; % Should be a 3 x 3 rotation matrix. det(R) should be +/-1. Note, if your SVD gives you just V, this this would  be V'
V_ss = V_ss(:,1:3)*R;

figure
 shadedErrorBar2(edges(1:end-1), mean(N_CS), std(N_CS)/sqrt(size(N_CS, 1)));
hold on

%plot3(V_ss(:,1), V_ss(:,2), V_ss(:,3), 'b');


for k = 1:length(RecordingList)
clear N_CS
for n = 1:length(CS([CS.RecorNum] == k))
    [N_CS(n,:), edges] = OneUnitHistStructTimeLimLineINDEX(RecordingList(k).JuiceTimes, n, CS([CS.RecorNum] == k), xmin, xmax, bwidth, [0 inf], 4, 'k', NaN, 0, 0);
    %N_CS(n,:) = smoothdata([N_CS(n,:)], 'sgolay', smoothVal);
    N_CS(n,:) = (N_CS(n,:) - mean(N_CS(n,1:binvalue0)))/std(N_CS(n,1:binvalue0));
end
% [U_ss, S_ss, V_ss] = svd(N_CS, 'econ');
% for n = 1:3
%     V_ss(:,n) = (V_ss(:,n) - mean(V_ss(:,n)));
%     V_ss(:,n) = V_ss(:,n)*sqrt(100*length(V_ss))*S_ss(n,n)/sum(S_ss, 'all');
% end    
% H = V_all(:,1:3)' * V_ss(:,1:3); % H (should be a 3 x 3, covariance matrix)
% [U, S, Vt] = svd(H); % Confirm that the output of whatever SVD you are using is the transpose of V (sometimes denoted Vh) rather than just V
% R = U * Vt; % Should be a 3 x 3 rotation matrix. det(R) should be +/-1. Note, if your SVD gives you just V, this this would  be V'
% V_ss = V_ss(:,1:3)*R;

figure
 shadedErrorBar2(edges(1:end-1), mean(N_CS), std(N_CS)/sqrt(size(N_CS, 1)));
 ylim([-15 15]);
 title(num2str(k));

% plot3(V_ss(:,1), V_ss(:,2), V_ss(:,3));
end
legend({num2str(length(Summary)); num2str(length(CS)); num2str(length(CS([CS.RecorNum] == 1))); num2str(length(CS([CS.RecorNum] == 2))); num2str(length(CS([CS.RecorNum] == 3))); num2str(length(CS([CS.RecorNum] == 4))); num2str(length(CS([CS.RecorNum] == 5)))})

viz code
 figure
 hold on

 shadedErrorBar2(edges(1:end-1), mean(N_CS), std(N_CS)/sqrt(size(N_CS, 1)), 'LineProp', 'b');
   shadedErrorBar2(edges(1:end-1), mean(N_CS), std(N_CS)/sqrt(size(N_CS, 1)), 'LineProp', 'k');
    shadedErrorBar2(edges(1:end-1), mean(N_MLI), std(N_CS)/sqrt(size(N_MLI, 1)), 'LineProp', 'm');
     shadedErrorBar2(edges(1:end-1), mean(N_Gol), std(N_CS)/sqrt(size(N_Gol, 1)), 'LineProp', 'g');
      shadedErrorBar2(edges(1:end-1), mean(N_MF), std(N_CS)/sqrt(size(N_MF, 1)), 'LineProp', 'r');
      legend({'Sspk'; 'Cpsk'; 'MLI'; 'Golgi'; 'MFB'});
FigureWrap(NaN, 'RewardDeliveryPSTH_Zscore', 'time from reward (s)', 'sp/s (z-score)', NaN, NaN, NaN, NaN)
% end




% 
% clear N_all
% for n = 1:length(NoCspk)
%     [N_all(n,:), edges] = OneUnitHistStructTimeLimLineINDEX(trigger, n, NoCspk, xmin, xmax, bwidth, [0 inf], 4, 'k', NaN, 0, 0);
%     N_all(n,:) = smoothdata([N_all(n,:)], 'sgolay', smoothVal);
%     N_all(n,:) = (N_all(n,:) - mean(N_all(n,1:binvalue0)))/std(N_all(n,1:binvalue0));
% end
% [U_all, S_all, V_all] = svd(N_all, 'econ');
% for n = 1:3
%     V_all(:,n) = (V_all(:,n) - mean(V_all(1:binvalue0,n)));
%     V_all(:,n) = V_all(:,n)*sqrt(100*length(V_all))*S_all(n,n)/sum(S_all, 'all');
% end   
% 
% clear N_rand
% for n = 1:length(randNoCspk)
%     [N_rand(n,:), edges] = OneUnitHistStructTimeLimLineINDEX(trigger, n, randNoCspk, xmin, xmax, bwidth, [0 inf], 4, 'k', NaN, 0, 0);
%     N_rand(n,:) = smoothdata([N_rand(n,:)], 'sgolay', smoothVal);
%     N_rand(n,:) = (N_rand(n,:) - mean(N_rand(n,:)))/std(N_rand(n,:));
% end
% [U_rand, S_rand, V_rand] = svd(N_rand, 'econ');
% for n = 1:3
%     V_rand(:,n) = (V_rand(:,n) - mean(V_rand(1:binvalue0,n)));
%     V_rand(:,n) = V_rand(:,n)*sqrt(100*length(V_rand))*S_rand(n,n)/sum(S_rand, 'all');
% end   
% H = V_all(:,1:3)' * V_rand(:,1:3); % H (should be a 3 x 3, covariance matrix)
% [U, S, Vt] = svd(H); % Confirm that the output of whatever SVD you are using is the transpose of V (sometimes denoted Vh) rather than just V
% R = U * Vt; % Should be a 3 x 3 rotation matrix. det(R) should be +/-1. Note, if your SVD gives you just V, this this would  be V'
% V_rand = V_rand(:,1:3)*R;
% 
% clear N_CS
% for n = 1:length(CS)
%     [N_CS(n,:), edges] = OneUnitHistStructTimeLimLineINDEX(trigger, n, CS, xmin, xmax, bwidth, [0 inf], 4, 'k', NaN, 0, 0);
%     N_CS(n,:) = smoothdata([N_CS(n,:)], 'sgolay', smoothVal);
%     N_CS(n,:) = (N_CS(n,:) - mean(N_CS(n,:)))/std(N_CS(n,:));
% end
% [U_ss, S_ss, V_ss] = svd(N_CS, 'econ');
% for n = 1:3
%     V_ss(:,n) = (V_ss(:,n) - mean(V_ss(1:binvalue0,n)));
%     V_ss(:,n) = V_ss(:,n)*sqrt(100*length(V_ss))*S_ss(n,n)/sum(S_ss, 'all');
% end    
% H = V_all(:,1:3)' * V_ss(:,1:3); % H (should be a 3 x 3, covariance matrix)
% [U, S, Vt] = svd(H); % Confirm that the output of whatever SVD you are using is the transpose of V (sometimes denoted Vh) rather than just V
% R = U * Vt; % Should be a 3 x 3 rotation matrix. det(R) should be +/-1. Note, if your SVD gives you just V, this this would  be V'
% V_ss = V_ss(:,1:3)*R;
% 
% clear N_CS
% for n = 1:length(CS)
%     [N_CS(n,:), edges] = OneUnitHistStructTimeLimLineINDEX(trigger, n, CS, xmin, xmax, bwidth, [0 inf], 4, 'k', NaN, 0, 0);
%     N_CS(n,:) = smoothdata([N_CS(n,:)], 'sgolay', smoothVal);
%     N_CS(n,:) = (N_CS(n,:) - mean(N_CS(n,:)))/std(N_CS(n,:));
% end
% [U_cs, S_cs, V_cs] = svd(N_CS, 'econ');
% for n = 1:3
%     V_cs(:,n) = (V_cs(:,n) - mean(V_cs(1:binvalue0,n)));
%     V_cs(:,n) = V_cs(:,n)*sqrt(100*length(V_cs))*S_cs(n,n)/sum(S_cs, 'all');
% end   
% H = V_all(:,1:3)' * V_cs(:,1:3); % H (should be a 3 x 3, covariance matrix)
% [U, S, Vt] = svd(H); % Confirm that the output of whatever SVD you are using is the transpose of V (sometimes denoted Vh) rather than just V
% R = U * Vt; % Should be a 3 x 3 rotation matrix. det(R) should be +/-1. Note, if your SVD gives you just V, this this would  be V'
% V_cs = V_cs(:,1:3)*R;
% 
% clear N_MLI
% for n = 1:length(MLI)
%     [N_MLI(n,:), edges] = OneUnitHistStructTimeLimLineINDEX(trigger, n, MLI, xmin, xmax, bwidth, [0 inf], 4, 'k', NaN, 0, 0);
%     N_MLI(n,:) = smoothdata([N_MLI(n,:)], 'sgolay', smoothVal);
%     N_MLI(n,:) = (N_MLI(n,:) - mean(N_MLI(n,:)))/std(N_MLI(n,:));
% end
% [U_mli, S_mli, V_mli] = svd(N_MLI, 'econ');
% for n = 1:3
%     V_mli(:,n) = (V_mli(:,n) - mean(V_mli(1:binvalue0,n)));
%     V_mli(:,n) = V_mli(:,n)*sqrt(100*length(V_mli))*S_mli(n,n)/sum(S_mli, 'all');
% end
% H = V_all(:,1:3)' * V_mli(:,1:3); % H (should be a 3 x 3, covariance matrix)
% [U, S, Vt] = svd(H); % Confirm that the output of whatever SVD you are using is the transpose of V (sometimes denoted Vh) rather than just V
% R = U * Vt; % Should be a 3 x 3 rotation matrix. det(R) should be +/-1. Note, if your SVD gives you just V, this this would  be V'
% V_mli = V_mli(:,1:3)*R;
% 
% clear N_Gol
% for n = 1:length(Gol)
%     [N_Gol(n,:), edges] = OneUnitHistStructTimeLimLineINDEX(trigger, n, Gol, xmin, xmax, bwidth, [0 inf], 4, 'k', NaN, 0, 0);
%     N_Gol(n,:) = smoothdata([N_Gol(n,:)], 'sgolay', smoothVal);
%     N_Gol(n,:) = (N_Gol(n,:) - mean(N_Gol(n,:)))/std(N_Gol(n,:));
% end
% [U_gol, S_gol, V_gol] = svd(N_Gol, 'econ');
% for n = 1:3
%     V_gol(:,n) = (V_gol(:,n) - mean(V_gol(1:binvalue0,n)));
%     V_gol(:,n) = V_gol(:,n)*sqrt(100*length(V_gol))*S_gol(n,n)/sum(S_gol, 'all');
% end
% H = V_all(:,1:3)' * V_gol(:,1:3); % H (should be a 3 x 3, covariance matrix)
% [U, S, Vt] = svd(H); % Confirm that the output of whatever SVD you are using is the transpose of V (sometimes denoted Vh) rather than just V
% R = U * Vt; % Should be a 3 x 3 rotation matrix. det(R) should be +/-1. Note, if your SVD gives you just V, this this would  be V'
% V_gol = V_gol(:,1:3)*R;
% 
% clear N_MF
% for n = 1:length(MF)
%     [N_MF(n,:), edges] = OneUnitHistStructTimeLimLineINDEX(trigger, n, MF, xmin, xmax, bwidth, [0 inf], 4, 'k', NaN, 0, 0);
%     N_MF(n,:) = smoothdata([N_MF(n,:)], 'sgolay', smoothVal);
%     N_MF(n,:) = (N_MF(n,:) - mean(N_MF(n,:)))/std(N_MF(n,:));
% end
% [U_mf, S_mf, V_mf] = svd(N_MF, 'econ');
% for n = 1:3
%     V_mf(:,n) = (V_mf(:,n) - mean(V_mf(1:binvalue0,n)));
%     V_mf(:,n) = V_mf(:,n)*sqrt(100*length(V_mf))*S_mf(n,n)/sum(S_mf, 'all');
% end   
% H = V_all(:,1:3)' * V_mf(:,1:3); % H (should be a 3 x 3, covariance matrix)
% [U, S, Vt] = svd(H); % Confirm that the output of whatever SVD you are using is the transpose of V (sometimes denoted Vh) rather than just V
% R = U * Vt; % Should be a 3 x 3 rotation matrix. det(R) should be +/-1. Note, if your SVD gives you just V, this this would  be V'
% V_mf = V_mf(:,1:3)*R;
%     
% figure
% plot3(V_all(:,1), V_all(:,2), V_all(:,3), 'k');
% hold on
% % plot3(V_rand(:,1), V_rand(:,2), V_rand(:,3), 'LineWidth', 3, 'Color', 'b');
% % scatter3(V_all(1,1), V_all(1,2), V_all(1,3), 'k');
% plot3(V_ss(:,1), V_ss(:,2), V_ss(:,3), 'b');
% scatter3(V_ss(1,1), V_ss(1,2), V_ss(1,3), 'b');
% % plot3(V_cs(:,1), V_cs(:,2), V_cs(:,3), 'k');
% % scatter3(V_cs(1,1), V_cs(1,2), V_cs(1,3), 'k')
% plot3(V_mli(:,1), V_mli(:,2), V_mli(:,3), 'm');
% %scatter3
% plot3(V_gol(:,1), V_gol(:,2), V_gol(:,3), 'g');
% scatter3(V_gol(1,1), V_gol(1,2), V_gol(1,3), 'g');
% plot3(V_mf(:,1), V_mf(:,2), V_mf(:,3), 'r');
% scatter3(V_mf(1,1), V_mf(1,2), V_mf(1,3), 'r');
% scatter3(15, -9, -4, 'c', 'Filled');
% 
% %rotate to be most pretty
% %FigureWrap(NaN, 'RewardDeliveryPSTH_PCA', NaN, NaN, NaN, NaN, NaN, NaN)
% 
% v = VideoWriter('TestVideo');
% %v.FrameCount = 30;
% v.FrameRate = 10;
% open(v);
% for n = 1:length(V_all)
%     figure
% plot3(V_all(1:n,1), V_all(1:n,2), V_all(1:n,3), 'k');
% hold on
% % plot3(V_rand(1:n,1), V_rand(1:n,2), V_rand(1:n,3), 'LineWidth', 3, 'Color', 'b');
% % scatter3(V_all(1,1), V_all(1,2), V_all(1,3), 'k');
% plot3(V_ss(1:n,1), V_ss(1:n,2), V_ss(1:n,3), 'b');
% scatter3(V_ss(1,1), V_ss(1,2), V_ss(1,3), 'b');
% % plot3(V_cs(1:n,1), V_cs(1:n,2), V_cs(1:n,3), 'k');
% % scatter3(V_cs(1,1), V_cs(1,2), V_cs(1,3), 'k')
% plot3(V_mli(1:n,1), V_mli(1:n,2), V_mli(1:n,3), 'm');
% %scatter3
% plot3(V_gol(1:n,1), V_gol(1:n,2), V_gol(1:n,3), 'g');
% scatter3(V_gol(1,1), V_gol(1,2), V_gol(1,3), 'g');
% plot3(V_mf(1:n,1), V_mf(1:n,2), V_mf(1:n,3), 'r');
% scatter3(V_mf(1,1), V_mf(1,2), V_mf(1,3), 'r');
% if n >= binvalue0
%     scatter3(15, -9, -4, 'c', 'Filled');
% end
% xlabel('x');
% xlim([-5 20]);
% ylabel('y');
% ylim([-10 10]);
% zlabel('z');
% zlim([-6 4]);
%     frame = getframe(gcf);
%    writeVideo(v,frame);
%    close all
% end
% close(v);
% 
% 
% 
%  %viz code
%  figure
%  hold on
%  %plot(edges(1:end-1), mean(N_CS), 'b');
%  shadedErrorBar2(edges(1:end-1), mean(N_CS), std(N_CS)/sqrt(size(N_CS, 1)), 'LineProp', 'b');
%   %plot(edges(1:end-1), mean(N_CS), 'k');
%    shadedErrorBar2(edges(1:end-1), mean(N_CS), std(N_CS)/sqrt(size(N_CS, 1)), 'LineProp', 'k');
%    %plot(edges(1:end-1), mean(N_MLI), 'm');
%     shadedErrorBar2(edges(1:end-1), mean(N_MLI), std(N_CS)/sqrt(size(N_MLI, 1)), 'LineProp', 'm');
%     %plot(edges(1:end-1), mean(N_Gol), 'g');
%      shadedErrorBar2(edges(1:end-1), mean(N_Gol), std(N_CS)/sqrt(size(N_Gol, 1)), 'LineProp', 'g');
%      %plot(edges(1:end-1), mean(N_MF), 'r');
%       shadedErrorBar2(edges(1:end-1), mean(N_MF), std(N_CS)/sqrt(size(N_MF, 1)), 'LineProp', 'r');
%       legend({'Sspk'; 'Cpsk'; 'MLI'; 'Golgi'; 'MFB'});
% FigureWrap(NaN, 'RewardDeliveryPSTH_Zscore', 'time from reward (s)', 'sp/s (z-score)', NaN, NaN, NaN, NaN)
% % end
