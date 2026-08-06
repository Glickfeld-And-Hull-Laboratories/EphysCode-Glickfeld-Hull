function test_event_detection(sf, secs)
%TEST_EVENT_DETECTION  Run OP-GLX's own event detector on a fresh NI capture.
%
%   test_event_detection(sf)       % capture 3 s of the event channel and test
%   test_event_detection(sf, 5)    % capture 5 s
%
%   DELIVER LASER PULSES while this runs. It fetches the configured event
%   channel (NI.event_chan) and calls the SAME function findEvent calls,
%   acquisition.extractEventSample, with your live parameters. It then reports:
%     - which extractEventSample file is actually on the path (patched vs toolbox)
%     - your current analog settings
%     - whether an event was detected, and where
%     - the number of rising and falling crossings of your threshold
%
%   This isolates the detector from the acquisition timing. If it detects an
%   event here but OP-GLX still says "Event not found", the problem is arming/
%   timing, not detection. If it detects NOTHING here, the printed diagnostics
%   tell you why (wrong file, wrong channel, or threshold not between levels).

    if nargin < 2 || isempty(secs), secs = 3; end

    js = sf.hParams.NI.js;
    ip = sf.hParams.NI.ip;
    ch = sf.hParams.NI.event_chan;

    hSGL = SpikeGL(sf.hParams.address);
    closer = onCleanup(@() Close(hSGL)); %#ok<NASGU>
    if ~IsRunning(hSGL)
        error('test_event_detection:notAcquiring', 'SpikeGLX is not acquiring.');
    end
    fs  = GetStreamSampleRate(hSGL, js, ip);
    % Capture FORWARD: mark now, wait while you pulse, then fetch that window.
    s0  = double(GetStreamSampleCount(hSGL, js, ip));
    fprintf('\n>>> Deliver laser pulses NOW -- capturing %.1f s ...\n', secs); drawnow;
    pause(secs);
    cnt = double(GetStreamSampleCount(hSGL, js, ip));
    n   = cnt - s0;
    if n < 1
        error('test_event_detection:noNewData', ...
              'No new samples advanced during capture. Is SpikeGLX still acquiring?');
    end
    [d, si] = Fetch(hSGL, js, ip, s0, n, ch);
    dd = double(d(:, 1));

    thr = getf(sf.hParams.NI, 'event_thresh', NaN);

    fprintf('\n--- event-detector test ---\n');
    fprintf('detector file : %s\n', which('acquisition.extractEventSample'));
    fprintf('event_mode    : %s\n', getf(sf.hParams.NI, 'event_mode', '<unset -> digital>'));
    fprintf('event_chan    : %d\n', ch);
    fprintf('event_thresh  : %g counts\n', thr);
    fprintf('event_edge    : %s\n', getf(sf.hParams.NI, 'event_edge', 'rising (default)'));
    fprintf('capture       : %d samples, level min=%+d max=%+d counts\n', ...
            numel(dd), round(min(dd)), round(max(dd)));
    if ~isnan(thr)
        fprintf('crossings     : rising(low->high)=%d  falling(high->low)=%d\n', ...
                sum(diff(dd > thr) > 0), sum(diff(dd > thr) < 0));
    end

    % Recommend the correct settings straight from the captured waveform.
    base = median(dd);
    [~, ix] = max(abs(dd - base));
    pk  = dd(ix);
    mid = round((base + pk) / 2);
    if pk < base, sedge = 'falling'; else, sedge = 'rising'; end
    fprintf('SUGGESTED     : baseline~%+d, pulse~%+d counts  ->  set event_thresh=%d , event_edge=''%s''\n', ...
            round(base), round(pk), mid, sedge);

    % Call the exact function findEvent uses, with the live parameter object.
    ev = acquisition.extractEventSample(d, si, sf.hParams);
    if isempty(ev)
        fprintf('RESULT        : NO event detected in this capture.\n');
    else
        fprintf('RESULT        : event detected at sample %d (%.3f s into capture)\n', ...
                ev(1), (ev(1) - si) / fs);
    end
    fprintf('---------------------------\n\n');
end

function v = getf(s, f, dflt)
    if isfield(s, f) && ~isempty(s.(f)), v = s.(f); else, v = dflt; end
end
