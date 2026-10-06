function plotAlluvialPhases(PDSind_byphase, CDSind_byphase, nCells, ttl)
% PDSind_byphase / CDSind_byphase: cell arrays (1 x nPhases) of cell indices
% State codes: 1 = PDS, 2 = CDS, 3 = unclassified
% Link color = state at phase 1 (origin cohort); node color = state at that phase
    nPhases = numel(PDSind_byphase);
    S = 3*ones(nCells, nPhases);
    for ph = 1:nPhases
        S(CDSind_byphase{ph}, ph) = 2;
        S(PDSind_byphase{ph}, ph) = 1;     % PDS wins if a cell is in both lists
    end
    nBoth = sum(cellfun(@(a,b) numel(intersect(a,b)), PDSind_byphase, CDSind_byphase));
    if nBoth > 0
        warning('%d cell-phase entries are in both PDS and CDS; counted as PDS.', nBoth);
    end

    cols  = [0.85 0.2 0.2; 0.2 0.4 0.85; 0.65 0.65 0.65];
    K = 3;  gap = 0.05*nCells;  nodeW = 0.12;
    hv = {'HandleVisibility','off'};

    N   = zeros(K, nPhases);
    top = zeros(K, nPhases);
    for p = 1:nPhases
        for k = 1:K, N(k,p) = sum(S(:,p)==k); end
        top(:,p) = [0; cumsum(N(1:end-1,p) + gap)];
    end

    hold on
    t = linspace(0,1,60);  s = 3*t.^2 - 2*t.^3;
    for p = 1:nPhases-1
        % T(o,a,b): cells that started in state o (phase 1), are in a at p, b at p+1
        T = zeros(K,K,K);
        for o = 1:K
            for a = 1:K
                for b = 1:K
                    T(o,a,b) = sum(S(:,1)==o & S(:,p)==a & S(:,p+1)==b);
                end
            end
        end
        Tab = reshape(sum(T,1), K, K);      % total a -> b flow (all origins)
        xs  = (p + nodeW/2) + (1 - nodeW)*t;

        for a = 1:K
            for b = 1:K
                for o = 1:K
                    w = T(o,a,b);
                    if w == 0, continue; end
                    sub = sum(T(1:o-1,a,b));                 % offset within the a->b link
                    y0  = top(a,p)   + sum(Tab(a,1:b-1)) + sub;   % outgoing: by dest, then origin
                    y1  = top(b,p+1) + sum(Tab(1:a-1,b)) + sub;   % incoming: by source, then origin
                    yt  = y0 + (y1 - y0)*s;
                    patch([xs fliplr(xs)], [yt fliplr(yt + w)], cols(o,:), ...
                          'FaceAlpha',0.5, 'EdgeColor','none', hv{:});
                end
            end
        end
    end

    for p = 1:nPhases
        for k = 1:K
            if N(k,p) == 0, continue; end
            patch(p + nodeW/2*[-1 1 1 -1], top(k,p) + [0 0 N(k,p) N(k,p)], ...
                  cols(k,:), 'EdgeColor','none', hv{:});
            text(p, top(k,p) + N(k,p)/2, sprintf('%d', N(k,p)), ...
                 'HorizontalAlignment','center','VerticalAlignment','middle', ...
                 'FontSize',7,'Color','w','FontWeight','bold', hv{:});
        end
        text(p, -0.05*nCells, sprintf('Phase %d', p), ...
             'HorizontalAlignment','center','FontWeight','bold','FontSize',8, hv{:});
    end

    text((nPhases+1)/2, -0.14*nCells, ttl, 'HorizontalAlignment','center', ...
         'FontWeight','bold','FontSize',10, hv{:});

    set(gca,'YDir','reverse'); axis off
    xlim([0.5 nPhases+0.5]);
    ylim([-0.18*nCells, max(top(:,1) + N(:,1)) + 0.02*nCells]);
end