import numpy as np
import pandas as pd
from sklearn.decomposition import PCA
from sklearn.manifold import TSNE

import globals

def runTSNE(X, y, flagPCA):
    if flagPCA:
        feat_cols = ['bin' + str(i) for i in range(X.shape[1])]

        df = pd.DataFrame(X, columns=feat_cols)
        df['y'] = y
        df['label'] = df['y'].apply(lambda i: str(i))
        pca = PCA(n_components=globals.PCA_DIM_SIZE)
        pca_result = pca.fit_transform(df[feat_cols].values)
        print('Cumulative explained variation for {} principal components: {}'.format(globals.PCA_DIM_SIZE, np.sum(pca.explained_variance_ratio_[:3])))
        df['pca-one'] = pca_result[:, 0]
        df['pca-two'] = pca_result[:, 1]
        df['pca-three'] = pca_result[:, 2]
        newMatrix = pca_result
    else:
        newMatrix = X

    # We want to get TSNE embedding with 2 dimensions
    n_components = 2
    tsne = TSNE(n_components, init='pca', perplexity=globals.TSNE_PERPLEXITY, n_iter=1000, learning_rate='auto')
    tsne_result = tsne.fit_transform(newMatrix)
    return tsne_result

def runPCA(X, y):
    feat_cols = ['bin' + str(i) for i in range(X.shape[1])]

    df = pd.DataFrame(X, columns=feat_cols)
    df['y'] = y
    df['label'] = df['y'].apply(lambda i: str(i))

    pca = PCA(n_components=3)
    pca_result = pca.fit_transform(df[feat_cols].values)

    df['pca-one'] = pca_result[:, 0]
    df['pca-two'] = pca_result[:, 1]
    df['pca-three'] = pca_result[:, 2]

    print('Explained variation per principal component: {}'.format(pca.explained_variance_ratio_))
    return df, pca.explained_variance_ratio_
