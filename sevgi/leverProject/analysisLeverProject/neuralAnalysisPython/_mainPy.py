import numpy as np
import matplotlib
matplotlib.use('TkAgg')
import matplotlib.pyplot as plt

from sklearn.manifold import TSNE
import pandas as pd

import time

import globals
import readFromMat
import runDimReduction
import plotModule

font = {'weight' : 'bold',
        'size'   : 22}

matplotlib.rc('font', **font)
# plt.rcParams.update({'axes.titlesize': 'large'})
# plt.rcParams.update({'axes.labelsize':'medium'})

def runPCAAnalysis(holdRandomX, holdRandomHitX, holdRandomFaX, holdRandomMissX, holdFixedX, holdFixedHitX, holdFixedFaX, holdFixedMissX,
               releaseRandomX, releaseRandomHitX, releaseRandomFaX, releaseRandomMissX, releaseFixedX, releaseFixedHitX, releaseFixedFaX, releaseFixedMissX,
               targetRandomX, targetRandomHitX, targetRandomFaX, targetRandomMissX, targetFixedX, targetFixedHitX, targetFixedFaX, targetFixedMissX, neuronTypeY):
    runPCAperMatrix(holdRandomX, neuronTypeY, 'Random trials on Hold', 'holdRandom.png')
    runPCAperMatrix(holdRandomHitX, neuronTypeY, 'Random Hit trials on Hold', 'holdRandomHit.png')
    runPCAperMatrix(holdRandomFaX, neuronTypeY, 'Random Fa trials on Hold', 'holdRandomFa.png')
    runPCAperMatrix(holdRandomMissX, neuronTypeY, 'Random Miss trials on Hold', 'holdRandomMiss.png')

    runPCAperMatrix(holdFixedX, neuronTypeY, 'Fixed trials on Hold', 'holdFixed.png')
    runPCAperMatrix(holdFixedHitX, neuronTypeY, 'Fixed Hit trials on Hold', 'holdFixedHit.png')
    runPCAperMatrix(holdFixedFaX, neuronTypeY, 'Fixed Fa trials on Hold', 'holdFixedFa.png')
    runPCAperMatrix(holdFixedMissX, neuronTypeY, 'Fixed Miss trials on Hold', 'holdFixedMiss.png')

    runPCAperMatrix(releaseRandomX, neuronTypeY, 'Random trials on Release', 'releaseRandom.png')
    runPCAperMatrix(releaseRandomHitX, neuronTypeY, 'Random Hit trials on Release', 'releaseRandomHit.png')
    runPCAperMatrix(releaseRandomFaX, neuronTypeY, 'Random Fa trials on Release', 'releaseRandomFa.png')
    runPCAperMatrix(releaseRandomMissX, neuronTypeY, 'Random Miss trials on Release', 'releaseRandomMiss.png')

    runPCAperMatrix(releaseFixedX, neuronTypeY, 'Fixed trials on Release', 'releaseFixed.png')
    runPCAperMatrix(releaseFixedHitX, neuronTypeY, 'Fixed Hit trials on Release', 'releaseFixedHit.png')
    runPCAperMatrix(releaseFixedFaX, neuronTypeY, 'Fixed Fa trials on Release', 'releaseFixedFa.png')
    runPCAperMatrix(releaseFixedMissX, neuronTypeY, 'Fixed Miss trials on Release', 'releaseFixedMiss.png')

    runPCAperMatrix(targetRandomX, neuronTypeY, 'Random trials on Target', 'targetRandom.png')
    runPCAperMatrix(targetRandomHitX, neuronTypeY, 'Random Hit trials on Target', 'targetRandomHit.png')
    runPCAperMatrix(targetRandomFaX, neuronTypeY, 'Random Fa trials on Target', 'targetRandomFa.png')
    runPCAperMatrix(targetRandomMissX, neuronTypeY, 'Random Miss trials on Target', 'targetRandomMiss.png')

    runPCAperMatrix(targetFixedX, neuronTypeY, 'Fixed trials on Target', 'targetFixed.png')
    runPCAperMatrix(targetFixedHitX, neuronTypeY, 'Fixed Hit trials on Target', 'targetFixedHit.png')
    runPCAperMatrix(targetFixedFaX, neuronTypeY, 'Fixed Fa trials on Target', 'targetFixedFa.png')
    runPCAperMatrix(targetFixedMissX, neuronTypeY, 'Fixed Miss trials on Target', 'targetFixedMiss.png')

def runPCAperMatrix(X,y,title,fileName):
    time_start = time.time()
    df, expVar = runDimReduction.runPCA(X, y)
    plotModule.plotPCAResult(df, title, fileName, expVar)
    print('PCA finished for ' + fileName + ' ==> Time elapsed: {} seconds'.format(time.time() - time_start))

def runTSNEAnalysis(holdRandomX, holdRandomHitX, holdRandomFaX, holdRandomMissX, holdFixedX, holdFixedHitX, holdFixedFaX, holdFixedMissX,
               releaseRandomX, releaseRandomHitX, releaseRandomFaX, releaseRandomMissX, releaseFixedX, releaseFixedHitX, releaseFixedFaX, releaseFixedMissX,
               targetRandomX, targetRandomHitX, targetRandomFaX, targetRandomMissX, targetFixedX, targetFixedHitX, targetFixedFaX, targetFixedMissX, neuronTypeY):

    ################### ALL TRIALS ###############
    time_start = time.time()
    tsneResultHoldRandom = runDimReduction.runTSNE(holdRandomX, neuronTypeY, flagPCA=True)
    tsneResultHoldFixed = runDimReduction.runTSNE(holdFixedX, neuronTypeY, flagPCA=True)
    tsneResultReleaseRandom = runDimReduction.runTSNE(releaseRandomX, neuronTypeY, flagPCA=True)
    tsneResultReleaseFixed = runDimReduction.runTSNE(releaseFixedX, neuronTypeY, flagPCA=True)
    tsneResultTargetRandom = runDimReduction.runTSNE(targetRandomX, neuronTypeY, flagPCA=True)
    tsneResultTargetFixed = runDimReduction.runTSNE(targetFixedX, neuronTypeY, flagPCA=True)
    print('T-SNE finished for All trials ==> Time elapsed: {} seconds'.format(time.time() - time_start))

    time_start = time.time()
    # Plot the result of our TSNE with the label color coded
    # A lot of the stuff here is about making the plot look pretty and not TSNE
    plotModule.plotTSNEResult(tsneResultHoldRandom, tsneResultHoldFixed, tsneResultReleaseRandom, tsneResultReleaseFixed,
                              tsneResultTargetRandom, tsneResultTargetFixed, neuronTypeY,'allTrials.png')
    print('Plotting finished ==> Time elapsed: {0:.2f} seconds'.format(time.time() - time_start))

    ################### HIT TRIALS ###############
    time_start = time.time()
    tsneResultHoldRandomHit = runDimReduction.runTSNE(holdRandomHitX, neuronTypeY, flagPCA=True)
    tsneResultHoldFixedHit = runDimReduction.runTSNE(holdFixedHitX, neuronTypeY, flagPCA=True)
    tsneResultReleaseRandomHit = runDimReduction.runTSNE(releaseRandomHitX, neuronTypeY, flagPCA=True)
    tsneResultReleaseFixedHit = runDimReduction.runTSNE(releaseFixedHitX, neuronTypeY, flagPCA=True)
    tsneResultTargetRandomHit = runDimReduction.runTSNE(targetRandomHitX, neuronTypeY, flagPCA=True)
    tsneResultTargetFixedHit = runDimReduction.runTSNE(targetFixedHitX, neuronTypeY, flagPCA=True)
    print('T-SNE finished for Hit trials ==> Time elapsed: {} seconds'.format(time.time() - time_start))

    time_start = time.time()
    plotModule.plotTSNEResult(tsneResultHoldRandomHit, tsneResultHoldFixedHit, tsneResultReleaseRandomHit,
                              tsneResultReleaseFixedHit, tsneResultTargetRandomHit, tsneResultTargetFixedHit, neuronTypeY, 'hitTrials.png')
    print('Plotting finished for Hit trials ==> Time elapsed: {0:.2f} seconds'.format(time.time() - time_start))

    ################### FA TRIALS ###############
    time_start = time.time()
    tsneResultHoldRandomFa = runDimReduction.runTSNE(holdRandomFaX, neuronTypeY, flagPCA=True)
    tsneResultHoldFixedFa = runDimReduction.runTSNE(holdFixedFaX, neuronTypeY, flagPCA=True)
    tsneResultReleaseRandomFa = runDimReduction.runTSNE(releaseRandomFaX, neuronTypeY, flagPCA=True)
    tsneResultReleaseFixedFa = runDimReduction.runTSNE(releaseFixedFaX, neuronTypeY, flagPCA=True)
    tsneResultTargetRandomFa = runDimReduction.runTSNE(targetRandomFaX, neuronTypeY, flagPCA=True)
    tsneResultTargetFixedFa = runDimReduction.runTSNE(targetFixedFaX, neuronTypeY, flagPCA=True)
    print('T-SNE finished for Fa trials ==> Time elapsed: {0:.2f} seconds'.format(time.time() - time_start))

    time_start = time.time()
    plotModule.plotTSNEResult(tsneResultHoldRandomFa, tsneResultHoldFixedFa, tsneResultReleaseRandomFa,
                              tsneResultReleaseFixedFa, tsneResultTargetRandomFa, tsneResultTargetFixedFa, neuronTypeY, 'faTrials.png')
    print('Plotting finished for Fa trials ==> Time elapsed: {0:.2f} seconds'.format(time.time() - time_start))

    ################### Miss TRIALS ###############
    time_start = time.time()
    tsneResultHoldRandomMiss = runDimReduction.runTSNE(holdRandomMissX, neuronTypeY, flagPCA=True)
    tsneResultHoldFixedMiss = runDimReduction.runTSNE(holdFixedMissX, neuronTypeY, flagPCA=True)
    tsneResultReleaseRandomMiss = runDimReduction.runTSNE(releaseRandomMissX, neuronTypeY, flagPCA=True)
    tsneResultReleaseFixedMiss = runDimReduction.runTSNE(releaseFixedMissX, neuronTypeY, flagPCA=True)
    tsneResultTargetRandomMiss = runDimReduction.runTSNE(targetRandomMissX, neuronTypeY, flagPCA=True)
    tsneResultTargetFixedMiss = runDimReduction.runTSNE(targetFixedMissX, neuronTypeY, flagPCA=True)
    print('T-SNE finished for Miss trials ==> Time elapsed: {0:.2f} seconds'.format(time.time() - time_start))

    time_start = time.time()
    plotModule.plotTSNEResult(tsneResultHoldRandomMiss, tsneResultHoldFixedMiss, tsneResultReleaseRandomMiss,
                              tsneResultReleaseFixedMiss, tsneResultTargetRandomMiss, tsneResultTargetFixedMiss, neuronTypeY, 'missTrials.png')
    print('Plotting finished for Miss trials ==> Time elapsed: {0:.2f} seconds'.format(time.time() - time_start))

###################################################### MAIN STARTS HERE #######################################################
time_start = time.time()

if __name__ == "__main__":
    globals.initialize()

holdRandomX, holdRandomHitX, holdRandomFaX, holdRandomMissX, \
holdFixedX, holdFixedHitX, holdFixedFaX, holdFixedMissX, \
releaseRandomX, releaseRandomHitX, releaseRandomFaX, releaseRandomMissX, \
releaseFixedX, releaseFixedHitX, releaseFixedFaX, releaseFixedMissX, \
targetRandomX, targetRandomHitX, targetRandomFaX, targetRandomMissX, \
targetFixedX, targetFixedHitX, targetFixedFaX, targetFixedMissX, \
neuronTypeY = readFromMat.importRecordingsFromMat()

print('Data loading from Matlab ==> Time elapsed: {0:.2f} seconds'.format(time.time()-time_start))

time_start = time.time()

randomIds = np.random.choice(targetFixedX.shape[0], targetFixedX.shape[0], replace=False) # randomly mix the data set

holdRandomX = holdRandomX[randomIds,:]
holdRandomHitX = holdRandomHitX[randomIds,:]
holdRandomFaX = holdRandomFaX[randomIds,:]
holdRandomMissX = holdRandomMissX[randomIds,:]

holdFixedX = holdFixedX[randomIds,:]
holdFixedHitX = holdFixedHitX[randomIds,:]
holdFixedFaX = holdFixedFaX[randomIds,:]
holdFixedMissX = holdFixedMissX[randomIds,:]

releaseRandomX = releaseRandomX[randomIds,:]
releaseRandomHitX = releaseRandomHitX[randomIds,:]
releaseRandomFaX = releaseRandomFaX[randomIds,:]
releaseRandomMissX = releaseRandomMissX[randomIds,:]

releaseFixedX = releaseFixedX[randomIds,:]
releaseFixedHitX = releaseFixedHitX[randomIds,:]
releaseFixedFaX = releaseFixedFaX[randomIds,:]
releaseFixedMissX = releaseFixedMissX[randomIds,:]

targetRandomX = targetRandomX[randomIds,:]
targetRandomHitX = targetRandomHitX[randomIds,:]
targetRandomFaX = targetRandomFaX[randomIds,:]
targetRandomMissX = targetRandomMissX[randomIds,:]

targetFixedX = targetFixedX[randomIds,:]
targetFixedHitX = targetFixedHitX[randomIds,:]
targetFixedFaX = targetFixedFaX[randomIds,:]
targetFixedMissX = targetFixedMissX[randomIds,:]

neuronTypeY = neuronTypeY[randomIds]
print('Data randomization ==> Time elapsed: {0:.2f} seconds'.format(time.time()-time_start))

####################### PCA starts here ######################
runPCAAnalysis(holdRandomX, holdRandomHitX, holdRandomFaX, holdRandomMissX, holdFixedX, holdFixedHitX, holdFixedFaX, holdFixedMissX,
               releaseRandomX, releaseRandomHitX, releaseRandomFaX, releaseRandomMissX, releaseFixedX, releaseFixedHitX, releaseFixedFaX, releaseFixedMissX,
               targetRandomX, targetRandomHitX, targetRandomFaX, targetRandomMissX, targetFixedX, targetFixedHitX, targetFixedFaX, targetFixedMissX, neuronTypeY)

####################### t-SNE starts here ######################
runTSNEAnalysis(holdRandomX, holdRandomHitX, holdRandomFaX, holdRandomMissX, holdFixedX, holdFixedHitX, holdFixedFaX, holdFixedMissX,
               releaseRandomX, releaseRandomHitX, releaseRandomFaX, releaseRandomMissX, releaseFixedX, releaseFixedHitX, releaseFixedFaX, releaseFixedMissX,
               targetRandomX, targetRandomHitX, targetRandomFaX, targetRandomMissX, targetFixedX, targetFixedHitX, targetFixedFaX, targetFixedMissX, neuronTypeY)


