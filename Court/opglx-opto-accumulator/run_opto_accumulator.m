%% run_opto_accumulator.m
% Example driver for OptoTrialAccumulator, an add-on to the OP-GLX toolbox
% (github.com/yadavlabs/OP-GLX) that turns OP-GLX Event mode into a trial
% accumulator: it collects each optogenetic trial's stimulus-aligned firing
% rate, builds a running trial-averaged PSTH (mean +/- SEM), auto re-arms Event
% mode for the next pulse, and flags channels whose spiking changes.
%
% ---------------------------------------------------------------------------
% WHAT OP-GLX ALREADY DOES, AND WHAT THIS ADDS
% ---------------------------------------------------------------------------
% OP-GLX Event mode (acquisition.SpikeFetcher, 'Event') does the timing-critical
% work: it scans the NI stream for your stimulus TTL (rising edge on a chosen
% digital line), maps that sample onto the Neuropixels stream, and fetches one
% window spanning pre-stim / stim / post-stim, aligned so t = 0 is stim onset.
% It then processes and PLOTS that single window and STOPS. It does NOT average
% across trials. This add-on supplies the missing accumulate + average + re-arm
% + responsiveness-test layer, without touching the fetch path.
%
% Detection in OP-GLX is per CHANNEL (threshold crossings), not spike-sorted
% units. Read every "channel" below as "recording site", not "isolated unit".
%
% ---------------------------------------------------------------------------
% PREREQUISITES
% ---------------------------------------------------------------------------
% 1. OP-GLX installed and on the MATLAB path (opglx.initialize() has run).
% 2. SpikeGLX acquiring, remote command server enabled, NI stream present.
% 3. Your optogenetic trigger TTL recorded on an NI digital line, and OP-GLX
%    event parameters pointing at it:
%        hParams.NI.event_chan   -> the NI digital channel being scanned
%        hParams.NI.stim_word    -> the bit within that word carrying your TTL
%    (OP-GLX finds a trial as a LOW->HIGH transition on that bit.)
% 4. A pre-stim window so there is a baseline to compare against:
%        hParams.OP.prestim_len  > 0   (e.g. 0.1 s)
%        hParams.OP.poststim_len covers your expected response (e.g. 0.1-0.2 s)
%        hParams.OP.bin_size     e.g. 5-10 ms for opto (default is 50 ms)
%    In the OP-GLX GUI these are set on the Initialization/parameter panel;
%    from a script they are set through the ParameterManager before starting.
%
% ---------------------------------------------------------------------------
% GETTING THE SpikeFetcher HANDLE (sf)
% ---------------------------------------------------------------------------
% This add-on attaches to an existing, initialized acquisition.SpikeFetcher.
%
%  (A) Running from the OP-GLX GUI (opglx.mlapp) -- NO app edit needed:
%      When you press the Initialize button, the app's InitializeButtonPushed
%      callback calls setupAcquisition, which builds app.fetcher AND already
%      runs  assignin('base','fetcher', app.fetcher).  So the moment Initialize
%      succeeds, the fetcher handle is in your base workspace as the variable
%      `fetcher`. Just alias it:      sf = fetcher;
%      Then select the firing-rate analysis tab, but do NOT click the app's own
%      "Fetch" (Continuous) or "Stimulate and Fetch" (Event) buttons -- let the
%      accumulator arm Event mode instead.
%      (Re-pressing Initialize builds a fresh fetcher and reassigns `fetcher`,
%      so re-run  sf = fetcher;  and reconstruct the accumulator if you do.)
%      (Only if a future OP-GLX release drops that assignin line: open the app
%      in App Designer, find setupAcquisition, and add
%      assignin('base','fetcher',app.fetcher)  right after the
%      app.fetcher = acquisition.SpikeFetcher(...) line.)
%
%  (B) Building the fetcher yourself in a script:
%      Construct acquisition.SpikeFetcher(...) as OP-GLX does and keep that
%      handle as `sf`.
% ---------------------------------------------------------------------------

% ====== 1. get your fetcher handle ======
if exist('sf','var')~=1 && exist('fetcher','var')==1
    sf = fetcher;                      % alias the handle the GUI exported at Initialize
end
assert(exist('sf','var')==1 && isa(sf,'acquisition.SpikeFetcher'), ...
    ['No SpikeFetcher found. Press Initialize in the OP-GLX GUI (it exports base ' ...
     'variable `fetcher`), then run  sf = fetcher;  -- or provide sf yourself.']);

% ====== 2. create the accumulator ======
acc = OptoTrialAccumulator(sf, ...
    'RespWin_ms',   [5 40], ...   % evoked window (ms after stim onset)
    'BaseWin_ms',   [-Inf 0], ... % baseline window (default: all pre-stim bins)
    'TargetTrials', 30, ...       % auto-stop after this many trials (Inf = run until stop())
    'AutoRearm',    true, ...     % re-arm Event mode after each pulse
    'InterTrial_s', 0.25, ...     % dead time before re-arming (raise if pulses are trains)
    'Alpha',        0.05, ...
    'Bonferroni',   true, ...     % correct across all channels
    'MakePlot',     true);

% ====== 3. start collecting ======
acc.start();                      % arms trial 1; the live figure updates each trial

% ...deliver your opto trials now. The figure shows the trial-averaged PSTH
%    for the most responsive channel, a channel x time heatmap, and a ranked
%    list of responsive channels, updating after every pulse...

% ====== 4. inspect results any time ======
% T = acc.resultsTable();          % ranked table: Channel, DeltaRate_Hz, tStat, pValue, Responsive
% disp(T(1:min(10,height(T)),:));

% ====== 5. stop and save ======
% acc.stop();
% FR = acc.FR;  t_ms = acc.t_ms;  chans = acc.chanIDs;   % [nBins x nChans x nTrials]
% save('opto_session.mat','FR','t_ms','chans');

% ---------------------------------------------------------------------------
% NOTES / CAVEATS
% ---------------------------------------------------------------------------
% * Per-channel, not per-unit: no spike sorting. A responsive "channel" is a
%   site whose threshold-crossing rate changed, not an isolated unit.
% * Re-arm timing: OP-GLX calls fetcher.stop() immediately after each event, so
%   re-arming is deferred by InterTrial_s via a one-shot timer. If your opto is
%   a pulse TRAIN, OP-GLX may treat each rising edge as an event; set
%   InterTrial_s longer than the train, or (for 'scs'-style single-latch lines)
%   use the stim_type handling already in OP-GLX so only the first pulse counts.
% * Statistics: paired baseline-vs-evoked t-test across trials, per channel,
%   Bonferroni-corrected by default. With hundreds of channels this is
%   conservative; consider FDR if you prefer. Needs >= 2 trials to report p.
% * Latency: OP-GLX end-to-end latency is ~6.5-10 ms (SpikeGLX MATLAB API
%   round-trip). Fine for trial-averaged opto readout; not sub-millisecond.
% * This is user add-on code, statically reviewed against the OP-GLX source but
%   not tested on live hardware. Validate on a pilot run.
