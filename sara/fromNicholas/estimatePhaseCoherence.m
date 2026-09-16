function Phi = estimatePhaseCoherence(RF, xgrid, ygrid, PO, SF, beta)
% estimatePhaseCoherence  Estimate the phase-coherence statistic Phi from
% a measured 2D receptive field map (see plaid_theory_derivations.pdf,
% Section 4, Eq. 6).
%
%   Phi = | sum_{x,y} RF(x,y) * exp(i*a*x_perp(x,y)) |  /  sum_{x,y} |RF(x,y)|
%
% where x_perp(x,y) is position (x,y) projected onto the axis
% PERPENDICULAR to the cell's preferred orientation/direction PO, and
%   a = 2*pi*SF*sind(beta)
% is the plaid's BEAT spatial frequency -- not the grating's own spatial
% frequency -- with beta half the angle between the plaid's two
% components (beta = 60 deg for the conventional 120-deg-separation
% plaid). Equivalent to: collapse RF onto the perpendicular-to-PO axis,
% take the 1D Fourier transform of that profile at frequency a, and
% normalize by the profile's total unsigned weight -- but computed here
% as a single direct 2D sum, which is mathematically identical (Fubini)
% and needs no explicit image rotation or profile-collapse step.
%
% INPUTS
%   RF     : Ny x Nx matrix, the receptive field map (e.g. a
%            baseline-subtracted or z-scored spatial map of the
%            isolated feedforward/thalamic excitatory drive, from
%            reverse correlation to flashed light/dark squares). Phi is
%            a SHAPE statistic (normalized by total |RF|), so an overall
%            amplitude/gain factor on RF does not matter -- but RF
%            should represent spatially-structured drive, not raw
%            absolute firing rate riding on an arbitrary baseline.
%
%            IMPORTANT -- sign convention: RF should be SIGNED (positive
%            for ON/light-preferring pixels, negative for OFF/dark-
%            preferring pixels), and it is used SIGNED, not rectified.
%            This matches the underlying model directly: an OFF-center
%            afferent contributes to the cortical F1 response with an
%            extra pi added to its phase relative to an ON-center
%            afferent at the same position (see lgnaggregateONOFF.m,
%            pol = [0,0,pi,pi]), i.e. exp(i*(...)+i*pi) = -exp(i*(...)).
%            A negative RF value at a pixel is therefore exactly
%            equivalent to a positive (ON-like) contribution carrying an
%            extra 180-deg phase shift, which is precisely what
%            multiplying by the RAW SIGNED value inside the complex sum
%            already achieves -- no separate rectification step is
%            needed or correct. Only the normalizing denominator uses
%            abs(RF), so that Phi remains bounded in [0,1] (triangle
%            inequality) while the numerator preserves the ON/OFF sign
%            information that the coherence calculation depends on.
%            A real oscillating (multi-lobed, Gabor-like) combined RF
%            will genuinely produce a SMALLER Phi than a single-signed
%            blob of the same envelope, because alternating ON/OFF
%            subfields really do add out of phase in the aggregate
%            response -- this is not an artifact to be corrected away.
%   xgrid  : 1 x Nx vector, x-coordinate (deg of visual angle) of each
%            column of RF
%   ygrid  : Ny x 1 (or 1 x Ny) vector, y-coordinate (deg of visual
%            angle) of each row of RF
%   PO     : preferred orientation/direction of the cell (deg),
%            measured independently (e.g. from drifting-grating tuning)
%   SF     : spatial frequency of the grating/plaid used in the plaid
%            experiment (cycles/deg) -- must be the SAME spatial
%            frequency as the plaid stimulus itself, not an arbitrary
%            probe frequency, and xgrid/ygrid must be in the same
%            (deg of visual angle) units
%   beta   : (optional) half the angle between the plaid's two
%            components (deg); default 60, i.e. the conventional
%            120-deg-separation plaid. MUST match whatever plaid
%            geometry was actually used -- Phi's relevant spatial
%            frequency is k*sin(beta), not k alone (see
%            plaid_theory_derivations.pdf Section 5).
%
% OUTPUT
%   Phi    : phase-coherence estimate, in [0,1]. High Phi -> RF is
%            compact relative to the beat wavelength 2*pi/a along the
%            perpendicular-to-PO axis (phase-robust); low Phi -> RF
%            spans multiple beat periods along that axis (phase-fragile).

if nargin < 6 || isempty(beta)
    beta = 60;
end

k = 2*pi*SF;            % grating wavenumber (rad/deg)
a = k*sind(beta);       % beat spatial frequency (rad/deg)

[XX,YY] = meshgrid(xgrid, ygrid);

% position projected onto the axis perpendicular to PO
% (n_hat(PO+90) = (-sin(PO), cos(PO)))
Xperp = -XX*sind(PO) + YY*cosd(PO);

W = RF .* exp(1i*a*Xperp);
Phi = abs(sum(W(:))) / sum(abs(RF(:)));
end
