function [RF, xgrid, ygrid] = makeGaborRF(PO, carrierSF, sigma_par, sigma_perp, phase, xgrid, ygrid)
% makeGaborRF  Generate a synthetic Gabor receptive field for testing
% estimatePhaseCoherence.m.
%
%   RF(x,y) = exp(-[x_par^2/(2*sigma_par^2) + x_perp^2/(2*sigma_perp^2)])
%             .* cos(2*pi*carrierSF*x_par + phase)
%
% where x_par, x_perp are (x,y) projected onto the axes parallel/
% perpendicular to PO -- using the SAME projection convention as
% estimatePhaseCoherence.m, so PO here is exactly the PO you'd pass to
% that function.
%
% sigma_perp is the parameter that matters most for testing Phi: it's
% the RF's spread along the same perpendicular-to-PO axis that Phi
% probes. Small sigma_perp (relative to the beat wavelength
% 1/(SF*sind(beta)) used in estimatePhaseCoherence) should give high
% Phi; large sigma_perp should give low Phi.
%
% INPUTS
%   PO         : preferred orientation of the Gabor's carrier (deg)
%   carrierSF  : spatial frequency of the Gabor's own sinusoidal carrier
%                (cycles/deg) -- the RF's intrinsic substructure spacing;
%                independent of whatever plaid SF is later used to probe
%                pattern/component selectivity
%   sigma_par  : envelope SD along the axis PARALLEL to PO (deg)
%   sigma_perp : envelope SD along the axis PERPENDICULAR to PO (deg)
%   phase      : (optional) carrier phase offset (rad); default 0
%   xgrid,ygrid: (optional) coordinate vectors (deg); if omitted, a grid
%                is auto-generated wide enough to contain the envelope
%                and fine enough to resolve the carrier
%
% OUTPUTS
%   RF          : Ny x Nx Gabor receptive field map
%   xgrid,ygrid : the coordinate vectors actually used (deg) -- pass
%                 these straight into estimatePhaseCoherence.m along with
%                 the SAME PO

if nargin < 5 || isempty(phase), phase = 0; end
if nargin < 6 || isempty(xgrid)
    extent = 4*max([sigma_par, sigma_perp, 1/carrierSF]);
    step   = min(1/(8*carrierSF), max(sigma_par,sigma_perp)/20);
    xgrid  = -extent:step:extent;
end
if nargin < 7 || isempty(ygrid)
    ygrid = xgrid;
end

[XX,YY] = meshgrid(xgrid, ygrid);

% project onto axes parallel / perpendicular to PO (same convention as
% estimatePhaseCoherence.m: n_hat(PO) = (cos PO, sin PO), n_hat(PO+90) = (-sin PO, cos PO))
Xpar  =  XX*cosd(PO) + YY*sind(PO);
Xperp = -XX*sind(PO) + YY*cosd(PO);

envelope = exp(-(Xpar.^2/(2*sigma_par^2) + Xperp.^2/(2*sigma_perp^2)));
carrier  = cos(2*pi*carrierSF*Xpar + phase);

RF = envelope .* carrier;
end
