function imecMeta = getMetaFile()    
    globals;
    imecMetaFiles = dir([pathNpyxFiltered '*.imec*ap.meta']);
    imecMetaFile = imecMetaFiles(1);
    imecMeta = readMeta(imecMetaFile.name, imecMetaFile.folder);
end