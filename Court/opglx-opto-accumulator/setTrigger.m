function setTrigger(sf, mode, varargin)
%SETTRIGGER  Configure the trial trigger on an OP-GLX fetcher: analog or digital.
%
%   One call sets sf.hParams.NI.event_mode plus the fields that mode needs, so
%   you can switch the trial trigger between an analog channel and a digital line
%   without remembering which parameters go with which mode.
%
%   ANALOG (threshold crossing on an analog channel):
%     setTrigger(sf, 'analog', 'chan', A, 'thresh', C)
%     setTrigger(sf, 'analog', 'chan', A, 'thresh', C, 'edge', 'falling')
%       chan   : analog channel index in the NI stream (0-based)
%       thresh : crossing threshold in int16 counts (NEGATIVE for a
%                negative-going pulse)
%       edge   : 'rising' (default) or 'falling'
%
%   DIGITAL (bit of the digital word):
%     setTrigger(sf, 'digital', 'chan', D, 'bit', B)
%     setTrigger(sf, 'digital', 'chan', D, 'bit', B, 'edge', 'falling')
%       chan : digital word channel index in the NI stream
%       bit  : bit within the word (1-indexed) carrying the trigger
%       edge : 'rising' (default) or 'falling'
%
%   Example of switching back and forth:
%     setTrigger(sf, 'analog',  'chan', 5, 'thresh', -16000, 'edge', 'falling');
%     setTrigger(sf, 'digital', 'chan', 1, 'bit', 4);     % back to a digital TTL
%
%   After calling this, verify with  test_event_detection(sf, 5)  before running
%   the accumulator. This only sets parameters; it does not start acquisition.

    mode = lower(char(mode));
    p = inputParser;
    p.addParameter('chan',   [], @(x) isnumeric(x) && isscalar(x));
    p.addParameter('thresh', [], @(x) isnumeric(x) && isscalar(x));
    p.addParameter('bit',    [], @(x) isnumeric(x) && isscalar(x));
    p.addParameter('edge', 'rising', @(x) any(strcmpi(x, {'rising','falling'})));
    p.parse(varargin{:});
    o = p.Results;

    switch mode
        case 'analog'
            if isempty(o.chan),   error('setTrigger:chan',   'analog mode needs ''chan'' (analog channel index).'); end
            if isempty(o.thresh), error('setTrigger:thresh', 'analog mode needs ''thresh'' (int16 counts).'); end
            sf.hParams.NI.event_mode   = 'analog';
            sf.hParams.NI.event_chan   = o.chan;
            sf.hParams.NI.event_thresh = o.thresh;
            sf.hParams.NI.event_edge   = lower(o.edge);
            fprintf(['[setTrigger] ANALOG: chan=%d, thresh=%d counts, edge=%s\n'], ...
                    o.chan, round(o.thresh), lower(o.edge));

        case 'digital'
            if isempty(o.chan), error('setTrigger:chan', 'digital mode needs ''chan'' (digital word channel index).'); end
            if isempty(o.bit),  error('setTrigger:bit',  'digital mode needs ''bit'' (1-indexed bit in the word).'); end
            sf.hParams.NI.event_mode = 'digital';
            sf.hParams.NI.event_chan = o.chan;
            sf.hParams.NI.stim_word  = o.bit;
            sf.hParams.NI.event_edge = lower(o.edge);
            fprintf(['[setTrigger] DIGITAL: chan=%d, bit(stim_word)=%d, edge=%s\n'], ...
                    o.chan, o.bit, lower(o.edge));

        otherwise
            error('setTrigger:mode', 'mode must be ''analog'' or ''digital'' (got ''%s'').', mode);
    end
end
