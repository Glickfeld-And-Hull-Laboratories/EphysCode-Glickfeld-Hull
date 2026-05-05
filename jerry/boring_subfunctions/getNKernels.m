function n = getNKernels(datLength,kernelSize,overlapL)
% n is rounded to the closest smaller integer

n = floor((datLength-kernelSize)/(kernelSize-overlapL)) + 1;

end