"""
Cluster analysis
"""
import numpy as np
from sklearn.cluster import dbscan

def cluster_scan(parts, params, eps=1.0, sp=0):
  """
  Finds clusters in the list of particles

  Parameters
  ----------
  parts
    a list of particle objects to be clustered
  params
    a dict of configuration values
  eps
    the separation distance to use for identifying clusters
  sp
    the specie to identify clusters in
  """
  # Extraxct the position vectors
  D = np.zeros((len(parts),3))
  ps = 0
  for p in range(len(parts)):
    # Check if the particle is of the desired specie
    if sp == 0 or parts[p].sp == sp:
      D[ps] = parts[p].x 
      ps += 1
  # Truncate zeros if we didn't cluster everything
  D = D[:ps]

  [core, labels] =  dbscan( D, eps=eps, min_samples=1)
  n_clusters_ = len(set(labels)) - (1 if -1 in labels else 0)
  print('Found',n_clusters_,'clusters')
  # Sizes of each cluster
  cluster_sizes = np.bincount(labels)
  # Number of clusters for given size
  size_hist = np.bincount( cluster_sizes )
  return size_hist[1:]

def specie_scan(parts, params, eps=1.0):
  """
  Scans for clusters in each individual species
  Does not look for inter-species clusters

  Parameters
  ----------
  parts
    a list of particle objects to be clustered
  params
    a dict of configuration values
  eps
    the separation distance to use for identifying clusters

  Returns
  -------
  hists
    A list of histograms corresponding to each specie
  """

  nsp = max( p.sp for p in parts )

  # Size historgrams for each species
  hists = []
  for sp in range(1,nsp+1):
    hists.append( cluster_scan(parts, params, eps, sp) )

  return hists
    

