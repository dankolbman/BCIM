"""
  Generate a radial distribution function for a binary system

  Dan Kolbman 2015
"""

import numpy as np
import matplotlib.pyplot as plt
import sys

import DataIO

def rad_dist(conf, path, bin_count=100):
  t, sp, xpos, ypos, zpos = DataIO.readPos(path)

  parts = np.matrix( [sp, xpos, ypos, zpos] ).transpose()
  npart = len(parts)

  rad = conf['size']
  dr = rad/bin_count/2.0

  bins = np.zeros(bin_count)
  gr = []
  dists = np.linspace(0.0, rad, bin_count)

  for i in range(len(parts)-1):
    d = np.linalg.norm( parts[i,1:] )
    for j in range(i+1, len(parts)):
      #if parts[i,0] == 2 or parts[j,0] == 2:
      #  continue
      d = np.linalg.norm( parts[j,1:] - parts[i,1:] )
      bnum = int(d/dr)
      if d < rad/2.0:
        bins[bnum] += 2

  phi = npart/(4.0/3.0*np.pi*(rad/2.0)**3)

  ideal = 4.0/3.0*np.pi*phi

  for b in range(len(bins)):
    nideal = ((b+1)**3-b**3)*dr**3*ideal
    gr.append(bins[b]/nideal)

  #print(gr)

  plt.plot(dists, gr)
  plt.show()

  exit()







  # Choose each particle
  for p1 in range(len(xpos)):
    # Bin particles on distance from this particle
    for p2 in range(len(xpos)):
      d = np.linalg.norm( pos[p1,1:] )
      if p1 != p2 and d < rad/2.0 and pos[p2,0] == pos[p1,0]:
        d = np.linalg.norm( pos[p2,1:] - pos[p1,1:] )
        bins[np.floor(d/dr)] += 1

  tot = len(xpos)

  for b in bins:
    gr.append(b/(4*tot*np.pi**2*dr)/conf['phi'])

  #print(gr)

  plt.plot(dists, gr)
  plt.show()

if __name__=='__main__':
  if(len(sys.argv) < 3):
    print("Correct useage: python distribution.py path/to/sim.cnf path/to/parts.dat")
  else:
    conf = DataIO.readConf(sys.argv[1])
    rad_dist(conf, sys.argv[2])

