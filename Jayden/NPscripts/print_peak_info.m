function print_peak_info(peak)
    fprintf('  fx = %.6f cycles/pixel\n', peak.fx);
    fprintf('  fy = %.6f cycles/pixel\n', peak.fy);
    fprintf('  radial freq = %.6f cycles/pixel\n', peak.fr);
    fprintf('  FFT peak mag = %.6f\n', peak.value);
    fprintf('  period = %.6f pixels/cycle\n', 1 / max(peak.fr, eps));
end