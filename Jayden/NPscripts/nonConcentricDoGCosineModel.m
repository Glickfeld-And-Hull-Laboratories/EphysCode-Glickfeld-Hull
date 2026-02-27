function modelVec = nonConcentricDoGCosineModel(p, XY, mode)
% ============================================================
% Nonconcentric DoG × Cosine RF model (forward model only)
%
% p = [Ac, As, sigmaC, deltaSigma, tau, theta,
%      x0, y0, f, phi, dx, dy]
%
% XY = [X(:) Y(:)]
%
% mode = 'unnormalized' or 'normalized'
%
% Returns modelVec (column vector)
% ============================================================

Ac  = p(1);
As  = p(2);
sigmaC = p(3);
deltaSigma = p(4);
tau  = p(5);
theta = p(6);
x0   = p(7);
y0   = p(8);
f    = p(9);
phi  = p(10);
dx   = p(11);
dy   = p(12);

X = XY(:,1);
Y = XY(:,2);

% ---- rotate coordinates ----
Xc =  (X - x0) * cos(theta) + (Y - y0) * sin(theta);
Yc = -(X - x0) * sin(theta) + (Y - y0) * cos(theta);

% ---- center Gaussian ----
G_center = exp(-(Xc.^2 + (tau*Yc).^2) ./ (2*sigmaC^2));

% ---- surround Gaussian (shifted) ----
Xs = X - (x0 + dx);
Ys = Y - (y0 + dy);

Xs_r =  Xs * cos(theta) + Ys * sin(theta);
Ys_r = -Xs * sin(theta) + Ys * cos(theta);

sigmaS = sigmaC + deltaSigma;

G_surround = exp(-(Xs_r.^2 + (tau*Ys_r).^2) ./ (2*sigmaS^2));

% ---- DoG ----
DoG = Ac * G_center - As * G_surround;

% ---- Cosine modulation ----
carrier = cos(2*pi*f*Xc + phi);

model = DoG .* carrier;

% ---- optional normalization ----
if nargin > 2 && strcmp(mode,'normalized')
    model = model / max(abs(model));
end

modelVec = model;

end