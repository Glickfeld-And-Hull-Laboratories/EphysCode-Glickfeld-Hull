
% ===== INPUTS =====
%   CSDraw          = (nChannels-2) x samples
%   chnls           = list of true indices for channels in CSDraw
%   fs              = sampling rate
%   chanSpacing     = distance between channels (um)
%   depth           = distance of tip of electrode from surface of the brain (e.g., -2000)


function [L4_DepthShal, L4_DepthDeep, L4_shal_ch, L4_deep_ch] = alignCSDwithTemplate_L4(CSDraw, fs, chanSpacing, tipDepth)

templateHeight = 140; % µm
[nChan, nSamp] = size(CSDraw);

t = (0:nSamp-1)/fs;
yCSD = (1:nChan-1)*chanSpacing + tipDepth;   % match other figure indexing

figure('Color','w','Units','normalized','Position',[0.1 0.1 0.8 0.8]);
    imagesc(t, yCSD, -CSDraw); hold on
        xlabel('time (s)')
        ylabel('channels (every other)')
        set(gca,'TickDir','out')
        set(gca,'YDir','normal')
    title('current source density')
    annotation('textbox',[0.25 0.93 0.5 0.05],...
    'String','Move template to center L4. Press return when done. Try to align white lines with borders of channels.',...
    'EdgeColor','none',...
    'HorizontalAlignment','center',...
    'FontSize',11);

% Initial positionsep
midDepth = median(yCSD);

topDepth = midDepth - templateHeight/2;
botDepth = midDepth + templateHeight/2;

hTop = drawline('Position',[t(1) topDepth; t(end) topDepth],'Color',[1 1 1],'LineWidth',1);
hBot = drawline('Position',[t(1) botDepth; t(end) botDepth],'Color',[1 1 1],'LineWidth',1);

% Lock horizontal movement
addlistener(hTop,'MovingROI',@(src,evt) moveTemplate(src,hBot,templateHeight));
addlistener(hBot,'MovingROI',@(src,evt) moveTemplate(src,hTop,-templateHeight));

% Wait for Enter
set(gcf,'KeyPressFcn',@keypress)
uiwait

% read the vertical position of the line (read in um, not channel numbers)
% because of imagesc, the bot and top created above are the opposite of our
% manipulation, so swap them back
yBot = hTop.Position(1,2);
yTop = hBot.Position(1,2);

% The white lines define:
% yTop  = shallower boundary
% yBot  = deeper boundary
% 
% So channels inside L4 satisfy:
% yBot < channel_depth < yTop 
% (Because electrode tip is at 0, yTop is actually at a higher channel
% value than yBot)

L4_top_csd_ch       = find(yTop < yCSD+10,1,'first');   % first channel below top boundary (using center of channel, not the boundary)
L4_bottom_csd_ch    = find(yBot > yCSD+10,1,'last'); % last channel above bottom boundary (using center of channel, not the boundary)

% Add one to account for the dropped first channel to compute the CSD and
% then get real channel value
L4_shal_ch      = L4_top_csd_ch + 1;
L4_deep_ch      = L4_bottom_csd_ch + 1;
L4_DepthShal    = L4_shal_ch*chanSpacing;
L4_DepthDeep    = L4_deep_ch*chanSpacing;

fprintf('Layer 4 shallow channel: %d, depth= %d\n',L4_shal_ch, L4_DepthShal)
fprintf('Layer 4 deep channel: %d, depth= %d\n',L4_deep_ch, L4_DepthDeep)

close

    figure
        subplot 132
            imagesc(t, yCSD, -CSDraw); hold on
            plot(1:nChan-1,yCSD,'k','LineWidth',1.5); hold on
            % plot selected boundaries
            yline(yTop,'b--','LineWidth',1)
            yline(yBot,'r--','LineWidth',1)
            % mark selected channels
            scatter(L4_top_csd_ch,yCSD(L4_top_csd_ch),80,'b','filled')
            scatter(L4_bottom_csd_ch,yCSD(L4_bottom_csd_ch),80,'r','filled')
            xlabel('CSD channel index')
            ylabel('depth (\mum)')
            title('Selected L4 boundaries, shallow (blue) and deep (red)')
            set(gca,'YDir','normal')
            set(gca,'TickDir','out')
            grid on

    function keypress(~,event)
        if strcmp(event.Key,'return')
            uiresume
        end
    end
end


function moveTemplate(activeLine, otherLine, offset)
pos = activeLine.Position;

% lock horizontal
y = mean(pos(:,2));
pos(:,2) = y;
activeLine.Position = pos;

% move paired line with fixed offset
otherPos = otherLine.Position;
otherPos(:,2) = y + offset;
otherLine.Position = otherPos;

end