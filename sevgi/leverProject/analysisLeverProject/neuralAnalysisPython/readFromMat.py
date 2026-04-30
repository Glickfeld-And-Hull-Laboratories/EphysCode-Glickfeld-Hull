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

    allUnitsResponseTypeHoldFixedAll = []
    allUnitsResponseTypeHoldFixedHit = []
    allUnitsResponseTypeHoldFixedFa = []
    allUnitsResponseTypeHoldFixedMiss = []
    allUnitsResponseTypeReleaseFixedAll = []
    allUnitsResponseTypeReleaseFixedHit = []
    allUnitsResponseTypeReleaseFixedFa = []
    allUnitsResponseTypeReleaseFixedMiss = []
    allUnitsResponseTypeTargetFixedAll = []
    allUnitsResponseTypeTargetFixedHit = []
    allUnitsResponseTypeTargetFixedMiss = []

    listReactTimesRandomAll = []
    listReactTimesRandomHit = []
    listReactTimesRandomFa = []
    listReactTimesRandomMiss = []

    listReactTimesFixedAll = []
    listReactTimesFixedHit = []
    listReactTimesFixedFa = []
    listReactTimesFixedMiss = []

    unitNeuronType = []

    for key, value in allRecStruct.items():
        if key.startswith(globals.DATA_FILE_NAME):
            unitsAndVariables = value[0, 0]
            print(np.shape(unitsAndVariables))
            units = unitsAndVariables['unitGood']
            leverHoldTimes = unitsAndVariables['leverHoldTimes'][0]
            leverReleaseTimesGLX = unitsAndVariables['leverReleaseTimesGLX'][0]
            targetStimTimesGLX = unitsAndVariables['targetStimTimesGLX'][0]
            baselineStimTimesGLX = unitsAndVariables['baselineStimTimesGLX'][0]
            trialCutIndex = unitsAndVariables['trialCutIndex']
            if trialCutIndex:   # if not empty
                trialCutIndex = trialCutIndex[0, 0]
            allTrials = unitsAndVariables['allTrials'][0]
            arrHitTrials = unitsAndVariables['arrHitTrials'][0]
            arrFaTrials = unitsAndVariables['arrFaTrials'][0]
            arrMissTrials = unitsAndVariables['arrMissTrials'][0]
            arrStimTurnedOnTrials = unitsAndVariables['arrStimTurnedOnTrials'][0]
            arrReqHoldTimes = unitsAndVariables['arrReqHoldTimes'][0]
            arrReactTimes = unitsAndVariables['arrReactTimes'][0]
            tooFastTime = unitsAndVariables['tooFastTime'][0, 0]
            reactTime = unitsAndVariables['reactTime'][0, 0]
            preHoldTime = unitsAndVariables['preHoldTime'][0, 0]
            fixedHoldStartsAtTrial = unitsAndVariables['fixedHoldStartsAtTrial'][0, 0]
            softCut = unitsAndVariables['softCut'][0, 0]
            softCutPartition = unitsAndVariables['softCutPartition'][0, 0]
            hardCut = unitsAndVariables['hardCut'][0, 0]
            hardCutPartition = unitsAndVariables['hardCutPartition'][0, 0]

            lenUnits = np.shape(units)[1]
            lenFeatureSizeHold = np.shape(globals.EDGES_HOLD)[0]
            lenFeatureSizeRelease = np.shape(globals.EDGES_RELEASE)[0]
            lenFeatureSizeTarget = np.shape(globals.EDGES_VIS_STIM)[0]

            unitSpikeRatesHoldRandomAll = np.zeros((lenUnits, lenFeatureSizeHold))
            unitSpikeRatesHoldRandomHit = np.zeros((lenUnits, lenFeatureSizeHold))
            unitSpikeRatesHoldRandomFa = np.zeros((lenUnits, lenFeatureSizeHold))
            unitSpikeRatesHoldRandomMiss = np.zeros((lenUnits, lenFeatureSizeHold))

            unitSpikeRatesHoldFixedAll = np.zeros((lenUnits, lenFeatureSizeHold))
            unitSpikeRatesHoldFixedHit = np.zeros((lenUnits, lenFeatureSizeHold))
            unitSpikeRatesHoldFixedFa = np.zeros((lenUnits, lenFeatureSizeHold))
            unitSpikeRatesHoldFixedMiss = np.zeros((lenUnits, lenFeatureSizeHold))

            unitSpikeRatesReleaseRandomAll = np.zeros((lenUnits, lenFeatureSizeRelease))
            unitSpikeRatesReleaseRandomHit = np.zeros((lenUnits, lenFeatureSizeRelease))
            unitSpikeRatesReleaseRandomFa = np.zeros((lenUnits, lenFeatureSizeRelease))
            unitSpikeRatesReleaseRandomMiss = np.zeros((lenUnits, lenFeatureSizeRelease))

            unitSpikeRatesReleaseFixedAll = np.zeros((lenUnits, lenFeatureSizeRelease))
            unitSpikeRatesReleaseFixedHit = np.zeros((lenUnits, lenFeatureSizeRelease))
            unitSpikeRatesReleaseFixedFa = np.zeros((lenUnits, lenFeatureSizeRelease))
            unitSpikeRatesReleaseFixedMiss = np.zeros((lenUnits, lenFeatureSizeRelease))

            unitSpikeRatesTargetRandomAll = np.zeros((lenUnits, lenFeatureSizeTarget))
            unitSpikeRatesTargetRandomHit = np.zeros((lenUnits, lenFeatureSizeTarget))
            unitSpikeRatesTargetRandomFa = np.zeros((lenUnits, lenFeatureSizeTarget))
            unitSpikeRatesTargetRandomMiss = np.zeros((lenUnits, lenFeatureSizeTarget))

            unitSpikeRatesTargetFixedAll = np.zeros((lenUnits, lenFeatureSizeTarget))
            unitSpikeRatesTargetFixedHit = np.zeros((lenUnits, lenFeatureSizeTarget))
            unitSpikeRatesTargetFixedFa = np.zeros((lenUnits, lenFeatureSizeTarget))
            unitSpikeRatesTargetFixedMiss = np.zeros((lenUnits, lenFeatureSizeTarget))

            unitResponseTypeHoldFixedAll = np.zeros((lenUnits,1))
            unitResponseTypeHoldFixedHit = np.zeros((lenUnits,1))
            unitResponseTypeHoldFixedFa = np.zeros((lenUnits, 1))
            unitResponseTypeHoldFixedMiss = np.zeros((lenUnits, 1))

            unitResponseTypeReleaseFixedAll = np.zeros((lenUnits,1))
            unitResponseTypeReleaseFixedHit = np.zeros((lenUnits,1))
            unitResponseTypeReleaseFixedFa = np.zeros((lenUnits, 1))
            unitResponseTypeReleaseFixedMiss = np.zeros((lenUnits, 1))

            unitResponseTypeTargetFixedAll = np.zeros((lenUnits,1))
            unitResponseTypeTargetFixedHit = np.zeros((lenUnits,1))
            unitResponseTypeTargetFixedMiss = np.zeros((lenUnits, 1))

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
                if len(neuronType) == 0:
                    neuronType = np.array(['Unknown'])

                layer = unit['layer'] # [0]
                KSLabel = unit['KSLabel']
                if len(KSLabel) > 0:
                    KSLabel = KSLabel[0]

                spikeTimeHoldAll = unit['spikeTimeHoldAll']
                spikeTimeReleaseAll = unit['spikeTimeReleaseAll']
                spikeTimeTargetAll = unit['spikeTimeTargetAll']
                spikeTimeBaselineAll = unit['spikeTimeBaselineAll']

                spikeRatePerTrialHoldAll = unit['spikeRatePerTrialHoldAll']
                spikeRatePerTrialReleaseAll = unit['spikeRatePerTrialReleaseAll']
                spikeRatePerTrialTargetAll = unit['spikeRatePerTrialTargetAll']

                spikeTimeHoldRandomAll = unit['spikeTimeHoldRandomAll']
                spikeTimeHoldFixedAll = unit['spikeTimeHoldFixedAll']
                spikeTimeReleaseRandomAll = unit['spikeTimeReleaseRandomAll']
                spikeTimeReleaseFixedAll = unit['spikeTimeReleaseFixedAll']
                spikeTimeTargetRandomAll = unit['spikeTimeTargetRandomAll']
                spikeTimeTargetFixedAll = unit['spikeTimeTargetFixedAll']

                spikeRatePerTrialHoldRandomAll = unit['spikeRatePerTrialHoldRandomAll']
                spikeRatePerTrialHoldFixedAll = unit['spikeRatePerTrialHoldFixedAll']
                spikeRatePerTrialReleaseRandomAll = unit['spikeRatePerTrialReleaseRandomAll']
                spikeRatePerTrialReleaseFixedAll = unit['spikeRatePerTrialReleaseFixedAll']
                spikeRatePerTrialTargetRandomAll = unit['spikeRatePerTrialTargetRandomAll']
                spikeRatePerTrialTargetFixedAll = unit['spikeRatePerTrialTargetFixedAll']

                spikeTimeHoldHit = unit['spikeTimeHoldHit']
                spikeTimeReleaseHit = unit['spikeTimeReleaseHit']
                spikeTimeTargetHit = unit['spikeTimeTargetHit']

                spikeRatePerTrialHoldRandomHit = unit['spikeRatePerTrialHoldRandomHit']
                spikeRatePerTrialHoldFixedHit = unit['spikeRatePerTrialHoldFixedHit']
                spikeRatePerTrialReleaseRandomHit = unit['spikeRatePerTrialReleaseRandomHit']
                spikeRatePerTrialReleaseFixedHit = unit['spikeRatePerTrialReleaseFixedHit']
                spikeRatePerTrialTargetRandomHit = unit['spikeRatePerTrialTargetRandomHit']
                spikeRatePerTrialTargetFixedHit = unit['spikeRatePerTrialTargetFixedHit']

                spikeTimeHoldFa = unit['spikeTimeHoldFa']
                spikeTimeReleaseFa = unit['spikeTimeReleaseFa']
                spikeTimeTargetFa = unit['spikeTimeTargetFa']

                spikeRatePerTrialHoldRandomFa = unit['spikeRatePerTrialHoldRandomFa']
                spikeRatePerTrialHoldFixedFa = unit['spikeRatePerTrialHoldFixedFa']
                spikeRatePerTrialReleaseRandomFa = unit['spikeRatePerTrialReleaseRandomFa']
                spikeRatePerTrialReleaseFixedFa = unit['spikeRatePerTrialReleaseFixedFa']
                spikeRatePerTrialTargetRandomFa = unit['spikeRatePerTrialTargetRandomFa']
                spikeRatePerTrialTargetFixedFa = unit['spikeRatePerTrialTargetFixedFa']

                spikeTimeHoldMiss = unit['spikeTimeHoldMiss']
                spikeTimeReleaseMiss = unit['spikeTimeReleaseMiss']
                spikeTimeTargetMiss = unit['spikeTimeTargetMiss']

                spikeRatePerTrialHoldRandomMiss = unit['spikeRatePerTrialHoldRandomMiss']
                spikeRatePerTrialHoldFixedMiss = unit['spikeRatePerTrialHoldFixedMiss']
                spikeRatePerTrialReleaseRandomMiss = unit['spikeRatePerTrialReleaseRandomMiss']
                spikeRatePerTrialReleaseFixedMiss = unit['spikeRatePerTrialReleaseFixedMiss']
                spikeRatePerTrialTargetRandomMiss = unit['spikeRatePerTrialTargetRandomMiss']
                spikeRatePerTrialTargetFixedMiss = unit['spikeRatePerTrialTargetFixedMiss']

                # Initialization of arrays
                # ALL Trials
                if not ('spikeRatesofTrialsVSUnits_HoldRandomAll' in locals()):
                    lenDim0 = np.shape(spikeRatePerTrialHoldRandomAll)[0]
                    spikeRatesofTrialsVSUnits_HoldRandomAll = np.zeros((lenDim0, lenUnits))
                if not ('spikeRatesofTrialsVSUnits_HoldFixedAll' in locals()):
                    lenDim0 = np.shape(spikeRatePerTrialHoldFixedAll)[0]
                    spikeRatesofTrialsVSUnits_HoldFixedAll = np.zeros((lenDim0, lenUnits))
                if not ('spikeRatesofTrialsVSUnits_ReleaseRandomAll' in locals()):
                    lenDim0 = np.shape(spikeRatePerTrialReleaseRandomAll)[0]
                    spikeRatesofTrialsVSUnits_ReleaseRandomAll = np.zeros((lenDim0, lenUnits))
                if not ('spikeRatesofTrialsVSUnits_ReleaseFixedAll' in locals()):
                    lenDim0 = np.shape(spikeRatePerTrialReleaseFixedAll)[0]
                    spikeRatesofTrialsVSUnits_ReleaseFixedAll = np.zeros((lenDim0, lenUnits))

                if not ('spikeRatesofTrialsVSUnits_BReleaseRandomAll' in locals()):
                    lenDim0 = np.shape(spikeRatePerTrialReleaseRandomAll)[0]
                    spikeRatesofTrialsVSUnits_BReleaseRandomAll = np.zeros((lenDim0, lenUnits))
                if not ('spikeRatesofTrialsVSUnits_BReleaseFixedAll' in locals()):
                    lenDim0 = np.shape(spikeRatePerTrialReleaseFixedAll)[0]
                    spikeRatesofTrialsVSUnits_BReleaseFixedAll = np.zeros((lenDim0, lenUnits))
                if not ('spikeRatesofTrialsVSUnits_AReleaseRandomAll' in locals()):
                    lenDim0 = np.shape(spikeRatePerTrialReleaseRandomAll)[0]
                    spikeRatesofTrialsVSUnits_AReleaseRandomAll = np.zeros((lenDim0, lenUnits))
                if not ('spikeRatesofTrialsVSUnits_AReleaseFixedAll' in locals()):
                    lenDim0 = np.shape(spikeRatePerTrialReleaseFixedAll)[0]
                    spikeRatesofTrialsVSUnits_AReleaseFixedAll = np.zeros((lenDim0, lenUnits))

                if not ('spikeRatesofTrialsVSUnits_TargetRandomAll' in locals()):
                    lenDim0 = np.shape(spikeRatePerTrialTargetRandomAll)[0]
                    spikeRatesofTrialsVSUnits_TargetRandomAll = np.zeros((lenDim0, lenUnits))
                if not ('spikeRatesofTrialsVSUnits_TargetFixedAll' in locals()):
                    lenDim0 = np.shape(spikeRatePerTrialTargetFixedAll)[0]
                    spikeRatesofTrialsVSUnits_TargetFixedAll = np.zeros((lenDim0, lenUnits))

                spikeRatesofTrialsVSUnits_HoldRandomAll[:, indUnit] = spikeRatePerTrialHoldRandomAll.T
                spikeRatesofTrialsVSUnits_HoldFixedAll[:, indUnit] = spikeRatePerTrialHoldFixedAll.T
                spikeRatesofTrialsVSUnits_ReleaseRandomAll[:, indUnit] = spikeRatePerTrialReleaseRandomAll.T
                spikeRatesofTrialsVSUnits_ReleaseFixedAll[:, indUnit] = spikeRatePerTrialReleaseFixedAll.T

                spikeRatePerTrialBReleaseRandomAll = np.zeros((1, len(spikeTimeReleaseRandomAll)))
                spikeRatePerTrialAReleaseRandomAll = np.zeros((1, len(spikeTimeReleaseRandomAll)))
                for ind in range(len(spikeTimeReleaseRandomAll)):
                    spikeRatePerTrialBReleaseRandomAll[0,ind] = (spikeTimeReleaseRandomAll[ind][0]<0).sum()/globals.PRE_TIME_RELEASE
                    spikeRatePerTrialAReleaseRandomAll[0,ind] = (spikeTimeReleaseRandomAll[ind][0] >= 0).sum()/globals.POST_TIME_RELEASE

                spikeRatePerTrialBReleaseFixedAll = np.zeros((1, len(spikeTimeReleaseFixedAll)))
                spikeRatePerTrialAReleaseFixedAll = np.zeros((1, len(spikeTimeReleaseFixedAll)))
                for ind in range(len(spikeTimeReleaseFixedAll)):
                    spikeRatePerTrialBReleaseFixedAll[0, ind] = (spikeTimeReleaseFixedAll[ind][0] < 0).sum() / globals.PRE_TIME_RELEASE
                    spikeRatePerTrialAReleaseFixedAll[0, ind] = (spikeTimeReleaseFixedAll[ind][0] >= 0).sum() / globals.POST_TIME_RELEASE

                # To get only preSpikeRate and postSpikeRate for prediction in multinomial logistic regression
                spikeRatesofTrialsVSUnits_BReleaseRandomAll[:, indUnit] = spikeRatePerTrialBReleaseRandomAll
                spikeRatesofTrialsVSUnits_AReleaseRandomAll[:, indUnit] = spikeRatePerTrialAReleaseRandomAll

                spikeRatesofTrialsVSUnits_BReleaseFixedAll[:, indUnit] = spikeRatePerTrialBReleaseFixedAll
                spikeRatesofTrialsVSUnits_AReleaseFixedAll[:, indUnit] = spikeRatePerTrialAReleaseFixedAll

                spikeRatesofTrialsVSUnits_TargetRandomAll[:, indUnit] = spikeRatePerTrialTargetRandomAll.T
                spikeRatesofTrialsVSUnits_TargetFixedAll[:, indUnit] = spikeRatePerTrialTargetFixedAll.T

                # HIT Trials
                if not('spikeRatesofTrialsVSUnits_HoldRandomHit' in locals()):
                    lenDim0 = np.shape(spikeRatePerTrialHoldRandomHit)[0]
                    spikeRatesofTrialsVSUnits_HoldRandomHit = np.zeros((lenDim0, lenUnits))
                if not('spikeRatesofTrialsVSUnits_HoldFixedHit' in locals()):
                    lenDim0 = np.shape(spikeRatePerTrialHoldFixedHit)[0]
                    spikeRatesofTrialsVSUnits_HoldFixedHit = np.zeros((lenDim0, lenUnits))
                if not('spikeRatesofTrialsVSUnits_ReleaseRandomHit' in locals()):
                    lenDim0 = np.shape(spikeRatePerTrialReleaseRandomHit)[0]
                    spikeRatesofTrialsVSUnits_ReleaseRandomHit = np.zeros((lenDim0, lenUnits))
                if not('spikeRatesofTrialsVSUnits_ReleaseFixedHit' in locals()):
                    lenDim0 = np.shape(spikeRatePerTrialReleaseFixedHit)[0]
                    spikeRatesofTrialsVSUnits_ReleaseFixedHit = np.zeros((lenDim0, lenUnits))
                if not('spikeRatesofTrialsVSUnits_TargetRandomHit' in locals()):
                    lenDim0 = np.shape(spikeRatePerTrialTargetRandomHit)[0]
                    spikeRatesofTrialsVSUnits_TargetRandomHit = np.zeros((lenDim0, lenUnits))
                if not('spikeRatesofTrialsVSUnits_TargetFixedHit' in locals()):
                    lenDim0 = np.shape(spikeRatePerTrialTargetFixedHit)[0]
                    spikeRatesofTrialsVSUnits_TargetFixedHit = np.zeros((lenDim0, lenUnits))

                spikeRatesofTrialsVSUnits_HoldRandomHit[:, indUnit] = spikeRatePerTrialHoldRandomHit.T
                spikeRatesofTrialsVSUnits_HoldFixedHit[:, indUnit] = spikeRatePerTrialHoldFixedHit.T
                spikeRatesofTrialsVSUnits_ReleaseRandomHit[:, indUnit] = spikeRatePerTrialReleaseRandomHit.T
                spikeRatesofTrialsVSUnits_ReleaseFixedHit[:, indUnit] = spikeRatePerTrialReleaseFixedHit.T
                spikeRatesofTrialsVSUnits_TargetRandomHit[:, indUnit] = spikeRatePerTrialTargetRandomHit.T
                spikeRatesofTrialsVSUnits_TargetFixedHit[:, indUnit] = spikeRatePerTrialTargetFixedHit.T

                # FA Trials
                if not('spikeRatesofTrialsVSUnits_HoldRandomFa' in locals()):
                    lenDim0 = np.shape(spikeRatePerTrialHoldRandomFa)[0]
                    spikeRatesofTrialsVSUnits_HoldRandomFa = np.zeros((lenDim0, lenUnits))
                if not('spikeRatesofTrialsVSUnits_HoldFixedFa' in locals()):
                    lenDim0 = np.shape(spikeRatePerTrialHoldFixedFa)[0]
                    spikeRatesofTrialsVSUnits_HoldFixedFa = np.zeros((lenDim0, lenUnits))
                if not('spikeRatesofTrialsVSUnits_ReleaseRandomFa' in locals()):
                    lenDim0 = np.shape(spikeRatePerTrialReleaseRandomFa)[0]
                    spikeRatesofTrialsVSUnits_ReleaseRandomFa = np.zeros((lenDim0, lenUnits))
                if not('spikeRatesofTrialsVSUnits_ReleaseFixedFa' in locals()):
                    lenDim0 = np.shape(spikeRatePerTrialReleaseFixedFa)[0]
                    spikeRatesofTrialsVSUnits_ReleaseFixedFa = np.zeros((lenDim0, lenUnits))
                if not('spikeRatesofTrialsVSUnits_TargetRandomFa' in locals()):
                    lenDim0 = np.shape(spikeRatePerTrialTargetRandomFa)[0]
                    spikeRatesofTrialsVSUnits_TargetRandomFa = np.zeros((lenDim0, lenUnits))
                if not('spikeRatesofTrialsVSUnits_TargetFixedFa' in locals()):
                    lenDim0 = np.shape(spikeRatePerTrialTargetFixedFa)[0]
                    spikeRatesofTrialsVSUnits_TargetFixedFa = np.zeros((lenDim0, lenUnits))

                spikeRatesofTrialsVSUnits_HoldRandomFa[:, indUnit] = spikeRatePerTrialHoldRandomFa.T
                spikeRatesofTrialsVSUnits_HoldFixedFa[:, indUnit] = spikeRatePerTrialHoldFixedFa.T
                spikeRatesofTrialsVSUnits_ReleaseRandomFa[:, indUnit] = spikeRatePerTrialReleaseRandomFa.T
                spikeRatesofTrialsVSUnits_ReleaseFixedFa[:, indUnit] = spikeRatePerTrialReleaseFixedFa.T
                spikeRatesofTrialsVSUnits_TargetRandomFa[:, indUnit] = spikeRatePerTrialTargetRandomFa.T
                spikeRatesofTrialsVSUnits_TargetFixedFa[:, indUnit] = spikeRatePerTrialTargetFixedFa.T

                # MISS Trials
                if not('spikeRatesofTrialsVSUnits_HoldRandomMiss' in locals()):
                    lenDim0 = np.shape(spikeRatePerTrialHoldRandomMiss)[0]
                    spikeRatesofTrialsVSUnits_HoldRandomMiss = np.zeros((lenDim0, lenUnits))
                if not('spikeRatesofTrialsVSUnits_HoldFixedMiss' in locals()):
                    lenDim0 = np.shape(spikeRatePerTrialHoldFixedMiss)[0]
                    spikeRatesofTrialsVSUnits_HoldFixedMiss = np.zeros((lenDim0, lenUnits))
                if not('spikeRatesofTrialsVSUnits_ReleaseRandomMiss' in locals()):
                    lenDim0 = np.shape(spikeRatePerTrialReleaseRandomMiss)[0]
                    spikeRatesofTrialsVSUnits_ReleaseRandomMiss = np.zeros((lenDim0, lenUnits))
                if not('spikeRatesofTrialsVSUnits_ReleaseFixedMiss' in locals()):
                    lenDim0 = np.shape(spikeRatePerTrialReleaseFixedMiss)[0]
                    spikeRatesofTrialsVSUnits_ReleaseFixedMiss = np.zeros((lenDim0, lenUnits))
                if not('spikeRatesofTrialsVSUnits_TargetRandomMiss' in locals()):
                    lenDim0 = np.shape(spikeRatePerTrialTargetRandomMiss)[0]
                    spikeRatesofTrialsVSUnits_TargetRandomMiss = np.zeros((lenDim0, lenUnits))
                if not('spikeRatesofTrialsVSUnits_TargetFixedMiss' in locals()):
                    lenDim0 = np.shape(spikeRatePerTrialTargetFixedMiss)[0]
                    spikeRatesofTrialsVSUnits_TargetFixedMiss = np.zeros((lenDim0, lenUnits))

                spikeRatesofTrialsVSUnits_HoldRandomMiss[:, indUnit] = spikeRatePerTrialHoldRandomMiss.T
                spikeRatesofTrialsVSUnits_HoldFixedMiss[:, indUnit] = spikeRatePerTrialHoldFixedMiss.T
                spikeRatesofTrialsVSUnits_ReleaseRandomMiss[:, indUnit] = spikeRatePerTrialReleaseRandomMiss.T
                spikeRatesofTrialsVSUnits_ReleaseFixedMiss[:, indUnit] = spikeRatePerTrialReleaseFixedMiss.T
                spikeRatesofTrialsVSUnits_TargetRandomMiss[:, indUnit] = spikeRatePerTrialTargetRandomMiss.T
                spikeRatesofTrialsVSUnits_TargetFixedMiss[:, indUnit] = spikeRatePerTrialTargetFixedMiss.T

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
                #unitSpikeRatesTargetRandomFa[indUnit, :] = spikeRatesTargetRandomHFM[1, :] # No Target on Fa trials
                unitSpikeRatesTargetRandomMiss[indUnit, :] = spikeRatesTargetRandomHFM[1, :]

                unitSpikeRatesTargetFixedAll[indUnit, :] = spikeRatesTargetFixedAll
                unitSpikeRatesTargetFixedHit[indUnit, :] = spikeRatesTargetFixedHFM[0, :]
                #unitSpikeRatesTargetFixedFa[indUnit, :] = spikeRatesTargetFixedHFM[1, :] # No Target on Fa trials
                unitSpikeRatesTargetFixedMiss[indUnit, :] = spikeRatesTargetFixedHFM[1, :]

                unitResponseTypeHoldFixedAll[indUnit] = unit['responseTypeHoldFixedAll'][0,0]
                unitResponseTypeHoldFixedHit[indUnit] = unit['responseTypeHoldFixedHFM'][0,0]
                unitResponseTypeHoldFixedFa[indUnit] = unit['responseTypeHoldFixedHFM'][0,1]
                unitResponseTypeHoldFixedMiss[indUnit] = unit['responseTypeHoldFixedHFM'][0,2]
                unitResponseTypeReleaseFixedAll[indUnit] = unit['responseTypeReleaseFixedAll'][0,0]
                unitResponseTypeReleaseFixedHit[indUnit] = unit['responseTypeReleaseFixedHFM'][0,0]
                unitResponseTypeReleaseFixedFa[indUnit] = unit['responseTypeReleaseFixedHFM'][0,1]
                unitResponseTypeReleaseFixedMiss[indUnit] = unit['responseTypeReleaseFixedHFM'][0,2]
                unitResponseTypeTargetFixedAll[indUnit] = unit['responseTypeTargetFixedAll'][0,0]
                unitResponseTypeTargetFixedHit[indUnit] = unit['responseTypeTargetFixedHFM'][0,0]
                unitResponseTypeTargetFixedMiss[indUnit] = unit['responseTypeTargetFixedHFM'][0,1]
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

            allUnitsResponseTypeHoldFixedAll.append(unitResponseTypeHoldFixedAll)
            allUnitsResponseTypeHoldFixedHit.append(unitResponseTypeHoldFixedHit)
            allUnitsResponseTypeHoldFixedFa.append(unitResponseTypeHoldFixedFa)
            allUnitsResponseTypeHoldFixedMiss.append(unitResponseTypeHoldFixedMiss)
            allUnitsResponseTypeReleaseFixedAll.append(unitResponseTypeReleaseFixedAll)
            allUnitsResponseTypeReleaseFixedHit.append(unitResponseTypeReleaseFixedHit)
            allUnitsResponseTypeReleaseFixedFa.append(unitResponseTypeReleaseFixedFa)
            allUnitsResponseTypeReleaseFixedMiss.append(unitResponseTypeReleaseFixedMiss)
            allUnitsResponseTypeTargetFixedAll.append(unitResponseTypeTargetFixedAll)
            allUnitsResponseTypeTargetFixedHit.append(unitResponseTypeTargetFixedHit)
            allUnitsResponseTypeTargetFixedMiss.append(unitResponseTypeTargetFixedMiss)

            # decrement indices by 1 because of the difference between Matlab and Python
            # these variables coming from Matlab and indices start with 1 in Matlab
            fixedHoldStartsAtTrial = fixedHoldStartsAtTrial-1
            allTrials = allTrials-1
            arrHitTrials = arrHitTrials-1
            arrFaTrials = arrFaTrials -1
            arrMissTrials = arrMissTrials-1

            listReactTimesRandomAll.append(arrReactTimes[:fixedHoldStartsAtTrial])
            hitIndices = arrHitTrials[arrHitTrials < fixedHoldStartsAtTrial]
            listReactTimesRandomHit.append(arrReactTimes[hitIndices])
            faIndices = arrFaTrials[arrFaTrials < fixedHoldStartsAtTrial]
            listReactTimesRandomFa.append(arrReactTimes[faIndices])
            missIndices = arrMissTrials[arrMissTrials < fixedHoldStartsAtTrial]
            listReactTimesRandomMiss.append(arrReactTimes[missIndices])

            listReactTimesFixedAll.append(arrReactTimes[fixedHoldStartsAtTrial:])
            hitIndices = arrHitTrials[arrHitTrials >= fixedHoldStartsAtTrial]
            listReactTimesFixedHit.append(arrReactTimes[hitIndices])
            faIndices = arrFaTrials[arrFaTrials >= fixedHoldStartsAtTrial]
            listReactTimesFixedFa.append(arrReactTimes[faIndices])
            missIndices = arrMissTrials[arrMissTrials >= fixedHoldStartsAtTrial]
            listReactTimesFixedMiss.append(arrReactTimes[missIndices])

            # arrReactTimesRandomAll = arrReactTimes[:fixedHoldStartsAtTrial-1]
            # hitIndices = arrHitTrials[arrHitTrials < fixedHoldStartsAtTrial]-1
            # arrReactTimesRandomHit = arrReactTimes[hitIndices]
            # faIndices = arrFaTrials[arrFaTrials < fixedHoldStartsAtTrial]-1
            # arrReactTimesRandomFa = arrReactTimes[faIndices]
            # missIndices = arrMissTrials[arrMissTrials<fixedHoldStartsAtTrial]-1
            # arrReactTimesRandomMiss = arrReactTimes[missIndices]
            #
            # arrReactTimesFixedAll = arrReactTimes[fixedHoldStartsAtTrial-1:]
            # hitIndices = arrHitTrials[arrHitTrials>=fixedHoldStartsAtTrial]-1
            # arrReactTimesFixedHit = arrReactTimes[hitIndices]
            # faIndices = arrFaTrials[arrFaTrials>=fixedHoldStartsAtTrial]-1
            # arrReactTimesFixedFa = arrReactTimes[faIndices]
            # missIndices = arrMissTrials[arrMissTrials>=fixedHoldStartsAtTrial]-1
            # arrReactTimesFixedMiss = arrReactTimes[missIndices]


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

    arrAllUnitsResponseTypeHoldFixedAll, arrAllUnitsResponseTypeHoldFixedHit, arrAllUnitsResponseTypeHoldFixedFa, arrAllUnitsResponseTypeHoldFixedMiss = \
        concatAllHFM(allUnitsResponseTypeHoldFixedAll, allUnitsResponseTypeHoldFixedHit, allUnitsResponseTypeHoldFixedFa, allUnitsResponseTypeHoldFixedMiss)
    arrAllUnitsResponseTypeReleaseFixedAll, arrAllUnitsResponseTypeReleaseFixedHit, arrAllUnitsResponseTypeReleaseFixedFa, arrAllUnitsResponseTypeReleaseFixedMiss = \
        concatAllHFM(allUnitsResponseTypeReleaseFixedAll, allUnitsResponseTypeReleaseFixedHit, allUnitsResponseTypeReleaseFixedFa, allUnitsResponseTypeReleaseFixedMiss)
    arrAllUnitsResponseTypeTargetFixedAll, arrAllUnitsResponseTypeTargetFixedHit, _, arrAllUnitsResponseTypeTargetFixedMiss = \
        concatAllHFM(allUnitsResponseTypeTargetFixedAll, allUnitsResponseTypeTargetFixedHit, [], allUnitsResponseTypeTargetFixedMiss)


    arrUnitNeuronType = np.concatenate(unitNeuronType, axis=0)

    arrReactTimesRandomAll, arrReactTimesRandomHit, arrReactTimesRandomFa, arrReactTimesRandomMiss = \
        concatAllHFM(listReactTimesRandomAll, listReactTimesRandomHit, listReactTimesRandomFa, listReactTimesRandomMiss)
    arrReactTimesFixedAll, arrReactTimesFixedHit, arrReactTimesFixedFa, arrReactTimesFixedMiss = \
        concatAllHFM(listReactTimesFixedAll, listReactTimesFixedHit, listReactTimesFixedFa, listReactTimesFixedMiss)

    return allTrials, arrHitTrials, arrFaTrials, arrMissTrials, fixedHoldStartsAtTrial, \
           arrAllUnitsSpikeRatesHoldRandomAll, arrAllUnitsSpikeRatesHoldRandomHit, arrAllUnitsSpikeRatesHoldRandomFa, arrAllUnitsSpikeRatesHoldRandomMiss,\
           arrAllUnitsSpikeRatesHoldFixedAll, arrAllUnitsSpikeRatesHoldFixedHit, arrAllUnitsSpikeRatesHoldFixedFa, arrAllUnitsSpikeRatesHoldFixedMiss, \
           arrAllUnitsSpikeRatesReleaseRandomAll, arrAllUnitsSpikeRatesReleaseRandomHit, arrAllUnitsSpikeRatesReleaseRandomFa, arrAllUnitsSpikeRatesReleaseRandomMiss, \
           arrAllUnitsSpikeRatesReleaseFixedAll, arrAllUnitsSpikeRatesReleaseFixedHit, arrAllUnitsSpikeRatesReleaseFixedFa, arrAllUnitsSpikeRatesReleaseFixedMiss, \
           arrAllUnitsSpikeRatesTargetRandomAll, arrAllUnitsSpikeRatesTargetRandomHit, arrAllUnitsSpikeRatesTargetRandomFa, arrAllUnitsSpikeRatesTargetRandomMiss, \
           arrAllUnitsSpikeRatesTargetFixedAll, arrAllUnitsSpikeRatesTargetFixedHit, arrAllUnitsSpikeRatesTargetFixedFa, arrAllUnitsSpikeRatesTargetFixedMiss, \
           arrAllUnitsResponseTypeHoldFixedAll, arrAllUnitsResponseTypeHoldFixedHit, arrAllUnitsResponseTypeHoldFixedFa, arrAllUnitsResponseTypeHoldFixedMiss, \
           arrAllUnitsResponseTypeReleaseFixedAll, arrAllUnitsResponseTypeReleaseFixedHit, arrAllUnitsResponseTypeReleaseFixedFa, arrAllUnitsResponseTypeReleaseFixedMiss, \
           arrAllUnitsResponseTypeTargetFixedAll, arrAllUnitsResponseTypeTargetFixedHit, arrAllUnitsResponseTypeTargetFixedMiss, \
           arrUnitNeuronType, \
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
           arrReactTimesFixedAll, arrReactTimesFixedHit, arrReactTimesFixedFa, arrReactTimesFixedMiss

# gets lists as inputs
# returns concatenated numpy arrays
def concatAllHFM(all, hit, fa, miss):
    npAll = np.concatenate(all, axis=0)
    npHit = np.concatenate(hit, axis=0)
    if fa:
        npFa = np.concatenate(fa, axis=0)
    else:
        npFa = np.zeros((1,1))
    npMiss = np.concatenate(miss, axis=0)
    return npAll, npHit, npFa, npMiss

