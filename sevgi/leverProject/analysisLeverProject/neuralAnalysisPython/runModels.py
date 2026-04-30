import numpy as np
import pandas as pd
from matplotlib import pyplot as plt
from sklearn import preprocessing
from sklearn.feature_selection import RFE
from sklearn.linear_model import LinearRegression, LassoCV
from sklearn.preprocessing import PolynomialFeatures
from sklearn.model_selection import train_test_split, RepeatedKFold, cross_val_score, cross_validate, RepeatedStratifiedKFold, cross_val_predict, GridSearchCV
from sklearn.metrics import mean_absolute_error, mean_squared_error, r2_score
import seaborn as sns
from sklearn.linear_model import TweedieRegressor
from sklearn.svm import SVR
from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import Lasso
from sklearn.linear_model import LogisticRegression

import globals
import plotModule


def gridSearchNumOfFeatures(X,y, neuronTypeY, sText):
    # step-1: create a cross-validation scheme
    cv = RepeatedStratifiedKFold(n_splits=4, n_repeats=3, random_state=1)
    # step-2: specify range of hyperparameters to tune
    hyper_params = [{'n_features_to_select': list(range(1, 12))}] #  X.shape[1]+1

    # step-3: perform grid search
    # 3.1 specify model
    lm = LinearRegression()
    lm.fit(X, y)
    rfe = RFE(lm)

    # 3.2 call GridSearchCV()
    model_cv = GridSearchCV(estimator=rfe,
                            param_grid=hyper_params,
                            scoring='r2',
                            cv=cv,
                            verbose=1,
                            return_train_score=True)

    # fit the model
    model_cv.fit(X, y)
    # cv results
    cv_results = pd.DataFrame(model_cv.cv_results_)

    # plotting cv results
    plt.figure(figsize=(16, 6))

    plt.plot(cv_results["param_n_features_to_select"], cv_results["mean_test_score"])
    plt.plot(cv_results["param_n_features_to_select"], cv_results["mean_train_score"])
    plt.xlabel('number of features')
    plt.ylabel('r-squared')
    plt.title(sText + ' -- Optimal Number of Features')
    plt.legend(['test score', 'train score'], loc='upper left')
    plt.show()
    a=0

# https://www.machinelearningnuggets.com/python-linear-regression/
# The main goal of regression analysis is to isolate the relationship between each independent variable and the dependent variable.
# We interpret regression coefficients as the mean change in the dependent variable for each 1 unit change in an independent variable when all other independent variables are constant.
# So if we cannot change the value of a given predictor variable without changing another predictor variable, then there is a problem caused by high collinearity.
# The most common way to detect multicollinearity is by using the variance inflation factor (VIF), which measures the correlation and strength of correlation between the predictor variables in a regression model.
# Y = β0 + β1X1 + β2X2 + … + βpXp + ε
# βj: The average effect on Y of a one unit increase in Xj, holding all other predictors fixed.
def runLinearRegression(X,y, neuronType, sText): # X = feature matrix, y = response vector

    print('X.shape:',X.shape)
    # SPLITTING THE DATA

    cv = RepeatedStratifiedKFold(n_splits=4, n_repeats=3, random_state=1)
    clf = make_pipeline(preprocessing.StandardScaler(), LinearRegression())  # StandardScaler scales the data set into mean=0 std=1
    n_scores = cross_val_score(clf, X, y, scoring='r2', cv=cv, n_jobs=-1)
    print(sText, ' Mean R2: %.3f (%.3f)' % (np.mean(n_scores), np.std(n_scores)))

    n_scores = cross_val_score(clf, X, y, scoring='neg_mean_squared_error', cv=cv, n_jobs=-1)
    print(sText, ' Mean neg_mean_squared_error: %.3f (%.3f)' % (np.mean(n_scores), np.std(n_scores)))

    # aa = np.column_stack((neuronTypeY, model.coef_))
    # inds = aa[:, 1].astype(float).argsort()
    # sorted = aa[inds,:]
    #print(f"coefficients: {sorted[:,1]}")
    q=0

    for indNeuronType in range(0,len(globals.NEURON_TYPES)):
        inds = np.where(neuronType == globals.NEURON_TYPES[indNeuronType])[0]
        if len(inds)>0:
            X_neuronSubset = X[:, inds]
            cv = RepeatedStratifiedKFold(n_splits=4, n_repeats=3, random_state=1)
            clf = make_pipeline(preprocessing.StandardScaler(), LinearRegression())  # StandardScaler scales the data set into mean=0 std=1
            n_scores = cross_val_score(clf, X_neuronSubset, y, scoring='r2', cv=cv, n_jobs=-1)
            print(sText, ' (', globals.NEURON_TYPES[indNeuronType], ') Mean R2: %.3f (%.3f)' % (np.mean(n_scores), np.std(n_scores)))
    a=0

def runGLM(X,y, neuronTypeY, sText): # Generalized Linear Model with a Tweedie distribution.
    reg = TweedieRegressor(power=1, alpha=0.5, link='log')
    reg.fit(X,y)
    sc = reg.score(X,y) # Compute D^2, the percentage of deviance explained. D^2 is a generalization of the coefficient of determination R^2. R^2 uses squared error and D^2 uses the deviance of this GLM
    print('Tweedie Regressor for', sText, ' score:', sc)

def runLogisticRegression(X,y):
    model = LogisticRegression(multi_class='multinomial', solver='lbfgs', penalty='l2', C=1.0, max_iter=1000)
    cv = RepeatedStratifiedKFold(n_splits=4, n_repeats=3, random_state=1)
    pipeline = make_pipeline(preprocessing.StandardScaler(), model)  # StandardScaler scales the data set into mean=0 std=1
    # n_scores = cross_val_score(pipeline, X, y, scoring='accuracy', cv=cv, n_jobs=-1)
    output = cross_validate(pipeline, X, y, cv=cv, n_jobs=-1,
                            scoring='accuracy',  # ('accuracy', 'f1', 'roc_auc'),
                            return_estimator=True,
                            return_train_score=True)
    hitRateCoeffs = []
    faRateCoeffs = []
    missRateCoeffs = []
    outcomes = np.unique(y)
    for ind in range(len(output['estimator'])):
        fitted_logreg = output['estimator'][ind].named_steps['logisticregression']
        hitRateCoeffs.append([fitted_logreg.coef_[0, :]])
        if fitted_logreg.coef_.shape[0]>1: # if outcome(y) has only 2 types, this array has only 1 row
            faRateCoeffs.append([fitted_logreg.coef_[1, :]])    # if outcome(y) has 3 types, this array has only 2 rows
            missRateCoeffs.append([fitted_logreg.coef_[2, :]])

    logOddsMeanHit = np.mean(np.concatenate(hitRateCoeffs), axis=0)
    # probMeanHit = np.exp(logOddsMeanHit) / (1 + np.exp(logOddsMeanHit))

    if faRateCoeffs:
        logOddsMeanFa = np.mean(np.concatenate(faRateCoeffs), axis=0)
        # probMeanFa = np.exp(logOddsMeanFa) / (1 + np.exp(logOddsMeanFa))
    if missRateCoeffs:
        logOddsMeanMiss = np.mean(np.concatenate(missRateCoeffs), axis=0)
        # probMeanMiss = np.exp(logOddsMeanMiss) / (1 + np.exp(logOddsMeanMiss))

    if not faRateCoeffs and globals.FA_OUTCOME in outcomes and globals.MISS_OUTCOME not in outcomes: # if faRateCoeffs is empty and there are FA in outcomes, probMeanFa should be reciprocal of probMeanHit
        # probMeanFa = 1-probMeanHit
        # probMeanMiss = np.zeros(probMeanHit.shape)
        logOddsMeanFa = -logOddsMeanHit
        logOddsMeanMiss = np.zeros(logOddsMeanHit.shape)
    elif not missRateCoeffs and globals.FA_OUTCOME not in outcomes and globals.MISS_OUTCOME in outcomes:# if missRateCoeffs is empty and there are MISS in outcomes, probMeanMiss should be reciprocal of probMeanHit
        # probMeanMiss = 1 - probMeanHit
        # probMeanFa = np.zeros(probMeanHit.shape)
        logOddsMeanFa = np.zeros(logOddsMeanHit.shape)
        logOddsMeanMiss = -logOddsMeanHit
    acc = output['test_score']

    return logOddsMeanHit, logOddsMeanFa, logOddsMeanMiss, acc

def runLogisticRegressionAndPlot(X_Random, yRandom, X_Fixed, yFixed, neuronType):
                #(X, y, neuronType, sTitle, subTitle):
    logitHitRandom, logitFaRandom, logitMissRandom, accRandom = runLogisticRegression(X_Random, yRandom)
    logitHitFixed, logitFaFixed, logitMissFixed, accFixed = runLogisticRegression(X_Fixed, yFixed)
    # plotModule.plotDensity([probMeanHit, probMeanFa, probMeanMiss], ['Hit', 'Fa', 'Miss'], sTitle + '' + subTitle + ' with acc=%.2f' % np.mean(acc), sTitle + '_' + subTitle)
    if len(neuronType)>0:
        for indNeuronType in range(0, len(globals.NEURON_TYPES)):
            inds = np.where(neuronType == globals.NEURON_TYPES[indNeuronType])[0]
            if len(inds) > 0:
                logitHitRandomSpec = logitHitRandom[inds]
                logitFaRandomSpec = logitFaRandom[inds]
                logitMissRandomSpec = logitMissRandom[inds]

                logitHitFixedSpec = logitHitFixed[inds]
                logitFaFixedSpec = logitFaFixed[inds]
                logitMissFixedSpec = logitMissFixed[inds]

                plotModule.plotDensity([logitHitRandomSpec, logitFaRandomSpec, logitMissRandomSpec], [logitHitFixedSpec, logitFaFixedSpec, logitMissFixedSpec],
                                       ['Reaction', 'Prediction'], ['Hit', 'Fa', 'Miss'],
                                       'Acc cue react=%.2f' % np.mean(accRandom) + ' vs cue pred=%.2f' % np.mean(accFixed), globals.NEURON_TYPES[indNeuronType])


def runLogisticRegressionWNeuronTypes(X,y,flagMultiNomial, neuronType, sTitle):

    # if not flagMultiNomial:
    #     model = LogisticRegression(penalty='none', solver='lbfgs', max_iter=1000)
    # else:
        # define the multinomial logistic regression model
    print(sTitle, ' Running for all cells:')
    runLogisticRegressionAndPlot(X, y, neuronType, sTitle, 'Allcells')
    # probMeanHit, probMeanFa, probMeanMiss, acc = runLogisticRegression(X, y)
    # plotModule.plotDensity([probMeanHit, probMeanFa, probMeanMiss], ['Hit','Fa','Miss'], sTitle + ' All cells with acc=%.2f' % np.mean(acc), sTitle +'_AllCells')
    # for indNeuronType in range(0, len(globals.NEURON_TYPES)):
    #     inds = np.where(neuronType == globals.NEURON_TYPES[indNeuronType])[0]
    #     if len(inds) > 0:
    #         probMeanHitSpec = probMeanHit[inds]
    #         probMeanFaSpec = probMeanFa[inds]
    #         probMeanMissSpec = probMeanMiss[inds]
    #         plotModule.plotDensity([probMeanHitSpec, probMeanFaSpec, probMeanMissSpec], ['Hit', 'Fa', 'Miss'], globals.NEURON_TYPES[indNeuronType] + ' coeffs in All cells with acc=%.2f' % np.mean(acc), 'CoeffDensity_' + globals.NEURON_TYPES[indNeuronType])


    # # run the model with only expert labelled cell types
    # inds = np.where(neuronType != globals.NEURON_TYPE_UNKNOWN)[0]
    # if len(inds)>0:
    #     X_neuronSubset = X[:, inds]
    #     neuronTypeSubset = neuronType[inds]
    #     print(sTitle, ' Running for only expert labelled cells:')
    #     runLogisticRegressionAndPlot(X_neuronSubset, y, neuronTypeSubset, sTitle, 'ExpertLabelled')
    #     # probMeanHitKnown, probMeanFaKnown, probMeanMissKnown, acc = runLogisticRegression(X_neuronSubset, y)
    #     # plotModule.plotDensity([probMeanHitKnown, probMeanFaKnown, probMeanMissKnown], ['Hit', 'Fa', 'Miss'], 'Expert labelled cells with acc=%.2f' % np.mean(acc), 'CoeffDensity_ExpertLabelledCells')
    #     # print(sTitle, ' (Expert_Labelled cells) Mean Accuracy: %.3f (%.3f)' % (np.mean(acc), np.std(acc)))
    #     # for indNeuronType in range(0, len(globals.NEURON_TYPES)):
    #     #     inds = np.where(neuronTypeSubset == globals.NEURON_TYPES[indNeuronType])[0]
    #     #     if len(inds) > 0:
    #     #         probMeanHitSpec = probMeanHitKnown[inds]
    #     #         probMeanFaSpec = probMeanFaKnown[inds]
    #     #         probMeanMissSpec = probMeanMissKnown[inds]
    #     #         plotModule.plotDensity([probMeanHitSpec, probMeanFaSpec, probMeanMissSpec], ['Hit', 'Fa', 'Miss'], globals.NEURON_TYPES[indNeuronType] + ' coeffs in Expert-labelled cells with acc=%.2f' % np.mean(acc), 'CoeffDensity_ExpertLabelled_' + globals.NEURON_TYPES[indNeuronType])
    #
    # # run the model with only one type of cells at a time
    # for indNeuronType in range(0,len(globals.NEURON_TYPES)):
    #     inds = np.where(neuronType == globals.NEURON_TYPES[indNeuronType])[0]
    #     if len(inds)>0:
    #         X_neuronSubset = X[:, inds]
    #         print(sTitle, ' Running for only ', globals.NEURON_TYPES[indNeuronType], ' cells:')
    #         runLogisticRegressionAndPlot(X_neuronSubset, y, [], sTitle, 'Only_' + globals.NEURON_TYPES[indNeuronType])
    #         # probMeanHit, probMeanFa, probMeanMiss, acc = runLogisticRegression(X_neuronSubset, y)
    #         # plotModule.plotDensity([probMeanHit, probMeanFa, probMeanMiss], ['Hit', 'Fa', 'Miss'], 'Only ' + globals.NEURON_TYPES[indNeuronType] + ' cells with acc=%.2f' % np.mean(acc), 'CoeffDensity_Only_' + globals.NEURON_TYPES[indNeuronType])
    #         # print(sTitle, ' (', globals.NEURON_TYPES[indNeuronType], ') Mean Accuracy: %.3f (%.3f)' % (np.mean(acc), np.std(acc)))

def runLasso(X,y,neuronTypeY,sText, fileName):
    # define model evaluation method
    cv = RepeatedKFold(n_splits=10, n_repeats=3, random_state=1)

    # # define model
    # model = Lasso(alpha=1.0)
    # # evaluate model
    # scores = cross_val_score(model, X, y, scoring='r2', cv=cv, n_jobs=-1) # neg_mean_absolute_error
    # # force scores to be positive
    # scores = np.absolute(scores)
    # print('Lasso Regression ', sText, ' Mean RMSE: %.3f (%.3f)' % (np.mean(scores), np.std(scores)))

    # define model
    model = LassoCV(alphas=np.arange(0, 1, 0.01), cv=cv, n_jobs=-1)
    # fit model
    model.fit(X, y)
    # summarize chosen configuration
    print('alpha: %f' % model.alpha_)

    # Set best alpha
    lasso_best = Lasso(alpha=model.alpha_)

    # scores = cross_val_score(lasso_best, X, y, scoring='r2', cv=cv, n_jobs=-1)  # neg_mean_absolute_error
    # scores = np.absolute(scores)
    # print('Lasso Regression ', sText, ' Mean RMSE: %.3f (%.3f)' % (np.mean(scores), np.std(scores)))
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3, random_state=10)
    lasso_best.fit(X_train, y_train)
    coeffVsNeuronType = list(zip(lasso_best.coef_, neuronTypeY))
    print(coeffVsNeuronType)
    print('Lasso Regression ', sText, ' R squared training set', round(lasso_best.score(X_train, y_train) * 100, 2))
    print('Lasso Regression ', sText, ' R squared test set', round(lasso_best.score(X_test, y_test) * 100, 2))

    y_val = np.array([[x[0] for x in coeffVsNeuronType]])
    x_val = np.array([[x[1] for x in coeffVsNeuronType]])

    zeroedValues = y_val[y_val==0]
    zeroedNeuronTypes = x_val[y_val == 0]

    survivedValues = y_val[y_val != 0]
    survivedNeuronTypes = x_val[y_val != 0]

    plt.figure(figsize=(18, 15))
    plt.plot(survivedNeuronTypes, survivedValues, '*r')
    plt.show()
    plt.savefig(globals.TSNE_RESULT_FILE + globals.DATA_FILE_NAME + fileName)
    plt.close()
    a=0