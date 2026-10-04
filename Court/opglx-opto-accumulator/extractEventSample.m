function event_sample = extractEventSample(data_ni, si_ni, params)
%EXTRACTEVENTSAMPLE  Find a stimulus-trigger edge on the NI stream (analog OR digital).
%
%   Drop-in, BACKWARD-COMPATIBLE replacement for the OP-GLX toolbox function
%   acquisition.extractEventSample. It lets the trial trigger be read from either
%   an NI ANALOG channel (e.g. a laser TTL on an analog input) or an NI DIGITAL
%   line, selectable at run time, without changing any other part of OP-GLX.
%
%   Detection mode is selected by params.NI.event_mode:
%     'digital' (default): decode bit params.NI.stim_word from the fetched
%               digital word and find the edge (original OP-GLX behavior,
%               extended here to honor event_edge and to return one event).
%     'analog' : threshold the fetched analog channel at params.NI.event_thresh
%               (in int16 counts) and find the edge.
%
%   Parameters (set on sf.hParams.NI; see setTrigger.m for a one-line switch):
%     Both modes:
%       NI.event_chan   channel carrying the trigger. For 'digital' this is the
%                       digital word channel; for 'analog' the analog channel
%                       index (within the NI stream). findEvent fetches exactly
%                       this channel, so nothing else in OP-GLX changes.
%       NI.event_edge   'rising' (default) or 'falling'.
%     Digital only:
%       NI.stim_word    bit (1-indexed) within the digital word to decode.
%     Analog only:
%       NI.event_thresh crossing threshold in int16 counts. For a negative-going
%                       pulse this value is NEGATIVE; event_edge sets only the
%                       direction of crossing, not the sign of the threshold.
%
%   In both modes a single event (the first qualifying edge in the scan block)
%   is returned, so the returned sample is always scalar and the accumulator can
%   re-arm cleanly for the next trial. Returns the absolute NI sample index of
%   the event, or [] if none is found in the block (same contract as the
%   original function).

    % --- resolve mode (default digital -> original behavior) ---
    mode = 'digital';
    if isfield(params.NI, 'event_mode') && ~isempty(params.NI.event_mode)
        mode = lower(char(params.NI.event_mode));
    end

    % --- resolve edge (shared by both modes; default rising) ---
    edge = 'rising';
    if isfield(params.NI, 'event_edge') && ~isempty(params.NI.event_edge)
        edge = lower(char(params.NI.event_edge));
    end

    % Operate on a single column, matching the single-channel fetch in findEvent.
    if size(data_ni, 2) > 1
        data_ni = data_ni(:, 1);
    end

    switch mode
        case 'analog'
            if ~isfield(params.NI, 'event_thresh') || isempty(params.NI.event_thresh)
                error('extractEventSample:noThresh', ...
                    ['Analog event mode requires params.NI.event_thresh ' ...
                     '(threshold in int16 counts).']);
            end
            % Binarize the analog trace at the threshold, then find edges.
            level = double(data_ni) > double(params.NI.event_thresh);

        otherwise  % 'digital'
            if ~isfield(params.NI, 'stim_word') || isempty(params.NI.stim_word)
                error('extractEventSample:noStimWord', ...
                    'Digital event mode requires params.NI.stim_word (bit index).');
            end
            % Decode the chosen bit of the digital word -> logical 0/1 over time.
            level = logical(bitget(data_ni, params.NI.stim_word, 'int16'));
    end

    % --- find the first qualifying edge (identical logic for both modes) ---
    if strcmp(edge, 'falling')
        stim_loc = find(diff(level) < 0) + 1;   % high -> low
    else
        stim_loc = find(diff(level) > 0) + 1;   % low  -> high (default)
    end
    if ~isempty(stim_loc)
        stim_loc = stim_loc(1);                 % one trial per scan block
    end

    % return empty if no event is present in this block
    if isempty(stim_loc)
        event_sample = [];
        return;
    end

    event_sample = (stim_loc + double(si_ni) - 1);

end
