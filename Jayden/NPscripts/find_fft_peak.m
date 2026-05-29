function peak = find_fft_peak(Fmag, fx, fy)
% Find dominant non-DC FFT peak.

    [ny, nx] = size(Fmag);
    [FX, FY] = meshgrid(fx, fy);

    % Remove DC neighborhood
    cx = ceil((nx + 1) / 2);
    cy = ceil((ny + 1) / 2);

    Fwork = Fmag;
    dc_radius = 1;  % zero out a small neighborhood around DC

    for iy = 1:ny
        for ix = 1:nx
            if abs(ix - cx) <= dc_radius && abs(iy - cy) <= dc_radius
                Fwork(iy, ix) = 0;
            end
        end
    end

    [~, idx] = max(Fwork(:));
    [iy, ix] = ind2sub(size(Fwork), idx);

    peak.fx = FX(iy, ix);
    peak.fy = FY(iy, ix);
    peak.fr = sqrt(peak.fx^2 + peak.fy^2);
    peak.value = Fmag(iy, ix);
    peak.ix = ix;
    peak.iy = iy;
end