currentdir = '\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\JaydenM\repositories';
addpath(genpath([currentdir '\ImagingCode-Glickfeld-Hull']));
addpath(genpath([currentdir '\BehaviorCode-Glickfeld-Hull']));
addpath(genpath([currentdir '\Scanbox']));
svnroot =[currentdir, '\ImagingCode-Glickfeld-Hull'];
ijroot = 'C:\Program Files\ImageJ'; 
			coreInitJavaPath(svnroot,ijroot);
			coreInitMatlabPath(svnroot,ijroot);
userRoot = 'C:\Users\ym257\Documents\MATLAB';

if isfolder(userRoot)
    addpath(genpath(userRoot));
else
    warning('User MATLAB folder not found: %s', userRoot);
end
