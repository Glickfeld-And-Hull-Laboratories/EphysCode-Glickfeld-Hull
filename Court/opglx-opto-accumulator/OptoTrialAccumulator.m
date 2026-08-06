classdef OptoTrialAccumulator < handle
% OPTOTRIALACCUMULATOR  Trial accumulator / online PSTH for OP-GLX Event mode.
%
%   Add-on for the OP-GLX toolbox (github.com/yadavlabs/OP-GLX). OP-GLX Event
%   mode fetches ONE stimulus-aligned window per arming, processes it, plots it,
%   then stops. It does not accumulate or average across trials. This class
%   attaches to a running acquisition.SpikeFetcher, collects each optogenetic
%   trial's stimulus-aligned firing-rate matrix, builds a running trial-averaged
%   PSTH (mean +/- SEM), auto re-arms Event mode for the next pulse, and runs a
%   simple per-channel baseline-vs-evoked test so you can see in real time which
%   channels change their spiking.
%
%   IMPORTANT SCOPE NOTE. OP-GLX detects threshold-crossing events per CHANNEL,
%   not spike-sorted units. Everything below is per channel, not per unit. A
%   Neuropixels unit spans several channels and a channel may carry several
%   units, so treat a "responsive channel" as "a site whose threshold-crossing
%   rate changed", not "an isolated unit responded".
%
%   USAGE (attach to an already-running fetcher configured for Event mode):
%       acc = OptoTrialAccumulator(sf, ...
%               'RespWin_ms',[5 40], 'BaseWin_ms',[-100 0], ...
%               'TargetTrials',30, 'AutoRearm',true, 'InterTrial_s',0.25);
%       acc.start();                 % arms the first trial and begins collecting
%       ...                          % deliver opto trials; plot updates each trial
%       T = acc.resultsTable();      % ranked responsive-channel table at any time
%       acc.stop();                  % detach listeners, stop re-arm
%
%   The SpikeFetcher (sf) must already be constructed and its hParams fully
%   initialized (as they are when OP-GLX is running). See run_opto_accumulator.m
%   for how to obtain the handle and for the required parameter settings.
%
%   Requires: OP-GLX on the MATLAB path (+spikes, +acquisition namespaces),
%   Statistics and Machine Learning Toolbox (for tcdf; a normal approximation is
%   used as a fallback if tcdf is unavailable).
%
%   This is user-authored add-on code, not part of OP-GLX. It has been reviewed
%   statically against the OP-GLX source but NOT tested against live SpikeGLX
%   hardware. Validate on a pilot session before trusting it in an experiment.

    properties
        % --- configuration ---
        fetcher                         % handle to acquisition.SpikeFetcher
        RespWin_ms   = [5 40]           % evoked window, ms re stim onset (t=0)
        BaseWin_ms   = [-Inf 0]         % baseline window, ms (default: all pre-stim bins)
        TargetTrials = Inf              % stop after this many trials
        AutoRearm    = true             % re-arm Event mode after each trial / empty scan
        InterTrial_s = 0.25             % dead time before re-arming (s)
        Alpha        = 0.05             % significance level for the per-channel test
        Bonferroni   = true             % Bonferroni-correct alpha across channels
        MakePlot     = true             % draw/update the live figure
        FocusChan    = []               % channel ID to feature in the PSTH panel ([]=auto: most responsive)
        Channels     = []               % channel ID(s) to accumulate; [] = all recorded channels.
                                        %   e.g. 42 for a single channel, or [10 42 100] for a subset.
        Verbose      = true             % print a one-line summary each trial

        % --- accumulated data (read-only in practice) ---
        FR           = []               % [nBins x nChans x nTrials] firing rate, Hz
        t_ms         = []               % [nBins x 1] bin-center times, ms (0 = stim onset)
        chanIDs      = []               % [1 x nChans] channel IDs (params.NP.chans)
        nTrials      = 0                % number of collected trials
        baseline     = []               % [nTrials x nChans] mean rate in BaseWin, Hz
        evoked       = []               % [nTrials x nChans] mean rate in RespWin, Hz
        stats        = struct()         % latest per-channel test result (see computeStats)
    end

    properties (Access = private)
        lEvent  = []                    % listener: EventFetched
        lNoEvent = []                   % listener: EventNotFound
        rearmTimer = []                 % one-shot timer for deferred re-arm
        active = false
        colSel = []                     % column indices into the full firing-rate matrix
        fig = []
        ax = struct()
    end

    methods
        function obj = OptoTrialAccumulator(fetcher, varargin)
            if nargin < 1 || ~isa(fetcher, 'acquisition.SpikeFetcher')
                error('OptoTrialAccumulator:badFetcher', ...
                    'First argument must be an acquisition.SpikeFetcher handle.');
            end
            obj.fetcher = fetcher;
            % Name/Value overrides (public config properties only)
            allowed = {'RespWin_ms','BaseWin_ms','TargetTrials','AutoRearm', ...
                       'InterTrial_s','Alpha','Bonferroni','MakePlot','FocusChan', ...
                       'Channels','Verbose'};
            for k = 1:2:numel(varargin)
                name = varargin{k};
                if ~ischar(name) && ~(isstring(name) && isscalar(name))
                    error('OptoTrialAccumulator:badOption', 'Option names must be strings.');
                end
                name = char(name);
                if ~ismember(name, allowed)
                    error('OptoTrialAccumulator:badOption', ...
                        'Unknown or non-configurable option "%s".', name);
                end
                obj.(name) = varargin{k+1};
            end
        end

        function start(obj)
            % Attach listeners and arm the first trial.
            if obj.active
                warning('OptoTrialAccumulator:alreadyActive', 'Already running; call stop() first.');
                return;
            end
            obj.reset();
            obj.active = true;

            obj.lEvent   = addlistener(obj.fetcher, 'EventFetched',  @(~,~) obj.onEvent());
            obj.lNoEvent = addlistener(obj.fetcher, 'EventNotFound', @(~,~) obj.onNoEvent());

            % Arm Event mode now (does nothing if already armed by the app).
            obj.armEvent();
            if obj.active
                obj.log('Accumulator started; waiting for opto trials.');
            end
        end

        function stop(obj)
            % Detach and clean up.
            obj.active = false;
            delete(obj.lEvent);   obj.lEvent = [];
            delete(obj.lNoEvent); obj.lNoEvent = [];
            obj.killRearmTimer();
            obj.log(sprintf('Accumulator stopped after %d trial(s).', obj.nTrials));
        end

        function reset(obj)
            % Clear accumulated trials but keep configuration.
            obj.FR = []; obj.t_ms = []; obj.chanIDs = []; obj.colSel = [];
            obj.nTrials = 0; obj.baseline = []; obj.evoked = [];
            obj.stats = struct();
        end

        function T = resultsTable(obj)
            % Ranked per-channel responsiveness table (most responsive first).
            obj.computeStats();
            if isempty(obj.stats) || ~isfield(obj.stats, 'chan') || isempty(obj.stats.chan)
                T = table(); return;
            end
            s = obj.stats;
            T = table(s.chan(:), s.delta(:), s.tstat(:), s.pval(:), s.responsive(:), ...
                'VariableNames', {'Channel','DeltaRate_Hz','tStat','pValue','Responsive'});
            [~, ord] = sort(abs(T.tStat), 'descend', 'MissingPlacement','last');
            T = T(ord, :);
        end
    end

    methods (Access = private)
        % ---------- event handling ----------
        function onEvent(obj)
            if ~obj.active, return; end
            try
                fr = obj.computeTrialFiringRate();      % [nBins x nChans], Hz
                if isempty(fr), obj.deferRearm(); return; end
                [b, e] = obj.trialWindowMeans(fr);      % compute BEFORE committing state
                obj.commitTrial(fr, b, e);              % atomic: nTrials/FR/baseline/evoked together
                obj.computeStats();
                if obj.MakePlot, obj.updatePlot(); end
                obj.logTrial();
            catch ME
                warning('OptoTrialAccumulator:trialError', ...
                    'Incoming trial (#%d) skipped: %s', obj.nTrials+1, ME.message);
            end
            % Re-arm for the next pulse (deferred; the fetcher calls stop()
            % immediately AFTER this EventFetched callback returns).
            if obj.active && obj.nTrials < obj.TargetTrials
                obj.deferRearm();
            elseif obj.nTrials >= obj.TargetTrials
                obj.log(sprintf('Target of %d trials reached; stopping.', obj.TargetTrials));
                obj.stop();
            end
        end

        function onNoEvent(obj)
            % Scan window elapsed with no pulse: keep waiting if still active.
            if obj.active && obj.nTrials < obj.TargetTrials
                obj.deferRearm();
            end
        end

        function fr = computeTrialFiringRate(obj)
            % Recompute the stimulus-aligned firing rate for the current trial
            % window directly from the fetcher buffer. Self-contained: does not
            % depend on the parfeval worker result or on the selected plot type.
            fr = [];
            data = obj.fetcher.data_uV;                 % [window_samples x nChans], uV
            if isempty(data), return; end
            params = obj.fetcher.hParams.toStruct();
            res = spikes.getSpikeFiringRates(data, params);
            fr = res{4};                                % [max_bins x numel(NP.chans)], Hz
            allChans = params.NP.chans(:).';

            % Establish channel selection and the time axis on the first trial.
            if isempty(obj.t_ms)
                if isempty(obj.Channels)
                    obj.colSel  = 1:numel(allChans);    % all recorded channels
                    obj.chanIDs = allChans;
                else
                    [tf, loc] = ismember(obj.Channels(:).', allChans);
                    if ~all(tf)
                        error('OptoTrialAccumulator:badChannel', ...
                            'Requested Channels not in the recorded set: %s', ...
                            mat2str(obj.Channels(~tf)));
                    end
                    obj.colSel  = loc;                  % restrict to requested channel(s)
                    obj.chanIDs = allChans(loc);
                end
                obj.t_ms = obj.binCenters(params, size(fr,1));
            end

            % Keep only the selected channels.
            if size(fr,2) < max(obj.colSel)
                error('firing-rate has %d channels; cannot select column %d.', ...
                    size(fr,2), max(obj.colSel));
            end
            fr = fr(:, obj.colSel);

            % Guard against a size change mid-run.
            if size(fr,1) ~= numel(obj.t_ms) || size(fr,2) ~= numel(obj.chanIDs)
                error('firing-rate size [%d x %d] does not match locked axes [%d x %d].', ...
                    size(fr,1), size(fr,2), numel(obj.t_ms), numel(obj.chanIDs));
            end
        end

        function [b, e] = trialWindowMeans(obj, fr)
            % Per-trial mean rate in baseline and evoked windows -> [1 x nChans].
            bMask = obj.t_ms >= obj.BaseWin_ms(1) & obj.t_ms < obj.BaseWin_ms(2);
            rMask = obj.t_ms >= obj.RespWin_ms(1) & obj.t_ms < obj.RespWin_ms(2);
            if ~any(bMask)
                warning('OptoTrialAccumulator:noBaselineBins', ...
                    'No bins fall in BaseWin_ms=[%g %g]. Set a pre-stim window (OP.prestim_len>0).', ...
                    obj.BaseWin_ms(1), obj.BaseWin_ms(2));
            end
            if ~any(rMask)
                warning('OptoTrialAccumulator:noRespBins', ...
                    'No bins fall in RespWin_ms=[%g %g].', obj.RespWin_ms(1), obj.RespWin_ms(2));
            end
            b = mean(fr(bMask,:), 1, 'omitnan');
            e = mean(fr(rMask,:), 1, 'omitnan');
        end

        function commitTrial(obj, fr, b, e)
            % Single atomic state update so a mid-trial error cannot desync
            % FR (pages) from baseline/evoked (rows).
            n = obj.nTrials + 1;
            if isempty(obj.FR)
                obj.FR = fr;
            else
                obj.FR(:,:,n) = fr;
            end
            obj.baseline(n,:) = b;
            obj.evoked(n,:)   = e;
            obj.nTrials = n;
        end

        function computeStats(obj)
            % Paired baseline-vs-evoked test across trials, per channel.
            s = struct('chan',[],'delta',[],'tstat',[],'pval',[],'responsive',[], ...
                       'alpha',obj.Alpha,'nTrials',obj.nTrials);
            n = obj.nTrials;
            if n < 1 || isempty(obj.evoked)
                obj.stats = s; return;
            end
            d = obj.evoked - obj.baseline;              % [nTrials x nChans], paired diff
            md = mean(d, 1, 'omitnan');                 % [1 x nChans]
            nCh = numel(obj.chanIDs);
            if n >= 2
                sd = std(d, 0, 1, 'omitnan');
                se = sd ./ sqrt(n);
                tstat = md ./ se;
                tstat(se == 0) = 0;                     % no variance -> undefined; treat as 0
                if exist('tcdf','file')
                    pval = 2 * tcdf(-abs(tstat), n-1);
                else
                    pval = 2 * (1 - obj.normcdfLocal(abs(tstat)));  % normal approx fallback
                end
            else
                tstat = nan(1, nCh);
                pval  = nan(1, nCh);
            end
            aC = obj.Alpha;
            if obj.Bonferroni, aC = obj.Alpha / max(nCh,1); end
            responsive = pval < aC;

            s.chan = obj.chanIDs(:).';
            s.delta = md;
            s.tstat = tstat;
            s.pval = pval;
            s.responsive = responsive;
            s.alphaCorrected = aC;
            obj.stats = s;
        end

        % ---------- re-arming ----------
        function deferRearm(obj)
            % Schedule fetcher.start('Event') AFTER the current fetchChunk (which
            % calls obj.fetcher.stop() right after this callback) has finished.
            if ~obj.AutoRearm || ~obj.active, return; end
            obj.killRearmTimer();
            obj.rearmTimer = timer('Name','OTA_Rearm', ...
                'ExecutionMode','singleShot', ...
                'StartDelay', max(obj.InterTrial_s, 0.01), ...
                'TimerFcn', @(~,~) obj.armEvent());
            start(obj.rearmTimer);
        end

        function armEvent(obj)
            if ~obj.active, return; end
            % NOTE: do NOT pre-check IsRunning(sf.hSGL) here. The fetcher's
            % stop() (called right after each EventFetched) runs Close(hSGL),
            % destroying the socket; the handle is only rebuilt inside
            % start()->ensureConnection(). So start('Event') is the correct
            % entry point: it reconnects and internally verifies acquisition.
            try
                msg = obj.fetcher.start('Event');       % returns 'ok' on success
                if ~isempty(msg) && ~strcmpi(msg, 'ok')
                    % Non-recoverable (not acquiring / connection error): no
                    % events will fire, so stop cleanly instead of stalling.
                    obj.log(sprintf('Re-arm halted: %s', msg));
                    obj.stop();
                end
            catch ME
                warning('OptoTrialAccumulator:rearmError', 'Re-arm failed: %s', ME.message);
                obj.stop();
            end
        end

        function killRearmTimer(obj)
            if ~isempty(obj.rearmTimer) && isvalid(obj.rearmTimer)
                stop(obj.rearmTimer); delete(obj.rearmTimer);
            end
            obj.rearmTimer = [];
        end

        % ---------- plotting ----------
        function updatePlot(obj)
            if isempty(obj.fig) || ~isvalid(obj.fig)
                obj.fig = figure('Name','OP-GLX Opto Trial Accumulator','Color','w', ...
                    'NumberTitle','off');
                obj.ax.psth = subplot(2,2,1, 'Parent', obj.fig);
                obj.ax.heat = subplot(2,2,2, 'Parent', obj.fig);
                obj.ax.txt  = subplot(2,2,[3 4], 'Parent', obj.fig);
            end

            % --- pick focus channel (most responsive by |t|, else user choice) ---
            ch = obj.resolveFocusChan();
            ci = find(obj.chanIDs == ch, 1);
            if isempty(ci), ci = 1; ch = obj.chanIDs(1); end

            % --- PSTH panel: mean +/- SEM across trials for focus channel ---
            trace = squeeze(obj.FR(:, ci, :));          % [nBins x nTrials]
            if isvector(trace), trace = trace(:); end
            m = mean(trace, 2, 'omitnan');
            if obj.nTrials >= 2
                sem = std(trace, 0, 2, 'omitnan') ./ sqrt(obj.nTrials);
            else
                sem = zeros(size(m));
            end
            axP = obj.ax.psth; cla(axP); hold(axP,'on');
            xx = obj.t_ms(:);
            patch(axP, [xx; flipud(xx)], [m-sem; flipud(m+sem)], [0.2 0.4 0.8], ...
                'FaceAlpha',0.20, 'EdgeColor','none');
            plot(axP, xx, m, 'LineWidth', 1.5, 'Color', [0.15 0.3 0.7]);
            yl = ylim(axP);
            plot(axP, [0 0], yl, 'k--');                                   % stim onset
            obj.shadeSpan(axP, obj.RespWin_ms, yl, [0.9 0.5 0.2]);         % evoked window
            obj.shadeSpan(axP, obj.baseWinForPlot(), yl, [0.6 0.6 0.6]);   % baseline window
            hold(axP,'off');
            xlabel(axP,'Time from stim (ms)'); ylabel(axP,'Firing rate (Hz)');
            title(axP, sprintf('Ch %d  |  %d trial(s)', ch, obj.nTrials));

            % --- heatmap panel: trial-mean rate across all channels ---
            axH = obj.ax.heat; cla(axH);
            meanFR = mean(obj.FR, 3, 'omitnan');        % [nBins x nChans]
            imagesc(axH, obj.t_ms, 1:numel(obj.chanIDs), meanFR.');
            axis(axH,'tight'); colorbar(axH);
            hold(axH,'on'); plot(axH,[0 0],[0.5 numel(obj.chanIDs)+0.5],'w--'); hold(axH,'off');
            xlabel(axH,'Time from stim (ms)'); ylabel(axH,'Channel index');
            title(axH,'Trial-mean rate (Hz)');

            % --- text panel: responsive channel readout ---
            axT = obj.ax.txt; cla(axT); axis(axT,'off');
            lines = obj.summaryLines(8);
            text(axT, 0.02, 0.98, lines, 'VerticalAlignment','top', ...
                'FontName','FixedWidth', 'FontSize', 9, 'Interpreter','none');

            drawnow limitrate;
        end

        function ch = resolveFocusChan(obj)
            if ~isempty(obj.FocusChan)
                ch = obj.FocusChan; return;
            end
            if isfield(obj.stats,'tstat') && ~isempty(obj.stats.tstat) && any(~isnan(obj.stats.tstat))
                [~, idx] = max(abs(obj.stats.tstat));
                ch = obj.chanIDs(idx);
            else
                ch = obj.chanIDs(1);
            end
        end

        function w = baseWinForPlot(obj)
            w = obj.BaseWin_ms;
            if isinf(w(1)), w(1) = obj.t_ms(1); end
            if isinf(w(2)), w(2) = 0; end
        end

        function lines = summaryLines(obj, topN)
            lines = {sprintf('Trials collected: %d', obj.nTrials)};
            if ~isfield(obj.stats,'responsive') || isempty(obj.stats.responsive)
                lines{end+1} = '(need >= 2 trials for the responsiveness test)';
                return;
            end
            aC = obj.stats.alphaCorrected;
            nResp = sum(obj.stats.responsive);
            lines{end+1} = sprintf('Responsive channels: %d  (alpha=%.2g%s)', nResp, aC, ...
                ternary(obj.Bonferroni,' Bonferroni',''));
            T = obj.resultsTable();
            k = min(topN, height(T));
            lines{end+1} = 'rank  chan   dRate(Hz)     t      p        resp';
            for i = 1:k
                lines{end+1} = sprintf('%3d  %5d  %+9.2f  %+6.2f  %8.1e   %d', ...
                    i, T.Channel(i), T.DeltaRate_Hz(i), T.tStat(i), T.pValue(i), T.Responsive(i)); %#ok<AGROW>
            end
        end

        % ---------- small helpers ----------
        function t = binCenters(~, params, nBins)
            % Bin-center times (ms, 0 = stim onset), length exactly nBins.
            % getSpikeFiringRates rows = OP.max_bins, which can exceed
            % numel(OP.bin_centers) (edge-count) by trailing zero-pad bins, so
            % extend the real centers at the bin step rather than switching axes.
            bs_ms = params.OP.bin_size * 1000;
            if isfield(params.OP,'bin_centers') && ~isempty(params.OP.bin_centers)
                bc = params.OP.bin_centers(:);
                if numel(bc) >= nBins
                    t = bc(1:nBins);
                else
                    pad = bc(end) + (1:(nBins - numel(bc))).' * bs_ms;
                    t = [bc; pad];
                end
            else
                t0 = -double(params.OP.prestim_samples) / round(params.NP.fs) * 1000;
                t = t0 + ((0:nBins-1).' + 0.5) * bs_ms;
            end
            t = t(:);
        end

        function shadeSpan(~, ax, w, yl, col)
            if any(isinf(w)) || w(2) <= w(1), return; end
            patch(ax, [w(1) w(2) w(2) w(1)], [yl(1) yl(1) yl(2) yl(2)], col, ...
                'FaceAlpha',0.08, 'EdgeColor','none');
        end

        function p = normcdfLocal(~, x)
            p = 0.5 * (1 + erf(x ./ sqrt(2)));
        end

        function logTrial(obj)
            if ~obj.Verbose, return; end
            if isfield(obj.stats,'responsive') && ~isempty(obj.stats.responsive)
                obj.log(sprintf('Trial %d collected. Responsive channels so far: %d.', ...
                    obj.nTrials, sum(obj.stats.responsive)));
            else
                obj.log(sprintf('Trial %d collected.', obj.nTrials));
            end
        end

        function log(obj, msg)
            if obj.Verbose
                fprintf('[OptoTrialAccumulator %s] %s\n', ...
                    char(datetime('now','Format','HH:mm:ss')), msg);
            end
        end
    end
end

function out = ternary(cond, a, b)
    if cond, out = a; else, out = b; end
end
