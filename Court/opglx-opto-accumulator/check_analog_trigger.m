function check_analog_trigger(sf, chanList, secs)
%CHECK_ANALOG_TRIGGER  Diagnose the analog laser-trigger channel and threshold.
%
%   check_analog_trigger(sf)            % probe the current NI.event_chan, 2 s
%   check_analog_trigger(sf, 0:5)       % probe NI channels 0..5
%   check_analog_trigger(sf, 0:5, 3)    % ... capturing 3 s each
%
%   DELIVER LASER PULSES while this runs. For each candidate NI channel it
%   fetches the most recent samples directly from SpikeGLX, plots the trace
%   with your threshold drawn on it, and prints:
%     - min / max in raw int16 counts and in volts
%     - peak-to-peak amplitude in counts
%     - how many times the trace would cross NI.event_thresh (the detector's test)
%
%   Read it like this:
%     * The channel whose trace shows the laser pulse is your event_chan.
%     * If a pulse is visible but "crossings above event_thresh" is 0, your
%       threshold is too high: set event_thresh roughly halfway up the step
%       (about half the max count shown).
%     * If no channel shows a pulse, the TTL is not reaching any NI analog
%       input SpikeGLX is streaming (check wiring / SpikeGLX channel setup).
%
%   Stop the accumulator first (acc.stop()) so this does not compete with its
%   scan timer for the SpikeGLX command server. This opens its own connection.

    if nargin < 3 || isempty(secs),     secs = 2; end
    if nargin < 2 || isempty(chanList), chanList = sf.hParams.NI.event_chan; end

    js = sf.hParams.NI.js;
    ip = sf.hParams.NI.ip;
    thr = [];
    if isfield(sf.hParams.NI, 'event_thresh') && ~isempty(sf.hParams.NI.event_thresh)
        thr = double(sf.hParams.NI.event_thresh);
    end

    hSGL = SpikeGL(sf.hParams.address);          % own connection
    closer = onCleanup(@() Close(hSGL));         %#ok<NASGU>  closes on exit/error
    if ~IsRunning(hSGL)
        error('check_analog_trigger:notAcquiring', ...
              'SpikeGLX is not acquiring. Start acquisition first.');
    end

    fs = GetStreamSampleRate(hSGL, js, ip);
    n  = round(secs * fs);

    figure('Name', 'NI analog trigger check', 'Color', 'w');
    nC = numel(chanList);

    fprintf('\n--- NI analog trigger check (deliver pulses now) ---\n');
    for i = 1:nC
        ch = chanList(i);
        cnt = double(GetStreamSampleCount(hSGL, js, ip));
        s0  = max(0, cnt - n);                   % most recent ~secs of data
        [d, ~] = Fetch(hSGL, js, ip, s0, n, ch);
        d = double(d(:, 1));

        vpc = GetStreamI16ToVolts(hSGL, js, ip, ch);   % volts per count
        pk = max(d); tr = min(d);
        fprintf('NI ch %d:  min=%+d  max=%+d counts  (%.3f to %.3f V)  p2p=%d counts\n', ...
                ch, round(tr), round(pk), tr*vpc, pk*vpc, round(pk - tr));
        if ~isempty(thr)
            nCross = sum(diff(d > thr) > 0);
            fprintf('          crossings above event_thresh=%d : %d\n', round(thr), nCross);
        end

        ax = subplot(nC, 1, i);
        plot(ax, (0:numel(d)-1)/fs, d); grid(ax, 'on');
        ylabel(ax, sprintf('ch %d', ch));
        if ~isempty(thr)
            yline(ax, thr, 'r--', 'event\_thresh');
        end
        if i == 1,  title(ax, 'Deliver laser pulses during this capture'); end
        if i == nC, xlabel(ax, 'time (s)'); end
    end
    fprintf('---------------------------------------------------\n\n');
end
