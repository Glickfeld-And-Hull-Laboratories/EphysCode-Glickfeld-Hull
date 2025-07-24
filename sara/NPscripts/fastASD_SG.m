%% test_fastASD_3D.m
%


% NOTE: Run script 'setpaths.m' in parent directory before running

setpaths_ASD

%%  Make stimulus and response
nsamps = 1000; % number of stimulus sample
signse = 10;   % stdev of added noise
x = gsmooth(randn(nk,nsamps),1)'; % stimulus (smooth)
y = x*k + randn(nsamps,1)*signse;  % dependent variable 

% plot filter and examine noise level
subplot(224); % ------
plot(x*k, x*k, 'k.', x*k, y, 'r.'); xlabel('noiseless y'); ylabel('observed y');

%% Compute ridge regression estimate 
fprintf('\n...Running ridge regression with fixed-point updates...\n');

% Sufficient statistics (old way of doing it, not used for ASD)
dd.xx = x'*x;   % stimulus auto-covariance
dd.xy = (x'*y); % stimulus-response cross-covariance
dd.yy = y'*y;   % marginal response variance
dd.nx = nk;     % number of dimensions in stimulus
dd.ny = nsamps;  % total number of samples

% Run ridge regression using fixed-point update of hyperparameters
maxiter = 100;
tic;
kridge = autoRidgeRegress_fp(dd,maxiter);
toc;


%% Compute ASD estimate
fprintf('\n\n...Running ASD_2D...\n');

minlen = 2.5;  % minimum length scale along each dimension

tic; 
[kasd,asdstats] = fastASD(x,y,nks,minlen);
toc;

%%  ---- Make Plots ----

kridge_tns = reshape(kridge,nks);
kasd_tns = reshape(kasd,nks);

for j = 1:min(4,nks(3));
    subplot(3,4,j); imagesc(ktns(:,:,j)); 
    title(sprintf('slice %d',j));
    subplot(3,4,j+4); imagesc(kridge_tns(:,:,j));
    subplot(3,4,j+8); imagesc(kasd_tns(:,:,j));
end
subplot(3,4,1); ylabel('\bf{true k}');
subplot(3,4,5); ylabel('\bf ridge');
subplot(3,4,9); ylabel('\bf ASD');


% Display facts about estimate
ci = asdstats.ci;
fprintf('\nHyerparam estimates (+/-1SD)\n-----------------------\n');
fprintf('     l: %5.1f  %5.1f (+/-%.1f)\n',len(1),asdstats.len,ci(1));
fprintf('   rho: %5.1f  %5.1f (+/-%.1f)\n',rho(1),asdstats.rho,ci(2));
fprintf('nsevar: %5.1f  %5.1f (+/-%.1f)\n',signse.^2,asdstats.nsevar,ci(3));

% Compute errors
err = @(khat)(sum((k-khat(:)).^2)); % Define error function
fprintf('\nErrors:\n------\n  Ridge = %7.2f\n  ASD2D = %7.2f\n\n', ...
     [err(kridge) err(kasd)]);
% 
