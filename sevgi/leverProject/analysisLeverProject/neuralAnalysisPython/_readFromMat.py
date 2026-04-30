import gc
import numpy as np
import scipy.io as sio
import globals


def importRecordingsFromMat():
    allRecStruct = sio.loadmat(globals.ALL_RECORDINGS_FILE)  # , squeeze_me=True)
    gc.collect()

    allUnitsSpikeRatesHoldRandomAll = []
    allUnitsSpikeRatesHoldRandomHit = []
    allUnitsSpikeRatesHoldRandomFa = []
    allUnitsSpikeRatesHoldRandomMiss = []

    allUnitsSpikeRatesHoldFixedAll = []
    allUnitsSpikeRatesHoldFixedHit = []
    allUnitsSpikeRatesHoldFixedFa = []
    allUnitsSpikeRatesHoldFixedMiss = []

    allUnitsSpikeRatesReleaseRandomAll = []
    allUnitsSpikeRatesReleaseRandomHit = []
    allUnitsSpikeRatesReleaseRandomFa = []
    allUnitsSpikeRatesReleaseRandomMiss = []

    allUnitsSpikeRatesReleaseFixedAll = []
    allUnitsSpikeRatesReleaseFixedHit = []
    allUnitsSpikeRatesReleaseFixedFa = []
    allUnitsSpikeRatesReleaseFixedMiss = []

    allUnitsSpikeRatesTargetRandomAll = []
    allUnitsSpikeRatesTargetRandomHit = []
    allUnitsSpikeRatesTargetRandomFa = []
    allUnitsSpikeRatesTargetRandomMiss = []

    allUnitsSpikeRatesTargetFixedAll = []
    allUnitsSpikeRatesTargetFixedHit = []
    allUnitsSpikeRatesTargetFixedFa = []
    allUnitsSpikeRatesTargetFixedMiss = []

    unitNeuronType = []

    for key, value in allRecStruct.items():
        if key.startswith(globals.DATA_FILE_NAME):
            unitsAndVariables = value[0, 0]
            units = unitsAndVariables['unitGood']
            a = np.shape(units)
            l = len(units)
            leverHoldTimesGLX = unitsAndVariables['leverHoldTimesGLX']
            leverReleaseTimesGLX = unitsAndVariables['leverReleaseTimesGLX']
            targetStimTimesGLX = unitsAndVariables['targetStimTimesGLX']
            baselineStimTimesGLX = unitsAndVariables['baselineStimTimesGLX']
            trialCutIndex = unitsAndVariables['trialCutIndex']
            allTrials = unitsAndVariables['allTrials']
            arrHitTrials = unitsAndVariables['arrHitTrials']
            arrFaTrials = unitsAndVariables['arrFaTrials']
            arrMissTrials = unitsAndVariables['arrMissTrials']
            arrStimTurnedOnTrials = unitsAndVariables['arrStimTurnedOnTrials']
            arrReqHoldTimes = unitsAndVariables['arrReqHoldTimes']
            arrReactTimes = unitsAndVariables['arrReactTimes']
            tooFastTime = unitsAndVariables['tooFastTime'][0, 0]
            reactTime = unitsAndVariables['reactTime'][0, 0]
            preHoldTime = unitsAndVariables['preHoldTime'][0, 0]
            fixedHoldStartsAtTrial = unitsAndVariables['fixedHoldStartsAtTrial'][0, 0]
            softCut = unitsAndVariables['softCut'][0, 0]
            softCutPartition = unitsAndVariables['softCutPartition'][0, 0]

            lenUnits = np.shape(units)[1]
            unitSpikeRatesHoldRandomAll = np.zeros((lenUnits, globals.TSNE_FEATURE_SIZE))
            unitSpikeRatesHoldRandomHit = np.zeros((lenUnits, globals.TSNE_FEATURE_SIZE))
            unitSpikeRatesHoldRandomFa = np.zeros((lenUnits, globals.TSNE_FEATURE_SIZE))
            unitSpikeRatesHoldRandomMiss = np.zeros((lenUnits, globals.TSNE_FEATURE_SIZE))

            unitSpikeRatesHoldFixedAll = np.zeros((lenUnits, globals.TSNE_FEATURE_SIZE))
            unitSpikeRatesHoldFixedHit = np.zeros((lenUnits, globals.TSNE_FEATURE_SIZE))
            unitSpikeRatesHoldFixedFa = np.zeros((lenUnits, globals.TSNE_FEATURE_SIZE))
            unitSpikeRatesHoldFixedMiss = np.zeros((lenUnits, globals.TSNE_FEATURE_SIZE))

            unitSpikeRatesReleaseRandomAll = np.zeros((lenUnits, globals.TSNE_FEATURE_SIZE))
            unitSpikeRatesReleaseRandomHit = np.zeros((lenUnits, globals.TSNE_FEATURE_SIZE))
            unitSpikeRatesReleaseRandomFa = np.zeros((lenUnits, globals.TSNE_FEATURE_SIZE))
            unitSpikeRatesReleaseRandomMiss = np.zeros((lenUnits, globals.TSNE_FEATURE_SIZE))

            unitSpikeRatesReleaseFixedAll = np.zeros((lenUnits, globals.TSNE_FEATURE_SIZE))
            unitSpikeRatesReleaseFixedHit = np.zeros((lenUnits, globals.TSNE_FEATURE_SIZE))
            unitSpikeRatesReleaseFixedFa = np.zeros((lenUnits, globals.TSNE_FEATURE_SIZE))
            unitSpikeRatesReleaseFixedMiss = np.zeros((lenUnits, globals.TSNE_FEATURE_SIZE))

            unitSpikeRatesTargetRandomAll = np.zeros((lenUnits, globals.TSNE_FEATURE_SIZE))
            unitSpikeRatesTargetRandomHit = np.zeros((lenUnits, globals.TSNE_FEATURE_SIZE))
            unitSpikeRatesTargetRandomFa = np.zeros((lenUnits, globals.TSNE_FEATURE_SIZE))
            unitSpikeRatesTargetRandomMiss = np.zeros((lenUnits, globals.TSNE_FEATURE_SIZE))

            unitSpikeRatesTargetFixedAll = np.zeros((lenUnits, globals.TSNE_FEATURE_SIZE))
            unitSpikeRatesTargetFixedHit = np.zeros((lenUnits, globals.TSNE_FEATURE_SIZE))
            unitSpikeRatesTargetFixedFa = np.zeros((lenUnits, globals.TSNE_FEATURE_SIZE))
            unitSpikeRatesTargetFixedMiss = np.zeros((lenUnits, globals.TSNE_FEATURE_SIZE))

            for indUnit in range(lenUnits):
                # unitTemp = units[indUnit]
                unit = units[0][indUnit]
                id = unit['id'][0, 0]
                spikeTimesSecs = unit['spikeTimesSecs']
                amplitudes = unit['amplitudes']
                ch = unit['ch'][0, 0]
                depth = unit['depth'][0, 0]
                fr = unit['fr'][0, 0]
                clusterAmp = unit['clusterAmpl'][0, 0]
                group = unit['group']
                nSpikes = unit['nSpikes'][0, 0]
                SNR = unit['SNR'][0, 0]
                neuronType = unit['neuronType']
                layer = unit['layer'][0]
                KSLabel = unit['KSLabel']
                if len(KSLabel) > 0:
                    KSLabel = KSLabel[0]
                spikeTimeAlignedToLeverHoldAll = unit['spikeTimeAlignedToLeverHoldAll']
                spikeTimeAlignedToLeverReleaseAll = unit['spikeTimeAlignedToLeverReleaseAll']
                spikeTimeAlignedToTargetVisStimAll = unit['spikeTimeAlignedToTargetVisStimAll']
                spikeTimeAlignedToBaselineVisStimAll = unit['spikeTimeAlignedToBaselineVisStimAll']

                spikeRatesHoldRandomAll = unit['spikeRatesHoldRandomAll']
                spikeRatesHoldFixedAll = unit['spikeRatesHoldFixedAll']
                spikeRatesHoldRandomHFM = unit['spikeRatesHoldRandomHFM']
                spikeRatesHoldFixedHFM = unit['spikeRatesHoldFixedHFM']

                spikeRatesReleaseRandomAll = unit['spikeRatesReleaseRandomAll']
                spikeRatesReleaseFixedAll = unit['spikeRatesReleaseFixedAll']
                spikeRatesReleaseRandomHFM = unit['spikeRatesReleaseRandomHFM']
                spikeRatesReleaseFixedHFM = unit['spikeRatesReleaseFixedHFM']

                spikeRatesTargetRandomAll = unit['spikeRatesTargetRandomAll']
                spikeRatesTargetFixedAll = unit['spikeRatesTargetFixedAll']
                spikeRatesTargetRandomHFM = unit['spikeRatesTargetRandomHFM']
                spikeRatesTargetFixedHFM = unit['spikeRatesTargetFixedHFM']

                unitSpikeRatesHoldRandomAll[indUnit, :] = spikeRatesHoldRandomAll
                unitSpikeRatesHoldRandomHit[indUnit, :] = spikeRatesHoldRandomHFM[0, :]
                unitSpikeRatesHoldRandomFa[indUnit, :] = spikeRatesHoldRandomHFM[1, :]
                unitSpikeRatesHoldRandomMiss[indUnit, :] = spikeRatesHoldRandomHFM[2, :]

                unitSpikeRatesHoldFixedAll[indUnit, :] = spikeRatesHoldFixedAll
                unitSpikeRatesHoldFixedHit[indUnit, :] = spikeRatesHoldFixedHFM[0, :]
                unitSpikeRatesHoldFixedFa[indUnit, :] = spikeRatesHoldFixedHFM[1, :]
                unitSpikeRatesHoldFixedMiss[indUnit, :] = spikeRatesHoldFixedHFM[2, :]

                unitSpikeRatesReleaseRandomAll[indUnit, :] = spikeRatesReleaseRandomAll
                unitSpikeRatesReleaseRandomHit[indUnit, :] = spikeRatesReleaseRandomHFM[0, :]
                unitSpikeRatesReleaseRandomFa[indUnit, :] = spikeRatesReleaseRandomHFM[1, :]
                unitSpikeRatesReleaseRandomMiss[indUnit, :] = spikeRatesReleaseRandomHFM[2, :]

                unitSpikeRatesReleaseFixedAll[indUnit, :] = spikeRatesReleaseFixedAll
                unitSpikeRatesReleaseFixedHit[indUnit, :] = spikeRatesReleaseFixedHFM[0, :]
                unitSpikeRatesReleaseFixedFa[indUnit, :] = spikeRatesReleaseFixedHFM[1, :]
                unitSpikeRatesReleaseFixedMiss[indUnit, :] = spikeRatesReleaseFixedHFM[2, :]

                unitSpikeRatesTargetRandomAll[indUnit, :] = spikeRatesTargetRandomAll
                unitSpikeRatesTargetRandomHit[indUnit, :] = spikeRatesTargetRandomHFM[0, :]
                unitSpikeRatesTargetRandomFa[indUnit, :] = spikeRatesTargetRandomHFM[1, :]
                unitSpikeRatesTargetRandomMiss[indUnit, :] = spikeRatesTargetRandomHFM[2, :]

                unitSpikeRatesTargetFixedAll[indUnit, :] = spikeRatesTargetFixedAll
                unitSpikeRatesTargetFixedHit[indUnit, :] = spikeRatesTargetFixedHFM[0, :]
                unitSpikeRatesTargetFixedFa[indUnit, :] = spikeRatesTargetFixedHFM[1, :]
                unitSpikeRatesTargetFixedMiss[indUnit, :] = spikeRatesTargetFixedHFM[2, :]

                if len(neuronType) == 0:
                    neuronType = np.array(['Unknown'])
                unitNeuronType.append(neuronType)

            allUnitsSpikeRatesHoldRandomAll.append(unitSpikeRatesHoldRandomAll)
            allUnitsSpikeRatesHoldRandomHit.append(unitSpikeRatesHoldRandomHit)
            allUnitsSpikeRatesHoldRandomFa.append(unitSpikeRatesHoldRandomFa)
            allUnitsSpikeRatesHoldRandomMiss.append(unitSpikeRatesHoldRandomMiss)

            allUnitsSpikeRatesHoldFixedAll.append(unitSpikeRatesHoldFixedAll)
            allUnitsSpikeRatesHoldFixedHit.append(unitSpikeRatesHoldFixedHit)
            allUnitsSpikeRatesHoldFixedFa.append(unitSpikeRatesHoldFixedFa)
            allUnitsSpikeRatesHoldFixedMiss.append(unitSpikeRatesHoldFixedMiss)

            allUnitsSpikeRatesReleaseRandomAll.append(unitSpikeRatesReleaseRandomAll)
            allUnitsSpikeRatesReleaseRandomHit.append(unitSpikeRatesReleaseRandomHit)
            allUnitsSpikeRatesReleaseRandomFa.append(unitSpikeRatesReleaseRandomFa)
            allUnitsSpikeRatesReleaseRandomMiss.append(unitSpikeRatesReleaseRandomMiss)

            allUnitsSpikeRatesReleaseFixedAll.append(unitSpikeRatesReleaseFixedAll)
            allUnitsSpikeRatesReleaseFixedHit.append(unitSpikeRatesReleaseFixedHit)
            allUnitsSpikeRatesReleaseFixedFa.append(unitSpikeRatesReleaseFixedFa)
            allUnitsSpikeRatesReleaseFixedMiss.append(unitSpikeRatesReleaseFixedMiss)

            allUnitsSpikeRatesTargetRandomAll.append(unitSpikeRatesTargetRandomAll)
            allUnitsSpikeRatesTargetRandomHit.append(unitSpikeRatesTargetRandomHit)
            allUnitsSpikeRatesTargetRandomFa.append(unitSpikeRatesTargetRandomFa)
            allUnitsSpikeRatesTargetRandomMiss.append(unitSpikeRatesTargetRandomMiss)

            allUnitsSpikeRatesTargetFixedAll.append(unitSpikeRatesTargetFixedAll)
            allUnitsSpikeRatesTargetFixedHit.append(unitSpikeRatesTargetFixedHit)
            allUnitsSpikeRatesTargetFixedFa.append(unitSpikeRatesTargetFixedFa)
            allUnitsSpikeRatesTargetFixedMiss.append(unitSpikeRatesTargetFixedMiss)

    arrAllUnitsSpikeRatesHoldRandomAll, arrAllUnitsSpikeRatesHoldRandomHit, arrAllUnitsSpikeRatesHoldRandomFa, arrAllUnitsSpikeRatesHoldRandomMiss = \
        concatAllHFM(allUnitsSpikeRatesHoldRandomAll, allUnitsSpikeRatesHoldRandomHit, allUnitsSpikeRatesHoldRandomFa, allUnitsSpikeRatesHoldRandomMiss)

    arrAllUnitsSpikeRatesHoldFixedAll, arrAllUnitsSpikeRatesHoldFixedHit, arrAllUnitsSpikeRatesHoldFixedFa, arrAllUnitsSpikeRatesHoldFixedMiss = \
        concatAllHFM(allUnitsSpikeRatesHoldFixedAll, allUnitsSpikeRatesHoldFixedHit, allUnitsSpikeRatesHoldFixedFa, allUnitsSpikeRatesHoldFixedMiss)

    arrAllUnitsSpikeRatesReleaseRandomAll, arrAllUnitsSpikeRatesReleaseRandomHit, arrAllUnitsSpikeRatesReleaseRandomFa, arrAllUnitsSpikeRatesReleaseRandomMiss = \
        concatAllHFM(allUnitsSpikeRatesReleaseRandomAll, allUnitsSpikeRatesReleaseRandomHit, allUnitsSpikeRatesReleaseRandomFa, allUnitsSpikeRatesReleaseRandomMiss)

    arrAllUnitsSpikeRatesReleaseFixedAll, arrAllUnitsSpikeRatesReleaseFixedHit, arrAllUnitsSpikeRatesReleaseFixedFa, arrAllUnitsSpikeRatesReleaseFixedMiss = \
        concatAllHFM(allUnitsSpikeRatesReleaseFixedAll, allUnitsSpikeRatesReleaseFixedHit, allUnitsSpikeRatesReleaseFixedFa, allUnitsSpikeRatesReleaseFixedMiss)

    arrAllUnitsSpikeRatesTargetRandomAll, arrAllUnitsSpikeRatesTargetRandomHit, arrAllUnitsSpikeRatesTargetRandomFa, arrAllUnitsSpikeRatesTargetRandomMiss = \
        concatAllHFM(allUnitsSpikeRatesTargetRandomAll, allUnitsSpikeRatesTargetRandomHit, allUnitsSpikeRatesTargetRandomFa, allUnitsSpikeRatesTargetRandomMiss)

    arrAllUnitsSpikeRatesTargetFixedAll, arrAllUnitsSpikeRatesTargetFixedHit, arrAllUnitsSpikeRatesTargetFixedFa, arrAllUnitsSpikeRatesTargetFixedMiss = \
        concatAllHFM(allUnitsSpikeRatesTargetFixedAll, allUnitsSpikeRatesTargetFixedHit, allUnitsSpikeRatesTargetFixedFa, allUnitsSpikeRatesTargetFixedMiss)

    arrUnitNeuronType = np.concatenate(unitNeuronType, axis=0)

    return arrAllUnitsSpikeRatesHoldRandomAll, arrAllUnitsSpikeRatesHoldRandomHit, arrAllUnitsSpikeRatesHoldRandomFa, arrAllUnitsSpikeRatesHoldRandomMiss,\
           arrAllUnitsSpikeRatesHoldFixedAll, arrAllUnitsSpikeRatesHoldFixedHit, arrAllUnitsSpikeRatesHoldFixedFa, arrAllUnitsSpikeRatesHoldFixedMiss, \
           arrAllUnitsSpikeRatesReleaseRandomAll, arrAllUnitsSpikeRatesReleaseRandomHit, arrAllUnitsSpikeRatesReleaseRandomFa, arrAllUnitsSpikeRatesReleaseRandomMiss, \
           arrAllUnitsSpikeRatesReleaseFixedAll, arrAllUnitsSpikeRatesReleaseFixedHit, arrAllUnitsSpikeRatesReleaseFixedFa, arrAllUnitsSpikeRatesReleaseFixedMiss, \
           arrAllUnitsSpikeRatesTargetRandomAll, arrAllUnitsSpikeRatesTargetRandomHit, arrAllUnitsSpikeRatesTargetRandomFa, arrAllUnitsSpikeRatesTargetRandomMiss, \
           arrAllUnitsSpikeRatesTargetFixedAll, arrAllUnitsSpikeRatesTargetFixedHit, arrAllUnitsSpikeRatesTargetFixedFa, arrAllUnitsSpikeRatesTargetFixedMiss, \
           arrUnitNeuronType


# gets lists as inputs
# returns concatenated numpy arrays
def concatAllHFM(all, hit, fa, miss):
    npAll = np.concatenate(all, axis=0)
    npHit = np.concatenate(hit, axis=0)
    npFa = np.concatenate(fa, axis=0)
    npMiss = np.concatenate(miss, axis=0)
    return npAll, npHit, npFa, npMiss

