function [meany, stErr] = meany(X)
meany = mean(X);
stErr = std(X)/sqrt(length(X));
disp(['length of var is ' num2str(length(X))])
disp([num2str(meany) ' +- ' num2str(stErr)])
end
