import numpy as np
import matplotlib
from scipy.stats import wilcoxon, mannwhitneyu

matplotlib.use('TkAgg')
import matplotlib.pyplot as plt

from sklearn.manifold import TSNE
import pandas as pd

import time

import globals
import readFromMat
import runDimReduction
import runModels
import plotModule

#import lifelines.fitters.coxph_fitter
## from lifelines.fitters.coxph_fitter import CoxPHFitter
#from lifelines.datasets import load_rossi

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

def runLinearModel(spikeRatesofTrialsVSUnits_HoldRandomHit, spikeRatesofTrialsVSUnits_HoldFixedHit,
               spikeRatesofTrialsVSUnits_ReleaseRandomHit, spikeRatesofTrialsVSUnits_ReleaseFixedHit,
               spikeRatesofTrialsVSUnits_TargetRandomHit, spikeRatesofTrialsVSUnits_TargetFixedHit,
               spikeRatesofTrialsVSUnits_HoldRandomFa, spikeRatesofTrialsVSUnits_HoldFixedFa,
               spikeRatesofTrialsVSUnits_ReleaseRandomFa, spikeRatesofTrialsVSUnits_ReleaseFixedFa,
               spikeRatesofTrialsVSUnits_TargetRandomFa, spikeRatesofTrialsVSUnits_TargetFixedFa,
               spikeRatesofTrialsVSUnits_HoldRandomMiss, spikeRatesofTrialsVSUnits_HoldFixedMiss,
               spikeRatesofTrialsVSUnits_ReleaseRandomMiss, spikeRatesofTrialsVSUnits_ReleaseFixedMiss,
               spikeRatesofTrialsVSUnits_TargetRandomMiss, spikeRatesofTrialsVSUnits_TargetFixedMiss,
               arrReactTimesRandomAll, arrReactTimesRandomHit, arrReactTimesRandomFa, arrReactTimesRandomMiss,
               arrReactTimesFixedAll, arrReactTimesFixedHit, arrReactTimesFixedFa, arrReactTimesFixedMiss, neuronTypeY):

    # runModels.runLinearRegression(spikeRatesofTrialsVSUnits_HoldRandomHit, arrReactTimesRandomHit, neuronTypeY, 'Hold Random Hit')
    # runModels.runLinearRegression(spikeRatesofTrialsVSUnits_HoldFixedHit, arrReactTimesFixedHit, neuronTypeY, 'Hold Fixed Hit')
    # runModels.runLinearRegression(spikeRatesofTrialsVSUnits_ReleaseRandomHit, arrReactTimesRandomHit, neuronTypeY, 'Release Random Hit')
    # runModels.runLinearRegression(spikeRatesofTrialsVSUnits_ReleaseFixedHit, arrReactTimesFixedHit, neuronTypeY, 'Release Fixed Hit')
    # runModels.runLinearRegression(spikeRatesofTrialsVSUnits_TargetRandomHit, arrReactTimesRandomHit, neuronTypeY, 'Target Random Hit')
    # runModels.runLinearRegression(spikeRatesofTrialsVSUnits_TargetFixedHit, arrReactTimesFixedHit, neuronTypeY, 'Target Fixed Hit')
    #
    # runModels.runLinearRegression(spikeRatesofTrialsVSUnits_HoldRandomFa, arrReactTimesRandomFa, neuronTypeY, 'Hold Random Fa')
    # runModels.runLinearRegression(spikeRatesofTrialsVSUnits_HoldFixedFa, arrReactTimesFixedFa, neuronTypeY, 'Hold Fixed Fa')
    # runModels.runLinearRegression(spikeRatesofTrialsVSUnits_ReleaseRandomFa, arrReactTimesRandomFa, neuronTypeY, 'Release Random Fa')
    # runModels.runLinearRegression(spikeRatesofTrialsVSUnits_ReleaseFixedFa, arrReactTimesFixedFa, neuronTypeY, 'Release Fixed Fa')
    #
    # runModels.runLinearRegression(spikeRatesofTrialsVSUnits_HoldRandomMiss, arrReactTimesRandomMiss, neuronTypeY, 'Hold Random Miss')
    # runModels.runLinearRegression(spikeRatesofTrialsVSUnits_HoldFixedMiss, arrReactTimesFixedMiss, neuronTypeY, 'Hold Fixed Miss')
    # runModels.runLinearRegression(spikeRatesofTrialsVSUnits_ReleaseRandomMiss, arrReactTimesRandomMiss, neuronTypeY, 'Release Random Miss')
    # runModels.runLinearRegression(spikeRatesofTrialsVSUnits_ReleaseFixedMiss, arrReactTimesFixedMiss, neuronTypeY, 'Release Fixed Miss')
    # runModels.runLinearRegression(spikeRatesofTrialsVSUnits_TargetRandomMiss, arrReactTimesRandomMiss, neuronTypeY, 'Target Random Miss')
    # runModels.runLinearRegression(spikeRatesofTrialsVSUnits_TargetFixedMiss, arrReactTimesFixedMiss, neuronTypeY, 'Target Fixed Miss')

    # Only Random trials
    # spikeRatesofTrialsVSUnits_HoldRandom = np.concatenate((spikeRatesofTrialsVSUnits_HoldRandomHit, spikeRatesofTrialsVSUnits_HoldRandomFa, spikeRatesofTrialsVSUnits_HoldRandomMiss),axis=0)
    # spikeRatesofTrialsVSUnits_ReleaseRandom = np.concatenate((spikeRatesofTrialsVSUnits_ReleaseRandomHit, spikeRatesofTrialsVSUnits_ReleaseRandomFa, spikeRatesofTrialsVSUnits_ReleaseRandomMiss), axis=0)
    # spikeRatesofTrialsVSUnits_TargetRandom = np.concatenate((spikeRatesofTrialsVSUnits_TargetRandomHit, spikeRatesofTrialsVSUnits_TargetRandomMiss), axis=0)
    # arrReactTimesRandomTarget = np.concatenate((arrReactTimesRandomHit, arrReactTimesRandomMiss),axis=0)
    #
    # runModels.runLinearRegression(spikeRatesofTrialsVSUnits_HoldRandom, arrReactTimesRandomAll, neuronTypeY, 'Hold Random')
    # runModels.runLinearRegression(spikeRatesofTrialsVSUnits_ReleaseRandom, arrReactTimesRandomAll, neuronTypeY, 'Release Random')
    # runModels.runLinearRegression(spikeRatesofTrialsVSUnits_TargetRandom, arrReactTimesRandomTarget, neuronTypeY, 'Target Random')

    # Only Fixed trials
    spikeRatesofTrialsVSUnits_HoldFixed = np.concatenate((spikeRatesofTrialsVSUnits_HoldFixedHit, spikeRatesofTrialsVSUnits_HoldFixedFa, spikeRatesofTrialsVSUnits_HoldFixedMiss), axis=0)
    spikeRatesofTrialsVSUnits_ReleaseFixed = np.concatenate((spikeRatesofTrialsVSUnits_ReleaseFixedHit, spikeRatesofTrialsVSUnits_ReleaseFixedFa, spikeRatesofTrialsVSUnits_ReleaseFixedMiss), axis=0)
    spikeRatesofTrialsVSUnits_TargetFixed = np.concatenate((spikeRatesofTrialsVSUnits_TargetFixedHit, spikeRatesofTrialsVSUnits_TargetFixedMiss), axis=0)
    arrReactTimesFixedTarget = np.concatenate((arrReactTimesFixedHit, arrReactTimesFixedMiss), axis=0)

    # runModels.gridSearchNumOfFeatures(spikeRatesofTrialsVSUnits_HoldFixed, arrReactTimesFixedAll, neuronTypeY, 'Hold Fixed')
    # runModels.gridSearchNumOfFeatures(spikeRatesofTrialsVSUnits_ReleaseFixed, arrReactTimesFixedAll, neuronTypeY, 'Release Fixed')
    # runModels.gridSearchNumOfFeatures(spikeRatesofTrialsVSUnits_TargetFixed, arrReactTimesFixedTarget, neuronTypeY, 'Target Fixed')

    runModels.runLinearRegression(spikeRatesofTrialsVSUnits_HoldFixed, arrReactTimesFixedAll, neuronTypeY, 'Hold Fixed')
    runModels.runLinearRegression(spikeRatesofTrialsVSUnits_ReleaseFixed, arrReactTimesFixedAll, neuronTypeY, 'Release Fixed')
    runModels.runLinearRegression(spikeRatesofTrialsVSUnits_TargetFixed, arrReactTimesFixedTarget, neuronTypeY, 'Target Fixed')

def runMultinomialLogisticRegression(allTrials, arrHitTrials, arrFaTrials, arrMissTrials, fixedHoldStartsAtTrial,
                                 spikeRatesofTrialsVSUnits_HoldRandomAll, spikeRatesofTrialsVSUnits_HoldFixedAll,
                                 spikeRatesofTrialsVSUnits_ReleaseRandomAll, spikeRatesofTrialsVSUnits_ReleaseFixedAll,
                                 spikeRatesofTrialsVSUnits_TargetRandomAll, spikeRatesofTrialsVSUnits_TargetFixedAll,
                                 responseTypeHoldFixedAll, responseTypeReleaseFixedAll, responseTypeTargetFixedAll,
                                 expertLabels):

    flagMultiNomial = 1
    y = np.zeros((len(allTrials)))
    y[arrHitTrials] = globals.HIT_OUTCOME
    y[arrFaTrials] = globals.FA_OUTCOME
    y[arrMissTrials] = globals.MISS_OUTCOME
    yRandom = y[0:fixedHoldStartsAtTrial]
    yFixed = y[fixedHoldStartsAtTrial:]
    # probMeanHitKnownHR, probMeanFaKnownHR, probMeanMissKnownHR = runModels.runLogisticRegressionWNeuronTypes(spikeRatesofTrialsVSUnits_HoldRandomAll, yRandom, 1, expertLabels, 'HoldRandom')
    # probMeanHitKnownHF, probMeanFaKnownHF, probMeanMissKnownHF = runModels.runLogisticRegressionWNeuronTypes(spikeRatesofTrialsVSUnits_HoldFixedAll, yFixed, 1, expertLabels, 'HoldFixed')

    #runModels.runLogisticRegressionWNeuronTypes(spikeRatesofTrialsVSUnits_ReleaseRandomAll, yRandom, 1, expertLabels, 'ReleaseRandomBefore')
    #runModels.runLogisticRegressionWNeuronTypes(spikeRatesofTrialsVSUnits_ReleaseFixedAll, yFixed, 1, expertLabels, 'ReleaseFixedBefore')
    runModels.runLogisticRegressionAndPlot(spikeRatesofTrialsVSUnits_ReleaseRandomAll, yRandom, spikeRatesofTrialsVSUnits_ReleaseFixedAll, yFixed, expertLabels)
                                 #X, y, neuronType, sTitle, 'Allcells')

    # probMeanHitKnownTR, probMeanFaKnownTR, probMeanMissKnownTR = runModels.runLogisticRegressionWNeuronTypes(spikeRatesofTrialsVSUnits_TargetRandomAll, yRandom, 1, expertLabels, 'TargetRandom')
    # probMeanHitKnownTF, probMeanFaKnownTF, probMeanMissKnownTF = runModels.runLogisticRegressionWNeuronTypes(spikeRatesofTrialsVSUnits_TargetFixedAll, yFixed, 1, expertLabels, 'TargetFixed')

    # inds = np.where(expertLabels != globals.NEURON_TYPE_UNKNOWN)[0]
    # if len(inds) > 0:
    #     neuronTypeSubset = expertLabels[inds]
    #     for indNeuronType in range(0, len(globals.NEURON_TYPES)):
    #         inds = np.where(neuronTypeSubset == globals.NEURON_TYPES[indNeuronType])[0]
    #         if len(inds) > 5: # Wilcoxon test need n>5
    #             # probMeanHitSpecHR = probMeanHitKnownHR[inds]
    #             # probMeanFaSpecHR = probMeanFaKnownHR[inds]
    #             # probMeanMissSpecHR = probMeanMissKnownHR[inds]
    #             #
    #             # probMeanHitSpecHF = probMeanHitKnownHF[inds]
    #             # probMeanFaSpecHF = probMeanFaKnownHF[inds]
    #             # probMeanMissSpecHF = probMeanMissKnownHF[inds]
    #             #
    #             # d = probMeanHitSpecHF - probMeanHitSpecHR
    #             # res = wilcoxon(d)
    #             # if res.pvalue <= .05:
    #             #     print('Hit Hold Random vs Fixed ', globals.NEURON_TYPES[indNeuronType], ' cells: %.2f (p=%.2f)' % (res.statistic, res.pvalue))
    #             #
    #             # d = probMeanFaSpecHF - probMeanFaSpecHR
    #             # res = wilcoxon(d)
    #             # if res.pvalue <= .05:
    #             #     print('Fa Hold Random vs Fixed', globals.NEURON_TYPES[indNeuronType], ' cells: %.2f (p=%.2f)' % (res.statistic, res.pvalue))
    #             #
    #             # d = probMeanMissSpecHF - probMeanMissSpecHR
    #             # res = wilcoxon(d)
    #             # if res.pvalue <= .05:
    #             #     print('Miss Hold Random vs Fixed ', globals.NEURON_TYPES[indNeuronType], ' cells: %.2f (p=%.2f)' % (res.statistic, res.pvalue))
    #
    #             probMeanHitSpecRR = probMeanHitKnownRR[inds]
    #             probMeanFaSpecRR = probMeanFaKnownRR[inds]
    #             probMeanMissSpecRR = probMeanMissKnownRR[inds]
    #
    #             probMeanHitSpecRF = probMeanHitKnownRF[inds]
    #             probMeanFaSpecRF = probMeanFaKnownRF[inds]
    #             probMeanMissSpecRF = probMeanMissKnownRF[inds]
    #
    #             #d = probMeanHitSpecRF - probMeanHitSpecRR
    #             #res = wilcoxon(d) # This is non-parametric version of paired t-test
    #             res = mannwhitneyu(probMeanHitSpecRF, probMeanHitSpecRR) # This is non-parametric version of unpaired t-test
    #             if res.pvalue <= .05:
    #                 print('Hit Release Random vs Fixed ', globals.NEURON_TYPES[indNeuronType], ' cells: %.2f (p=%.2f)' % (res.statistic, res.pvalue))
    #
    #             # d = probMeanFaSpecRF - probMeanFaSpecRR
    #             # res = wilcoxon(d)
    #             res = mannwhitneyu(probMeanFaSpecRF, probMeanFaSpecRR)
    #             if res.pvalue <= .05:
    #                 print('Fa Release Random vs Fixed ', globals.NEURON_TYPES[indNeuronType], ' cells: %.2f (p=%.2f)' % (res.statistic, res.pvalue))
    #
    #             # d = probMeanMissSpecRF - probMeanMissSpecRR
    #             # res = wilcoxon(d)
    #             res = mannwhitneyu(probMeanMissSpecRF, probMeanMissSpecRR)
    #             if res.pvalue <= .05:
    #                 print('Miss Release Random vs Fixed ', globals.NEURON_TYPES[indNeuronType], ' cells: %.2f (p=%.2f)' % (res.statistic, res.pvalue))
    #
    #             # probMeanHitSpecTR = probMeanHitKnownTR[inds]
    #             # probMeanFaSpecTR = probMeanFaKnownTR[inds]
    #             # probMeanMissSpecTR = probMeanMissKnownTR[inds]
    #             #
    #             # probMeanHitSpecTF = probMeanHitKnownTF[inds]
    #             # probMeanFaSpecTF = probMeanFaKnownTF[inds]
    #             # probMeanMissSpecTF = probMeanMissKnownTF[inds]
    #             #
    #             # d = probMeanHitSpecTF - probMeanHitSpecTR
    #             # res = wilcoxon(d)
    #             # if res.pvalue<=.05:
    #             #     print('Hit Target Random vs Fixed ', globals.NEURON_TYPES[indNeuronType], ' cells: %.2f (p=%.2f)' % (res.statistic, res.pvalue))
    #             #
    #             # d = probMeanFaSpecTF - probMeanFaSpecTR
    #             # res = wilcoxon(d)
    #             # if res.pvalue <= .05:
    #             #     print('Fa Target Random vs Fixed ', globals.NEURON_TYPES[indNeuronType], ' cells: %.2f (p=%.2f)' % (res.statistic, res.pvalue))
    #             #
    #             # d = probMeanMissSpecTF - probMeanMissSpecTR
    #             # res = wilcoxon(d)
    #             # if res.pvalue <= .05:
    #             #     print('Miss Target Random vs Fixed ', globals.NEURON_TYPES[indNeuronType], ' cells: %.2f (p=%.2f)' % (res.statistic, res.pvalue))

    # indsInc = np.where(responseTypeHoldFixedAll == 1)[0]  # Increasing activity
    # indsDec = np.where(responseTypeHoldFixedAll == -1)[0]  # Decreasing activity
    # indsNoCh = np.where(responseTypeHoldFixedAll == 0)[0]  # No Change in activity
    # runModels.runLogisticRegressionWNeuronTypes(spikeRatesofTrialsVSUnits_HoldFixedAll[:, indsInc], yFixed, flagMultiNomial, '', 'Hold Fixed only Increasing Activity')
    # runModels.runLogisticRegressionWNeuronTypes(spikeRatesofTrialsVSUnits_HoldFixedAll[:, indsDec], yFixed, flagMultiNomial, '', 'Hold Fixed only Decreasing Activity')
    # runModels.runLogisticRegressionWNeuronTypes(spikeRatesofTrialsVSUnits_HoldFixedAll[:, indsNoCh], yFixed, flagMultiNomial, '', 'Hold Fixed only No Change Activity')
    #
    # indsInc = np.where(responseTypeReleaseFixedAll == 1)[0]  # Increasing activity
    # indsDec = np.where(responseTypeReleaseFixedAll == -1)[0]  # Decreasing activity
    # indsNoCh = np.where(responseTypeReleaseFixedAll == 0)[0]  # No Change in activity
    # runModels.runLogisticRegressionWNeuronTypes(spikeRatesofTrialsVSUnits_ReleaseFixedAll[:, indsInc], yFixed, flagMultiNomial, '', 'Release Fixed only Increasing Activity')
    # runModels.runLogisticRegressionWNeuronTypes(spikeRatesofTrialsVSUnits_ReleaseFixedAll[:, indsDec], yFixed, flagMultiNomial, '', 'Release Fixed only Decreasing Activity')
    # runModels.runLogisticRegressionWNeuronTypes(spikeRatesofTrialsVSUnits_ReleaseFixedAll[:, indsNoCh], yFixed, flagMultiNomial, '', 'Release Fixed only No Change Activity')
    #
    # indsInc = np.where(responseTypeTargetFixedAll == 1)[0]  # Increasing activity
    # indsDec = np.where(responseTypeTargetFixedAll == -1)[0]  # Decreasing activity
    # indsNoCh = np.where(responseTypeTargetFixedAll == 0)[0]  # No Change in activity
    # runModels.runLogisticRegressionWNeuronTypes(spikeRatesofTrialsVSUnits_TargetFixedAll[:, indsInc], yFixed, flagMultiNomial, '', 'Target Fixed only Increasing Activity')
    # runModels.runLogisticRegressionWNeuronTypes(spikeRatesofTrialsVSUnits_TargetFixedAll[:, indsDec], yFixed, flagMultiNomial, '', 'Target Fixed only Decreasing Activity')
    # runModels.runLogisticRegressionWNeuronTypes(spikeRatesofTrialsVSUnits_TargetFixedAll[:, indsNoCh], yFixed, flagMultiNomial, '', 'Target Fixed only No Change Activity')

def runLasso(responseTypeHoldFixedAll, responseTypeHoldFixedHit, responseTypeHoldFixedFa, responseTypeHoldFixedMiss,
            responseTypeReleaseFixedAll, responseTypeReleaseFixedHit, responseTypeReleaseFixedFa, responseTypeReleaseFixedMiss,
            responseTypeTargetFixedAll, responseTypeTargetFixedHit, responseTypeTargetFixedMiss,
            spikeRatesofTrialsVSUnits_HoldRandomHit, spikeRatesofTrialsVSUnits_HoldFixedHit,
            spikeRatesofTrialsVSUnits_ReleaseRandomHit, spikeRatesofTrialsVSUnits_ReleaseFixedHit,
            spikeRatesofTrialsVSUnits_TargetRandomHit, spikeRatesofTrialsVSUnits_TargetFixedHit,
            spikeRatesofTrialsVSUnits_HoldRandomFa, spikeRatesofTrialsVSUnits_HoldFixedFa,
            spikeRatesofTrialsVSUnits_ReleaseRandomFa, spikeRatesofTrialsVSUnits_ReleaseFixedFa,
            spikeRatesofTrialsVSUnits_TargetRandomFa, spikeRatesofTrialsVSUnits_TargetFixedFa,
            spikeRatesofTrialsVSUnits_HoldRandomMiss, spikeRatesofTrialsVSUnits_HoldFixedMiss,
            spikeRatesofTrialsVSUnits_ReleaseRandomMiss, spikeRatesofTrialsVSUnits_ReleaseFixedMiss,
            spikeRatesofTrialsVSUnits_TargetRandomMiss, spikeRatesofTrialsVSUnits_TargetFixedMiss,
            arrReactTimesRandomAll, arrReactTimesRandomHit, arrReactTimesRandomFa, arrReactTimesRandomMiss,
            arrReactTimesFixedAll, arrReactTimesFixedHit, arrReactTimesFixedFa, arrReactTimesFixedMiss, neuronTypeY):
    # Only Random trials
    spikeRatesofTrialsVSUnits_HoldRandom = np.concatenate((spikeRatesofTrialsVSUnits_HoldRandomHit, spikeRatesofTrialsVSUnits_HoldRandomFa, spikeRatesofTrialsVSUnits_HoldRandomMiss), axis=0)
    spikeRatesofTrialsVSUnits_ReleaseRandom = np.concatenate((spikeRatesofTrialsVSUnits_ReleaseRandomHit, spikeRatesofTrialsVSUnits_ReleaseRandomFa, spikeRatesofTrialsVSUnits_ReleaseRandomMiss), axis=0)
    spikeRatesofTrialsVSUnits_TargetRandom = np.concatenate((spikeRatesofTrialsVSUnits_TargetRandomHit, spikeRatesofTrialsVSUnits_TargetRandomMiss), axis=0)
    arrReactTimesRandomTarget = np.concatenate((arrReactTimesRandomHit, arrReactTimesRandomMiss), axis=0)

    # runModels.runLasso(spikeRatesofTrialsVSUnits_HoldRandom, arrReactTimesRandomAll, neuronTypeY, 'Hold Random')
    # runModels.runLasso(spikeRatesofTrialsVSUnits_ReleaseRandom, arrReactTimesRandomAll, neuronTypeY, 'Release Random')
    # runModels.runLasso(spikeRatesofTrialsVSUnits_TargetRandom, arrReactTimesRandomTarget, neuronTypeY, 'Target Random')

    # Only Fixed trials
    spikeRatesofTrialsVSUnits_HoldFixed = np.concatenate((spikeRatesofTrialsVSUnits_HoldFixedHit, spikeRatesofTrialsVSUnits_HoldFixedFa, spikeRatesofTrialsVSUnits_HoldFixedMiss), axis=0)
    spikeRatesofTrialsVSUnits_ReleaseFixed = np.concatenate((spikeRatesofTrialsVSUnits_ReleaseFixedHit, spikeRatesofTrialsVSUnits_ReleaseFixedFa, spikeRatesofTrialsVSUnits_ReleaseFixedMiss), axis=0)
    spikeRatesofTrialsVSUnits_TargetFixed = np.concatenate((spikeRatesofTrialsVSUnits_TargetFixedHit, spikeRatesofTrialsVSUnits_TargetFixedMiss), axis=0)
    arrReactTimesFixedTarget = np.concatenate((arrReactTimesFixedHit, arrReactTimesFixedMiss), axis=0)

    # runModels.runLasso(spikeRatesofTrialsVSUnits_HoldFixed, arrReactTimesFixedAll, neuronTypeY, 'Hold Fixed')
    # runModels.runLasso(spikeRatesofTrialsVSUnits_ReleaseFixed, arrReactTimesFixedAll, neuronTypeY, 'Release Fixed')
    runModels.runLasso(spikeRatesofTrialsVSUnits_TargetFixedHit, arrReactTimesFixedHit, neuronTypeY, 'Target Fixed Hit', 'Lasso_TargetFixedHit')
    runModels.runLasso(spikeRatesofTrialsVSUnits_TargetFixed, arrReactTimesFixedTarget, neuronTypeY, 'Target Fixed', 'Lasso_TargetFixed')

    indsInc = np.where(responseTypeTargetFixedHit == 1)[0] # Increasing activity
    indsDec = np.where(responseTypeTargetFixedHit == -1)[0]  # Decreasing activity
    indsNoCh = np.where(responseTypeTargetFixedHit == 0)[0]  # No Change in activity
    runModels.runLasso(spikeRatesofTrialsVSUnits_TargetFixedHit[:, indsInc], arrReactTimesFixedHit, neuronTypeY[indsInc], 'Target Fixed Hit only Increasing', 'Lasso_TargetFixedHitInc')
    runModels.runLasso(spikeRatesofTrialsVSUnits_TargetFixedHit[:, indsDec], arrReactTimesFixedHit, neuronTypeY[indsDec], 'Target Fixed Hit only Decreasing', 'Lasso_TargetFixedHitDec')
    runModels.runLasso(spikeRatesofTrialsVSUnits_TargetFixedHit[:, indsNoCh], arrReactTimesFixedHit, neuronTypeY[indsNoCh], 'Target Fixed Hit only NoChange', 'Lasso_TargetFixedHitNoCh')

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

# https://lifelines.readthedocs.io/en/latest/Survival%20Regression.html
def runCoxPropHazard(allTrials, arrHitTrials, arrFaTrials, arrMissTrials, fixedHoldStartsAtTrial,
                                 spikeRatesofTrialsVSUnits_HoldRandomAll, spikeRatesofTrialsVSUnits_HoldFixedAll,
                                 spikeRatesofTrialsVSUnits_ReleaseRandomAll, spikeRatesofTrialsVSUnits_ReleaseFixedAll,
                                 spikeRatesofTrialsVSUnits_TargetRandomAll, spikeRatesofTrialsVSUnits_TargetFixedAll,
                                 responseTypeHoldFixedAll, responseTypeReleaseFixedAll, responseTypeTargetFixedAll,
                                 expertLabels):
    rossi = load_rossi()
    cph = CoxPHFitter()
    cph.fit(rossi, duration_col='week', event_col='arrest')
    cph.print_summary()
    axes = cph.plot_partial_effects_on_outcome(covariates='prio', values=[0, 2, 4, 6, 8, 10], cmap='coolwarm')

    rossi_train = load_rossi().loc[:400]
    rossi_test = load_rossi().loc[400:]
    cph = CoxPHFitter().fit(rossi_train, 'week', 'arrest')

    trainScore = cph.score(rossi_train)
    testScore = cph.score(rossi_test)
    a=0

###################################################### MAIN STARTS HERE #######################################################
plt.close('all')
time_start = time.time()

if __name__ == "__main__":
    globals.initialize()

allTrials, arrHitTrials, arrFaTrials, arrMissTrials, fixedHoldStartsAtTrial, \
holdRandomX, holdRandomHitX, holdRandomFaX, holdRandomMissX, \
holdFixedX, holdFixedHitX, holdFixedFaX, holdFixedMissX, \
releaseRandomX, releaseRandomHitX, releaseRandomFaX, releaseRandomMissX, \
releaseFixedX, releaseFixedHitX, releaseFixedFaX, releaseFixedMissX, \
targetRandomX, targetRandomHitX, targetRandomFaX, targetRandomMissX, \
targetFixedX, targetFixedHitX, targetFixedFaX, targetFixedMissX, \
responseTypeHoldFixedAll, responseTypeHoldFixedHit, responseTypeHoldFixedFa, responseTypeHoldFixedMiss, \
responseTypeReleaseFixedAll, responseTypeReleaseFixedHit, responseTypeReleaseFixedFa, responseTypeReleaseFixedMiss, \
responseTypeTargetFixedAll, responseTypeTargetFixedHit, responseTypeTargetFixedMiss, \
neuronTypeY, \
spikeRatesofTrialsVSUnits_HoldRandomAll, spikeRatesofTrialsVSUnits_HoldFixedAll, spikeRatesofTrialsVSUnits_ReleaseRandomAll, spikeRatesofTrialsVSUnits_ReleaseFixedAll, \
spikeRatesofTrialsVSUnits_BReleaseRandomAll, spikeRatesofTrialsVSUnits_AReleaseRandomAll, spikeRatesofTrialsVSUnits_BReleaseFixedAll, spikeRatesofTrialsVSUnits_AReleaseFixedAll, \
spikeRatesofTrialsVSUnits_TargetRandomAll, spikeRatesofTrialsVSUnits_TargetFixedAll, \
spikeRatesofTrialsVSUnits_HoldRandomHit, spikeRatesofTrialsVSUnits_HoldFixedHit, spikeRatesofTrialsVSUnits_ReleaseRandomHit, spikeRatesofTrialsVSUnits_ReleaseFixedHit, \
spikeRatesofTrialsVSUnits_TargetRandomHit, spikeRatesofTrialsVSUnits_TargetFixedHit, \
spikeRatesofTrialsVSUnits_HoldRandomFa, spikeRatesofTrialsVSUnits_HoldFixedFa, spikeRatesofTrialsVSUnits_ReleaseRandomFa, spikeRatesofTrialsVSUnits_ReleaseFixedFa, \
spikeRatesofTrialsVSUnits_TargetRandomFa, spikeRatesofTrialsVSUnits_TargetFixedFa, \
spikeRatesofTrialsVSUnits_HoldRandomMiss, spikeRatesofTrialsVSUnits_HoldFixedMiss, spikeRatesofTrialsVSUnits_ReleaseRandomMiss, spikeRatesofTrialsVSUnits_ReleaseFixedMiss, \
spikeRatesofTrialsVSUnits_TargetRandomMiss, spikeRatesofTrialsVSUnits_TargetFixedMiss, \
arrReactTimesRandomAll, arrReactTimesRandomHit, arrReactTimesRandomFa, arrReactTimesRandomMiss, \
arrReactTimesFixedAll, arrReactTimesFixedHit, arrReactTimesFixedFa, arrReactTimesFixedMiss = readFromMat.importRecordingsFromMat()

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

neuronTypeRandY = neuronTypeY[randomIds]
print('Data randomization ==> Time elapsed: {0:.2f} seconds'.format(time.time()-time_start))

####################### PCA starts here ######################
# runPCAAnalysis(holdRandomX, holdRandomHitX, holdRandomFaX, holdRandomMissX, holdFixedX, holdFixedHitX, holdFixedFaX, holdFixedMissX,
#                releaseRandomX, releaseRandomHitX, releaseRandomFaX, releaseRandomMissX, releaseFixedX, releaseFixedHitX, releaseFixedFaX, releaseFixedMissX,
#                targetRandomX, targetRandomHitX, targetRandomFaX, targetRandomMissX, targetFixedX, targetFixedHitX, targetFixedFaX, targetFixedMissX, neuronTypeRandY)

####################### t-SNE starts here ######################
# runTSNEAnalysis(holdRandomX, holdRandomHitX, holdRandomFaX, holdRandomMissX, holdFixedX, holdFixedHitX, holdFixedFaX, holdFixedMissX,
#                releaseRandomX, releaseRandomHitX, releaseRandomFaX, releaseRandomMissX, releaseFixedX, releaseFixedHitX, releaseFixedFaX, releaseFixedMissX,
#                targetRandomX, targetRandomHitX, targetRandomFaX, targetRandomMissX, targetFixedX, targetFixedHitX, targetFixedFaX, targetFixedMissX, neuronTypeRandY)

###################### Linear Model starts here ################

# runGLM(spikeRatesofTrialsVSUnits_HoldRandomHit, spikeRatesofTrialsVSUnits_HoldFixedHit,
#                spikeRatesofTrialsVSUnits_ReleaseRandomHit, spikeRatesofTrialsVSUnits_ReleaseFixedHit,
#                spikeRatesofTrialsVSUnits_TargetRandomHit, spikeRatesofTrialsVSUnits_TargetFixedHit,
#                spikeRatesofTrialsVSUnits_HoldRandomFa, spikeRatesofTrialsVSUnits_HoldFixedFa,
#                spikeRatesofTrialsVSUnits_ReleaseRandomFa, spikeRatesofTrialsVSUnits_ReleaseFixedFa,
#                spikeRatesofTrialsVSUnits_TargetRandomFa, spikeRatesofTrialsVSUnits_TargetFixedFa,
#                spikeRatesofTrialsVSUnits_HoldRandomMiss, spikeRatesofTrialsVSUnits_HoldFixedMiss,
#                spikeRatesofTrialsVSUnits_ReleaseRandomMiss, spikeRatesofTrialsVSUnits_ReleaseFixedMiss,
#                spikeRatesofTrialsVSUnits_TargetRandomMiss, spikeRatesofTrialsVSUnits_TargetFixedMiss,
#                arrReactTimesRandomAll, arrReactTimesRandomHit, arrReactTimesRandomFa, arrReactTimesRandomMiss,
#                arrReactTimesFixedAll, arrReactTimesFixedHit, arrReactTimesFixedFa, arrReactTimesFixedMiss, neuronTypeY)

# runSVR(spikeRatesofTrialsVSUnits_HoldRandomHit, spikeRatesofTrialsVSUnits_HoldFixedHit,
#                spikeRatesofTrialsVSUnits_ReleaseRandomHit, spikeRatesofTrialsVSUnits_ReleaseFixedHit,
#                spikeRatesofTrialsVSUnits_TargetRandomHit, spikeRatesofTrialsVSUnits_TargetFixedHit,
#                spikeRatesofTrialsVSUnits_HoldRandomFa, spikeRatesofTrialsVSUnits_HoldFixedFa,
#                spikeRatesofTrialsVSUnits_ReleaseRandomFa, spikeRatesofTrialsVSUnits_ReleaseFixedFa,
#                spikeRatesofTrialsVSUnits_TargetRandomFa, spikeRatesofTrialsVSUnits_TargetFixedFa,
#                spikeRatesofTrialsVSUnits_HoldRandomMiss, spikeRatesofTrialsVSUnits_HoldFixedMiss,
#                spikeRatesofTrialsVSUnits_ReleaseRandomMiss, spikeRatesofTrialsVSUnits_ReleaseFixedMiss,
#                spikeRatesofTrialsVSUnits_TargetRandomMiss, spikeRatesofTrialsVSUnits_TargetFixedMiss,
#                arrReactTimesRandomAll, arrReactTimesRandomHit, arrReactTimesRandomFa, arrReactTimesRandomMiss,
#                arrReactTimesFixedAll, arrReactTimesFixedHit, arrReactTimesFixedFa, arrReactTimesFixedMiss, neuronTypeY)

# runLasso(responseTypeHoldFixedAll, responseTypeHoldFixedHit, responseTypeHoldFixedFa, responseTypeHoldFixedMiss,
#             responseTypeReleaseFixedAll, responseTypeReleaseFixedHit, responseTypeReleaseFixedFa, responseTypeReleaseFixedMiss,
#             responseTypeTargetFixedAll, responseTypeTargetFixedHit, responseTypeTargetFixedMiss,
#             spikeRatesofTrialsVSUnits_HoldRandomHit, spikeRatesofTrialsVSUnits_HoldFixedHit,
#             spikeRatesofTrialsVSUnits_ReleaseRandomHit, spikeRatesofTrialsVSUnits_ReleaseFixedHit,
#             spikeRatesofTrialsVSUnits_TargetRandomHit, spikeRatesofTrialsVSUnits_TargetFixedHit,
#             spikeRatesofTrialsVSUnits_HoldRandomFa, spikeRatesofTrialsVSUnits_HoldFixedFa,
#             spikeRatesofTrialsVSUnits_ReleaseRandomFa, spikeRatesofTrialsVSUnits_ReleaseFixedFa,
#             spikeRatesofTrialsVSUnits_TargetRandomFa, spikeRatesofTrialsVSUnits_TargetFixedFa,
#             spikeRatesofTrialsVSUnits_HoldRandomMiss, spikeRatesofTrialsVSUnits_HoldFixedMiss,
#             spikeRatesofTrialsVSUnits_ReleaseRandomMiss, spikeRatesofTrialsVSUnits_ReleaseFixedMiss,
#             spikeRatesofTrialsVSUnits_TargetRandomMiss, spikeRatesofTrialsVSUnits_TargetFixedMiss,
#             arrReactTimesRandomAll, arrReactTimesRandomHit, arrReactTimesRandomFa, arrReactTimesRandomMiss,
#             arrReactTimesFixedAll, arrReactTimesFixedHit, arrReactTimesFixedFa, arrReactTimesFixedMiss, neuronTypeY)

# runLinearModel(spikeRatesofTrialsVSUnits_HoldRandomHit, spikeRatesofTrialsVSUnits_HoldFixedHit,
#                spikeRatesofTrialsVSUnits_ReleaseRandomHit, spikeRatesofTrialsVSUnits_ReleaseFixedHit,
#                spikeRatesofTrialsVSUnits_TargetRandomHit, spikeRatesofTrialsVSUnits_TargetFixedHit,
#                spikeRatesofTrialsVSUnits_HoldRandomFa, spikeRatesofTrialsVSUnits_HoldFixedFa,
#                spikeRatesofTrialsVSUnits_ReleaseRandomFa, spikeRatesofTrialsVSUnits_ReleaseFixedFa,
#                spikeRatesofTrialsVSUnits_TargetRandomFa, spikeRatesofTrialsVSUnits_TargetFixedFa,
#                spikeRatesofTrialsVSUnits_HoldRandomMiss, spikeRatesofTrialsVSUnits_HoldFixedMiss,
#                spikeRatesofTrialsVSUnits_ReleaseRandomMiss, spikeRatesofTrialsVSUnits_ReleaseFixedMiss,
#                spikeRatesofTrialsVSUnits_TargetRandomMiss, spikeRatesofTrialsVSUnits_TargetFixedMiss,
#                arrReactTimesRandomAll, arrReactTimesRandomHit, arrReactTimesRandomFa, arrReactTimesRandomMiss,
#                arrReactTimesFixedAll, arrReactTimesFixedHit, arrReactTimesFixedFa, arrReactTimesFixedMiss, neuronTypeY)

# runMultinomialLogisticRegression(allTrials, arrHitTrials, arrFaTrials, arrMissTrials, fixedHoldStartsAtTrial,
#                                  spikeRatesofTrialsVSUnits_HoldRandomAll, spikeRatesofTrialsVSUnits_HoldFixedAll,
#                                  spikeRatesofTrialsVSUnits_ReleaseRandomAll, spikeRatesofTrialsVSUnits_ReleaseFixedAll,
#                                  spikeRatesofTrialsVSUnits_TargetRandomAll, spikeRatesofTrialsVSUnits_TargetFixedAll,
#                                  responseTypeHoldFixedAll, responseTypeReleaseFixedAll, responseTypeTargetFixedAll,
#                                  expertLabels)

runMultinomialLogisticRegression(allTrials, arrHitTrials, arrFaTrials, arrMissTrials, fixedHoldStartsAtTrial,
                                 spikeRatesofTrialsVSUnits_HoldRandomAll, spikeRatesofTrialsVSUnits_HoldFixedAll,
                                 spikeRatesofTrialsVSUnits_BReleaseRandomAll, spikeRatesofTrialsVSUnits_BReleaseFixedAll,
                                 spikeRatesofTrialsVSUnits_TargetRandomAll, spikeRatesofTrialsVSUnits_TargetFixedAll,
                                 responseTypeHoldFixedAll, responseTypeReleaseFixedAll, responseTypeTargetFixedAll,
                                 expertLabels)

runCoxPropHazard(allTrials, arrHitTrials, arrFaTrials, arrMissTrials, fixedHoldStartsAtTrial,
                                 spikeRatesofTrialsVSUnits_HoldRandomAll, spikeRatesofTrialsVSUnits_HoldFixedAll,
                                 spikeRatesofTrialsVSUnits_ReleaseRandomAll, spikeRatesofTrialsVSUnits_ReleaseFixedAll,
                                 spikeRatesofTrialsVSUnits_TargetRandomAll, spikeRatesofTrialsVSUnits_TargetFixedAll,
                                 responseTypeHoldFixedAll, responseTypeReleaseFixedAll, responseTypeTargetFixedAll,
                                 expertLabels)