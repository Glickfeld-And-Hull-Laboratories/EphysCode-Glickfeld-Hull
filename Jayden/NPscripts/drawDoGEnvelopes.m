function drawDoGEnvelopes(params, rfSize, nSigma)
% drawDoGEnvelopes
% Draw center and surround Gaussian envelopes as ellipses.
%
% Assumed parameter order:
% params = [Ac, As, sigmaC, deltaSigma, tau, theta, x0, y0, f, phi, dx, dy]
%
% rfSize = size(rf)
% nSigma = contour level in sigma units, e.g. 1 or 2

if nargin < 3
    nSigma = 2;
end

ny = rfSize(1);
nx = rfSize(2);

% --- unpack parameters ---
sigmaC = params(3);
deltaSigma = params(4);
tau = params(5);
theta = params(6);
x0 = params(7);
y0 = params(8);
dx = params(11);
dy = params(12);

sigmaS = sigmaC + deltaSigma;

% --- define ellipse axes ---
% Assumption: sigma_x = sigma, sigma_y = sigma / tau
% If your model defines tau the other way around, swap these.
aC = nSigma * sigmaC;
bC = nSigma * sigmaC / tau;

aS = nSigma * sigmaS;
bS = nSigma * sigmaS / tau;

% --- centers ---
cxC = (nx + 1)/2 + x0;
cyC = (ny + 1)/2 + y0;
cxS = (nx + 1)/2 + x0 + dx;
cyS = (ny + 1)/2 + y0 + dy;

% If your fitting coordinates are centered around 0 instead of image pixels,
% convert them here. For example:
% cxC = nx/2 + x0;
% cyC = ny/2 + y0;
% cxS = nx/2 + x0 + dx;
% cyS = ny/2 + y0 + dy;

% --- ellipse points ---
t = linspace(0, 2*pi, 200);

[xeC, yeC] = makeRotatedEllipse(cxC, cyC, aC, bC, theta, t);
[xeS, yeS] = makeRotatedEllipse(cxS, cyS, aS, bS, theta, t);

% --- draw ---
plot(xeC, yeC, 'r-', 'LineWidth', 1.5);   % center envelope
plot(xeS, yeS, 'b-', 'LineWidth', 1.5);   % surround envelope

% mark centers
plot(cxC, cyC, 'ro', 'MarkerSize', 4, 'MarkerFaceColor', 'r');
plot(cxS, cyS, 'bo', 'MarkerSize', 4, 'MarkerFaceColor', 'b');

xlim([0.5 nx+0.5]);
ylim([0.5 ny+0.5]);

end


function [x, y] = makeRotatedEllipse(cx, cy, a, b, theta, t)
xr = a * cos(t);
yr = b * sin(t);

R = [cos(theta), -sin(theta); ...
     sin(theta),  cos(theta)];

pts = R * [xr; yr];

x = cx + pts(1, :);
y = cy + pts(2, :);
end