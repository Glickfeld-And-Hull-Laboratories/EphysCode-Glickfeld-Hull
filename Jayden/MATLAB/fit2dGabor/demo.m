%% This demo loads 10 example patches and uses fit2dGabor to fit a Gabor
%% function to them.

clearvars -except add1 add2 checkpoint_dir errorfile_dir mainpath output_dir pathlist workspace_path skipkeep newfolderold;
close all
clc

load trialData.mat

%% set options

options.shape = 'elliptical'; % shape: 'elliptical' or 'equal'
options.runs  = 100;

options.parallel = false;% turn this off if you don't have the parallel toolbox.
options.visualize = true;% turn this off if you don't want to visualize

%% run fits
results=cell(size(data,3),1);
i=1;
waitbarFigure = waitbar(0,['Progress of fitting process. Finished 0 of ' num2str(size(data,3)) ' fits.']);
while i <= size(data,3)
    %     try
    results{i}=fit2dGabor(data(:,:,i),options);
    waitbar (i/size(data,3),waitbarFigure,['Progress of fitting process. Finished ' num2str(i) ' of ' num2str(size(data,3)) ' fits.'])
    i = i + 1;
    %     catch
    %         disp('catched an error, trying again.');
    %         continue;
    %     end
    
end


% The Parallel pool will not be reopened each time you call the function.
% So delete it afterwards.
if options.parallel
    %     delete(gcp('nocreate'))
end


%% plot the results
figure('units','normalized','outerposition',[0 0 1 1]);
setappdata(gcf, 'SubplotDefaultAxesLocation', [0 0 1 1]);
set(gcf,'Name','Visualization of best fits','NumberTitle','off');

size_dispGrid=NaN(1,2);
size_dispGrid(:)=ceil(sqrt(size(results,1)));
while size_dispGrid(2) * (size_dispGrid(1)-1) >= size(results,1)
    size_dispGrid(1) = size_dispGrid(1)-1;
end
for i = 1 : size(results,1)
    if isempty(results{i}) || isempty(results{i}.patch)
        continue;
    end
    subplot(size_dispGrid(1),size_dispGrid(2),i)
    imagesc([data(:,:,i),...
        ones(size(data(:,:,i),1),1)*min(min(min(data(:,:,i))),min(results{i}.patch(:))),...
        results{i}.patch]);
    colormap gray; axis image; axis off;
    if size(results,1) < 30
        title({'Left: input data','Right: best fit'});
    end
end