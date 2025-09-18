

load fastASDexample
setpaths


celln = 13;

nsamps = size(ys,2);
nks = [10 10];  % number of filter pixels along [cols, rows]
nk = prod(nks); % total number of filter coeffs

% ax needs to be size timesteps by number pixels
% ay needs to be size timesteps by 1


ax = (xxon(:,1:nsamps)- xxoff(:,1:nsamps))';
ay = ys(celln,1:nsamps)';


% cheap RF
zz = zeros(1,100);
for l=1:size(xxon,1)
    a = corrcoef(ax(:,l)',ay');
    zz(l) = zz(l)+a(1,2);
end



% ax needs to be size timesteps by number pixels
% ay needs to be size timesteps by 1

dd.xx = ax'*ax;
dd.xy = (ax'*ay); % stimulus-response cross-covariance
dd.yy = ay'*ay;   % marginal response variance
dd.nx = nk;     % number of dimensions in stimulus
dd.ny = nsamps;  % total number of samples



% This does not work -- Filter is all zeros.
% Run ridge regression using fixed-point update of hyperparameters
maxiter = 100;
tic;
kridge = autoRidgeRegress_fp(dd,maxiter);
toc;

figure;
    movegui('center')
    
    minlens = [2;2];  % minimum length scale along each dimension
    
    [kasd,asdstats] = fastASD(ax,ay,nks,minlens);
    subplot(121)
    imagesc(reshape(kasd,nks))
    subtitle('fast asd')
    subplot(122)
    imagesc(reshape(zz,nks))
    subtitle('cheap RF')
   

figure;
    movegui('center')
    sgtitle('changing response vector units')
    
    minlens = [2;2];  % minimum length scale along each dimension
    
    [kasd,asdstats] = fastASD(ax,ay,nks,minlens);
    subplot(221)
    imagesc(reshape(kasd,nks))
    subtitle('fast asd with spikes per bin? (ay)')
    subplot(222)
    imagesc(reshape(zz,nks))
    subtitle('cheap RF')
    
    movegui('center')
    ayS = round(ay*180);
    [kasd,asdstats] = fastASD(ax,ayS,nks,minlens);
    subplot(223)
    imagesc(reshape(kasd,nks))
    subtitle('fast asd with spike count (round(ay*180))')
    
    ayHz = ay/.180;
    [kasd,asdstats] = fastASD(ax,ayHz,nks,minlens);
    subplot(224)
    imagesc(reshape(kasd,nks))
    subtitle('fast asd with Hz (ay/.180))')


figure;
    movegui('center')
    sgtitle('changing minlens')

    minlens = [0.2;0.2];
    [kasd,asdstats] = fastASD(ax,ay,nks,minlens);
    subplot(321)
    imagesc(reshape(kasd,nks))
    subtitle('fast asd with spikes per bin, minlens[0.2;0.2]')
    
    minlens = [5;5];
    [kasd,asdstats] = fastASD(ax,ay,nks,minlens);
    subplot(322)
    imagesc(reshape(kasd,nks))
    subtitle('fast asd with spikes per bin, minlens[5;5]')
    
    minlens = [2.5;2.5];
    [kasd,asdstats] = fastASD(ax,ay,nks,minlens);
    subplot(323)
    imagesc(reshape(kasd,nks))
    subtitle('fast asd with spikes per bin, minlens[2.5;2.5]')

    minlens = [2.8;2.8];
    [kasd,asdstats] = fastASD(ax,ay,nks,minlens);
    subplot(324)
    imagesc(reshape(kasd,nks))
    subtitle('fast asd with spikes per bin, minlens[2.8;2.8]')
    
    minlens = [2.9;2.9];
    [kasd,asdstats] = fastASD(ax,ay,nks,minlens);
    subplot(325)
    imagesc(reshape(kasd,nks))
    subtitle('fast asd with spikes per bin, minlens[2.9;2.9]')

    minlens = [4;4];
    [kasd,asdstats] = fastASD(ax,ay,nks,minlens);
    subplot(326)
    imagesc(reshape(kasd,nks))
    subtitle('fast asd with spikes per bin, minlens[4;4]')



