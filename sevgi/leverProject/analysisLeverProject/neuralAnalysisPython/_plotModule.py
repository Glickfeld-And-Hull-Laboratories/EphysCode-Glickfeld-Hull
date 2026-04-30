import pandas as pd
from matplotlib import pyplot as plt
import seaborn as sns
import numpy as np

import globals

def plotTSNEResult(tsneResultHoldRandom, tsneResultHoldFixed, tsneResultReleaseRandom, tsneResultReleaseFixed, tsneResultTargetRandom, tsneResultTargetFixed, neuronTypeY, fileName):
    dfHoldRandom = pd.DataFrame({'tsne_1': tsneResultHoldRandom[:, 0], 'tsne_2': tsneResultHoldRandom[:, 1], 'label': neuronTypeY})
    dfHoldFixed = pd.DataFrame({'tsne_1': tsneResultHoldFixed[:, 0], 'tsne_2': tsneResultHoldFixed[:, 1], 'label': neuronTypeY})
    dfReleaseRandom = pd.DataFrame({'tsne_1': tsneResultReleaseRandom[:, 0], 'tsne_2': tsneResultReleaseRandom[:, 1], 'label': neuronTypeY})
    dfReleaseFixed = pd.DataFrame({'tsne_1': tsneResultReleaseFixed[:, 0], 'tsne_2': tsneResultReleaseFixed[:, 1], 'label': neuronTypeY})
    dfTargetRandom = pd.DataFrame({'tsne_1': tsneResultTargetRandom[:, 0], 'tsne_2': tsneResultTargetRandom[:, 1], 'label': neuronTypeY})
    dfTargetFixed = pd.DataFrame({'tsne_1': tsneResultTargetFixed[:, 0], 'tsne_2': tsneResultTargetFixed[:, 1], 'label': neuronTypeY})

    # fig = plt.figure(figsize=(18, 15))
    # fig, ax = plt.subplots(1)
    fig, ax = plt.subplots(nrows=2, ncols=3, figsize=(30, 15))  # , ax3, ax4, ax5, ax6

    ax[0, 0].set_title('Hold Random')
    sns.scatterplot(ax=ax[0, 0], x='tsne_1', y='tsne_2', hue='label', data=dfHoldRandom, s=120, alpha=0.7)
    ax[0, 0].legend(bbox_to_anchor=(1.05, 1), loc=2, borderaxespad=0.0, fontsize='x-small') # bbox_to_anchor=(1.05, 1),

    ax[0, 1].set_title('Release Random')
    sns.scatterplot(ax=ax[0, 1], x='tsne_1', y='tsne_2', hue='label', data=dfReleaseRandom, s=120, alpha=0.7)
    ax[0, 1].legend(bbox_to_anchor=(1.05, 1), loc=2, borderaxespad=0.0, fontsize='x-small')

    ax[0, 2].set_title('Target Random')
    sns.scatterplot(ax=ax[0, 2], x='tsne_1', y='tsne_2', hue='label', data=dfTargetRandom, s=120, alpha=0.7)
    ax[0, 2].legend(bbox_to_anchor=(1.05, 1), loc=2, borderaxespad=0.0, fontsize='x-small')

    ax[1, 0].set_title('Hold Fixed')
    sns.scatterplot(ax=ax[1, 0], x='tsne_1', y='tsne_2', hue='label', data=dfHoldFixed, s=120, alpha=0.7)
    ax[1, 0].legend(bbox_to_anchor=(1.05, 1), loc=2, borderaxespad=0.0, fontsize='x-small')

    ax[1, 1].set_title('Release Fixed')
    sns.scatterplot(ax=ax[1, 1], x='tsne_1', y='tsne_2', hue='label', data=dfReleaseFixed, s=120, alpha=0.7)
    ax[1, 1].legend(bbox_to_anchor=(1.05, 1), loc=2, borderaxespad=0.0, fontsize='x-small')

    ax[1, 2].set_title('Target Fixed')
    sns.scatterplot(ax=ax[1, 2], x='tsne_1', y='tsne_2', hue='label', data=dfTargetFixed, s=120, alpha=0.7)
    ax[1, 2].legend(bbox_to_anchor=(1.05, 1), loc=2, borderaxespad=0.0, fontsize='x-small')

    lim = (-globals.TSNE_XY_LIM, globals.TSNE_XY_LIM) #(tsneResultHoldRandom.min() - 3, tsneResultHoldRandom.max() + 3)
    ax[0, 0].set_xlim(lim)
    ax[0, 0].set_ylim(lim)
    ax[0, 0].set_aspect('equal')
    ax[0, 1].set_xlim(lim)
    ax[0, 1].set_ylim(lim)
    ax[0, 1].set_aspect('equal')
    ax[0, 2].set_xlim(lim)
    ax[0, 2].set_ylim(lim)
    ax[0, 2].set_aspect('equal')
    ax[1, 0].set_xlim(lim)
    ax[1, 0].set_ylim(lim)
    ax[1, 0].set_aspect('equal')
    ax[1, 1].set_xlim(lim)
    ax[1, 1].set_ylim(lim)
    ax[1, 1].set_aspect('equal')
    ax[1, 2].set_xlim(lim)
    ax[1, 2].set_ylim(lim)
    ax[1, 2].set_aspect('equal')

    plt.show()
    plt.savefig(globals.TSNE_RESULT_FILE + globals.DATA_FILE_NAME + fileName)
    plt.close()


def plotPCAResult(df, title, fileName, expVar):
    # For reproducability of the results
    np.random.seed(42)

    rndperm = np.random.permutation(df.shape[0])

    fig, ax = plt.subplots(nrows=3, ncols=1, figsize=(16, 25))
    fig.suptitle(title + ' Exp.var={0:.2f} on the pca-one'.format(expVar[0]))
    #ax[0].set_title('PCA dim 1 vs dim 2')
    sc12 = sns.scatterplot(ax=ax[0],
                    x="pca-one", y="pca-two",
                    hue="y",
                    # palette=sns.color_palette("hls", 10),
                    data=df.loc[rndperm, :],
                    s=250,
                    legend="full",
                    alpha=0.7
                    )
    sc12.set_xlabel('pca-one', fontdict={'fontweight': 'bold'})
    sc12.set_ylabel('pca-two', fontdict={'fontweight': 'bold'})

    #ax[1].set_title('PCA dim 2 vs dim 3')
    sc23 = sns.scatterplot(ax=ax[1],
                    x="pca-two", y="pca-three",
                    hue="y",
                    # palette=sns.color_palette("hls", 10),
                    data=df.loc[rndperm, :],
                    s=250,
                    legend="full",
                    alpha=0.7
                    )
    sc23.set_xlabel('pca-two', fontdict={'fontweight': 'bold'})
    sc23.set_ylabel('pca-three', fontdict={'fontweight': 'bold'})

    #ax[2].set_title('PCA dim 1 vs dim 3')
    sc13 = sns.scatterplot(ax=ax[2],
                    x="pca-one", y="pca-three",
                    hue="y",
                    # palette=sns.color_palette("hls", 10),
                    data=df.loc[rndperm, :],
                    s=250,
                    legend="full",
                    alpha=0.7
                    )
    sc13.set_xlabel('pca-one', fontdict={'fontweight': 'bold'})
    sc13.set_ylabel('pca-three', fontdict={'fontweight': 'bold'})

    plt.show()
    plt.savefig(globals.PCA_RESULT_FILE + globals.DATA_FILE_NAME + fileName)
    plt.close()