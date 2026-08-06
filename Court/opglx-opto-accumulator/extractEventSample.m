function event_sample = extractEventSample(data_ni, si_ni, params)
%EXTRACTEVENTSAMPLE  Find the rising edge of a stimulus event on the NI stream.
%
%   Drop-in, BACKWARD-COMPATIBLE replacement for the OP-GLX toolbox function
%   acquisition.extractEventSample. Adds analog-input event detection so the
%   stimulus trigger (e.g. a laser TTL) can be read from an NI ANALOG channel
%   instead of a digital line, without changing any other part of OP-GLX.
%
%   Detection mode is selected by params.NI.event_mode:
%     'digital' (default, unchanged behavior): decode bit params.NI.stim_word
%               from the fetched digital word (original OP-GLX behavior).
%     'analog' : threshold the fetched analog channel at params.NI.event_thresh
%               (in int16 counts) and take the first threshold crossing.
%
%   Extra parameters used only in analog mode (set on sf.hParams.NI):
%     NI.event_thresh  (required) crossing threshold in int16 counts.
%     NI.event_edge    (optional) 'rising' (default) or 'falling'.
%
%   In BOTH modes params.NI.event_chan must point at the channel actually
%   carrying the trigger: the digital word channel for 'digital', or the
%   analog channel index (within the NI stream) for 'analog'. findEvent
%   fetches exactly that channel, so nothing else in OP-GLX needs to change.
%
%   Returns the absolute NI sample index of the event, or [] if none is found
%   in this scan block (identical contract to the original function).

    % --- resolve mode (default digital -> original behavior) ---
    mode = 'digital';
    if isfield(params.NI, 'event_mode') && ~isempty(params.NI.event_mode)
        mode = lower(char(params.NI.event_mode));
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
            edge = 'rising';
            if isfield(params.NI, 'event_edge') && ~isempty(params.NI.event_edge)
                edge = lower(char(params.NI.event_edge));
            end
            % Binarize the analog trace at the threshold, then find edges.
            above = double(data_ni) > double(params.NI.event_thresh);
            if strcmp(edge, 'falling')
                stim_loc = find(diff(above) < 0) + 1;   % high -> low
            else
                stim_loc = find(diff(above) > 0) + 1;   % low -> high (default)
            end
            % One trial per scan block: keep only the first crossing so the
            % returned sample is always scalar (the accumulator re-arms for the
            % next pulse). event_scan_len bounds how close two pulses may be.
            if ~isempty(stim_loc)
                stim_loc = stim_loc(1);
            end

        otherwise  % 'digital' -- original OP-GLX behavior, unchanged
            data_event = bitget(data_ni, params.NI.stim_word, 'int16');
            stim_loc = find(diff(data_event) > 0) + 1;
            % scs stimulus presents all pulses on the event line; take the first.
            % Guard against an empty block (the normal no-event scan) so this
            % matches the original function's crash-free [] contract.
            if ~isempty(stim_loc) && strcmp(params.OP.stim_type, 'scs')
                stim_loc = stim_loc(1);
            end
    end

    % return empty if no event is present in this block
    if isempty(stim_loc)
        event_sample = [];
        return;
    end

    event_sample = (stim_loc + double(si_ni) - 1);

end
