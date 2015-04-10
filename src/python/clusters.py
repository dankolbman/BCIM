"""
Cluster analysis
"""
import numpy as np
from sklearn.cluster import dbscan

def size_hist(parts, params, eps=1.0, sp=0):
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
  # Extract the position vectors
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

def specie_size(parts, params, eps=1.0):
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
    hists.append( size_hist(parts, params, eps, sp) )

  return hists

def vel_hist(parts, params, eps=1.0, sp=0):
  # Extract the position vectors
  D = np.zeros(( len(parts),3) )
  # Particle velocities
  V = np.zeros( (len(parts),3 ) )
  ps = 0
  for p in range(len(parts)):
    # Check if the particle is of the desired specie
    if sp == 0 or parts[p].sp == sp:
      D[ps] = parts[p].x 
      V[ps] = parts[p].v
      ps += 1
  # Truncate zeros if we didn't cluster everything
  D = D[:ps]
  # Make clusters based on position
  [core, labels] =  dbscan( D, eps=eps, min_samples=1)
  n_clusters_ = len(set(labels)) - (1 if -1 in labels else 0)
  # The net velocities of each cluster
  cluster_vels = np.zeros( (n_clusters_, 3) );
  
  # Iterate all particles
  for p in range(ps):
    if labels[p] >= 0: # Make sure it was clustered
      # Add particle velocity to its cluster's net velocity
      cluster_vels[ labels[p] ] = np.add( cluster_vels[ labels[p] ], V[p] )

  # Magnitudes of cluster velocities
  normed_vels = np.apply_along_axis( np.linalg.norm, 1, cluster_vels )

  cluster_sizes = np.bincount(labels)
  # Number of clusters for given size
  size_hist = np.bincount( cluster_sizes )
  # Speed as a function of size
  speed_size = np.zeros( len(size_hist) )
  # Iterate through clusters
  for c in range(n_clusters_):
    speed_size[ cluster_sizes[c] ] = np.add(speed_size[ cluster_sizes[c] ], normed_vels[c])

  # Average
  speed_size = np.divide(speed_size[1:], size_hist[1:])

  return speed_size

