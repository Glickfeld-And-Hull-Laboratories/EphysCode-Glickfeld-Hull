import os
def initialize():
    global TSNE_FEATURE_SIZE, pathToParentRec, ALL_RECORDINGS_FILE, TSNE_RESULT_FILE, PCA_RESULT_FILE, DATA_FILE_NAME, dateOfRecording, LOCAL, PCA_DIM_SIZE,\
        TSNE_PERPLEXITY, TSNE_XY_LIM

    LOCAL = True
    TSNE_FEATURE_SIZE = 402
    PCA_DIM_SIZE = 10
    TSNE_PERPLEXITY = 40
    TSNE_XY_LIM = 20

    if ~LOCAL:
        PCA_DIM_SIZE = 50

    if os.name == 'nt':  # Windows
        pathToParentRec = 'S:/Neuropixels/test_data/pooled/'
    else:  # Ubuntu
        #pathToParentRec = '/home/sot5@dhe.duke.edu/IsilonSevgi/Neuropixels/test_data/pooled/'
        pathToParentRec = '/mnt/IsilonPerm/Neuropixels/test_data/pooled/'

    dateOfRecording = '20230210_'
    DATA_FILE_NAME = 'unitsAndVars_' + dateOfRecording # if dateOfRecording is empty, loads all recordings

    ALL_RECORDINGS_FILE = pathToParentRec + 'allData/allRecordings.mat'  # allRecordingsSmall
    TSNE_RESULT_FILE = pathToParentRec + 'tSNEResults/'
    PCA_RESULT_FILE = pathToParentRec + 'pcaResults/'