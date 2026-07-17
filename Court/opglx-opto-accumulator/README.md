# OP-GLX Opto Trial Accumulator: Complete Setup and Run Guide

Hull Lab. Consolidated rig guide, 2026-07-16.

This is the single reference for running the optogenetic trial accumulator on top of
OP-GLX with the laser trigger recorded on an NI analog channel. It covers installing
the analog-trigger patch, launching and initializing OP-GLX, recovering the fetcher
handle, finding the correct channel, threshold, and edge (including the negative-
threshold case), verifying detection, and running the accumulator. A troubleshooting
section at the end lists the specific errors we hit and their fixes.

Files this guide uses (put all of them on the MATLAB path):
`OptoTrialAccumulator.m` (v0.3), `run_opto_accumulator.m`, `check_analog_trigger.m`,
`test_event_detection.m`, and the patched `extractEventSample.m`.

## What this does, in one paragraph

OP-GLX Event mode fetches a stimulus-aligned window of Neuropixels data around each
trigger and processes it once, then stops. It does not average across trials, and it
detects threshold crossings per channel, not sorted units. The accumulator attaches to
a running OP-GLX fetcher, collects each trial's stimulus-aligned firing rate, builds a
running trial-averaged PSTH with SEM, auto re-arms Event mode for the next pulse, and
runs a per-channel baseline-versus-evoked test so you can see which channels respond.
Everything below is per channel, not per sorted unit.

## Prerequisites

OP-GLX installed and `opglx.initialize()` run at least once. MATLAB R2024b or later
with the Statistics and Machine Learning, Signal Processing, DSP, Curve Fitting, and
Parallel Computing toolboxes. SpikeGLX with the remote command server enabled and an NI
stream present. Your laser TTL recorded on an NI analog input. A pre-stimulus window
greater than zero so the baseline test has data.

## Step 1: Install the patched detector (analog triggers)

OP-GLX finds a trigger by decoding one bit of a digital word. To detect the laser on an
analog channel, replace the one function that does that, `acquisition.extractEventSample`,
with the supplied backward-compatible patch. Find the installed copy:

    >> which acquisition.extractEventSample

Then either replace it in place (simplest), backing up the original first:

    >> src = which('acquisition.extractEventSample');
    >> copyfile(src, [src '.orig_backup']);
    >> copyfile('extractEventSample.m', src);

or shadow it without touching the toolbox by putting the patched file in a folder named
`+acquisition` inside a project directory and placing that directory first on the path:

    >> addpath('C:\path\to\your\project', '-begin');   % the dir that CONTAINS +acquisition

Confirm the patch is the active one before continuing:

    >> which acquisition.extractEventSample     % must point at YOUR patched file

If this still shows the toolbox copy, analog detection will silently never fire.

## Step 2: Start acquisition in SpikeGLX

Put SpikeGLX into the acquiring state, not merely open. Initialization in the next step
fails unless SpikeGLX is actively acquiring.

## Step 3: Open the OP-GLX app and Initialize

Open the OP-GLX GUI (type `opglx` in the command window or launch it from the Apps tab).
Set your parameters on the initialization panel: a pre-stim window greater than zero (for
example 0.1 s), a post-stim window covering the expected response (for example 0.1 to
0.2 s), and a bin size suited to optogenetics (5 to 10 ms rather than the 50 ms default).
Press Initialize. The button should change to "Initialized." If the message area says
"SpikeGLX not acquiring data," go back to Step 2. Do not press the app's own "Fetch" or
"Stimulate and Fetch" buttons at any point; the accumulator arms Event mode itself.

## Step 4: Recover the fetcher handle

The app stores the fetcher as a private property, so read it directly from the running
app window. With the OP-GLX window open and initialized:

    fig = findall(groot,'Type','figure','Name','OP-GLX');
    app = fig(end).RunningAppInstance;
    w   = struct(app);        % ignore the one-time warning
    sf  = w.fetcher;
    isa(sf,'acquisition.SpikeFetcher')    % must return true

If `sf` is empty, Initialize did not actually create the fetcher, which means SpikeGLX was
not acquiring when you pressed Initialize; fix that and repeat Steps 2 to 4.

## Step 5: Switch the detector to analog

    sf.hParams.NI.event_mode = 'analog';

You will set the channel, threshold, and edge in the next step using the diagnostics.
Note: in these commands, type real numbers. Placeholders like `A` or `C` in examples are
stand-ins; typing the letter `A` gives an "unrecognized variable" error.

## Step 6: Find the channel, threshold, and edge

Deliver laser pulses while running each diagnostic. First identify which analog channel
carries the pulse:

    check_analog_trigger(sf, 0:7, 3);     % probe NI channels 0..7 for 3 s; pulse during

Adjust `0:7` to however many NI channels SpikeGLX acquires. The channel whose trace shows
the pulse is your `event_chan` (indices are zero-based, analog channels before digital).

Then get the exact threshold and edge from the waveform:

    test_event_detection(sf, 5);          % waits 5 s; pulse during the capture

It prints a `SUGGESTED` line with the correct `event_thresh` and `event_edge` computed
from your actual pulse. This is where the sign matters: `event_edge = 'falling'` only sets
which direction of crossing counts as an event, it does not set the sign of the threshold.
If your pulse deflects negative (for example a baseline near zero dropping toward negative
32000 counts), the threshold value itself must be negative, and the `SUGGESTED` line will
show that. Set the three values to what the diagnostics reported:

    sf.hParams.NI.event_chan   = 5;        % <- the channel that showed the pulse
    sf.hParams.NI.event_thresh = -16000;   % <- SUGGESTED value, WITH its sign
    sf.hParams.NI.event_edge   = 'falling'; % <- SUGGESTED edge

Threshold reference for a clean 5 V TTL, if you prefer to set it by hand rather than from
the SUGGESTED line: put it about halfway between the idle level and the pulse level, with
the sign on the same side as the pulse. On a +/-5 V range a positive-going pulse is about
16000 and a negative-going pulse about -16000; on +/-10 V about half that magnitude. The
exact value for any range comes from SpikeGLX's own scaling:

    hSGL = SpikeGL(sf.hParams.address);
    vpc  = GetStreamI16ToVolts(hSGL, sf.hParams.NI.js, sf.hParams.NI.ip, sf.hParams.NI.event_chan);
    Close(hSGL);
    sf.hParams.NI.event_thresh = round(2.5 / vpc);   % use -2.5 for a negative-going pulse

## Step 7: Verify detection before running

Run the detector test once more and confirm it now finds the pulse:

    test_event_detection(sf, 5);          % pulse during; RESULT should say "event detected"

Two lines to check on this run. `RESULT` should report an event detected. And the
`detector file` line at the top must point at your patched `extractEventSample.m`; if it
points inside the toolbox, the analog settings are being ignored and you must fix Step 1.

## Step 8: Run the accumulator

    clear OptoTrialAccumulator            % only needed if you edited the class file
    acc = OptoTrialAccumulator(sf, ...
            'RespWin_ms',   [5 40], ...   % evoked window, ms after stim onset
            'BaseWin_ms',   [-Inf 0], ... % baseline window (default: all pre-stim bins)
            'TargetTrials', 30, ...       % auto-stop after this many trials
            'AutoRearm',    true, ...     % catch the next pulse automatically
            'InterTrial_s', 0.25);        % dead time before re-arming
    acc.start();

Deliver your opto trials. The figure updates after each pulse with the trial-averaged PSTH
for the most responsive channel, a channel-by-time heatmap, and a ranked list of
responsive channels. Do not press the app's Fetch or Stimulate-and-Fetch buttons.

To accumulate a single channel (or a subset) instead of all channels, pass `Channels`:

    acc = OptoTrialAccumulator(sf, 'Channels', 42, 'RespWin_ms',[5 40], 'TargetTrials',30);
    % or a subset:  'Channels', [10 42 100]

The value is the actual channel ID (the number in the `Channel` column of
`acc.resultsTable()` and in `acc.chanIDs`), not the heatmap row index. If you are not sure
which channel to pick, run one all-channel session first, read `resultsTable()`, then
restrict to the responding channel on the next run. `Channels` limits what is accumulated
and tested; `FocusChan` only chooses which accumulated channel is drawn in the PSTH.

## Step 9: Inspect and save

    T = acc.resultsTable();               % ranked: Channel, DeltaRate_Hz, tStat, pValue, Responsive
    disp(T(1:min(10,height(T)),:));

    acc.stop();
    FR = acc.FR;  t_ms = acc.t_ms;  chans = acc.chanIDs;   % [nBins x nChans x nTrials]
    save('opto_session.mat','FR','t_ms','chans');

## Troubleshooting: the specific problems we hit

`sf = fetcher` says fetcher is unrecognized. The app only exports `fetcher` after a fully
successful Initialize, and only in some builds. Use the Step 4 `struct(app)` recovery,
and make sure SpikeGLX was acquiring when you pressed Initialize (the button must read
"Initialized").

`w = struct(app)` says app is unrecognized. You launched the app without keeping its
handle. Use the Step 4 recovery, which finds the running app by its window name; do not
type `app` on its own.

Constructing the accumulator gives "too many input arguments" or "incorrect number or
types of inputs." MATLAB is running an old or duplicate copy of the class, not v0.3.
Check with `which OptoTrialAccumulator -all` (there should be exactly one, the v0.3 file)
and `nargin('OptoTrialAccumulator')` (must return -2, which means the constructor accepts
name/value pairs). If a stale copy is cached, run `clear OptoTrialAccumulator` and retry;
if that does not help, restart MATLAB and repeat from Step 3.

Setting `event_chan = A` gives "unrecognized function or variable." `A` and `C` in the
examples are placeholders. Type the actual number, for example `sf.hParams.NI.event_chan = 5;`.

No trials register, OP-GLX keeps saying "Event not found." Work through Step 6 and Step 7.
The usual causes are the channel index not matching the channel that shows the pulse, the
threshold not sitting between the idle and pulse levels (for a negative-going pulse the
threshold must be negative), the wrong edge, or the patched detector not being the active
file. `test_event_detection` prints all four of these.

`test_event_detection` returns instantly instead of waiting. That was an early version
that read past buffer history. The current version marks the sample count, waits the
requested seconds while you pulse, then analyzes that window and prints a `SUGGESTED` line.
Make sure you are on the current file.

## Standing caveats

Detection is per channel, not per sorted unit. Single probe. End-to-end latency about
6.5 to 10 ms, fine for trial-averaged opto but not sub-millisecond feedback. This is
user-authored add-on code, validated against the OP-GLX source and now exercised on the
rig for the analog-trigger path; keep a pre-stim window set and verify detection with
`test_event_detection` at the start of each session.

---

## Attribution

This is user-authored add-on code for the OP-GLX toolbox
(https://github.com/yadavlabs/OP-GLX; Slack, Rutledge & Yadav, bioRxiv 2026,
doi:10.64898/2026.03.04.709636). It is not part of OP-GLX and is not affiliated with
its authors. `extractEventSample.m` here is a backward-compatible replacement for the
toolbox function of the same name; install it as described in Step 1.
