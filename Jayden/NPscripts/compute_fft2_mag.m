function [Fmag, fx, fy] = compute_fft2_mag(img)
% 2D FFT magnitude with frequency axes in cycles/pixel.

    [ny, nx] = size(img);

    F = fftshift(fft2(img));
    Fmag = abs(F);

    fx = ((1:nx) - ceil((nx + 1) / 2)) / nx;
    fy = ((1:ny) - ceil((ny + 1) / 2)) / ny;
end