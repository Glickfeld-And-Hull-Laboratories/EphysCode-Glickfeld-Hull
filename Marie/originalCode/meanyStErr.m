function [meany, stErr] = meanyStErr(X)
meany = mean(X);
stErr = std(X)/sqrt(length(X));
disp([num2str(meany) ' +- ' num2str(stErr)])
end
