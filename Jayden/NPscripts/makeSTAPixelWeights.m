function Wpix = makeSTAPixelWeights(zCrop, method, alpha, floorWeight)
% makeSTAPixelWeights
%
% Build pixel weights from cropped z-score STA.
%
% Inputs
%   zCrop        cropped z-score STA
%   method       'soft', 'soft_threshold', or 'binary'
%   alpha        exponent for soft weights
%   floorWeight  minimum weight
%
% Output
%   Wpix         weight map in [floorWeight, 1]

    if nargin < 2 || isempty(method)
        method = 'soft';
    end
    if nargin < 3 || isempty(alpha)
        alpha = 2;
    end
    if nargin < 4 || isempty(floorWeight)
        floorWeight = 0.1;
    end

    A = abs(zCrop);

    switch method
        case 'soft'
            A = A / (max(A(:)) + eps);
            Wpix = floorWeight + (1 - floorWeight) * (A .^ alpha);

        case 'soft_threshold'
            A = A / (max(A(:)) + eps);
            A = max(A - 0.2, 0);
            if max(A(:)) > 0
                A = A / max(A(:));
            end
            Wpix = floorWeight + (1 - floorWeight) * (A .^ alpha);

        case 'binary'
            A = A / (max(A(:)) + eps);
            Wpix = double(A > 0.2);
            Wpix = floorWeight + (1 - floorWeight) * Wpix;

        otherwise
            error('Unknown method: %s', method)
    end
end