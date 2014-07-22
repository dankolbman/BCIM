"""
  Script run after every simulation
  Plot and save system configuration
  Plot and save msd

  Dan Kolbman 2014
"""
import sys
import matplotlib.pyplot as plt

import Grfx
import DataIO

def postSim(conf, path):
  """ postSim : Dict String -> None
  Plots system configuration, msd
  """
  # Configuration
  fig = plt.figure()
  fig.add_subplot(111)
  Grfx.plotConfig2D(conf, path, ['/parts.dat'])
  plt.savefig(path+'finalConf.png', figsize=(1,1), dpi=100)
  # MSD
  fig = plt.figure()
  fig.add_subplot(111)
  Grfx.plotMSD(path, ['/avgMSD.dat'] )
  plt.savefig(path+'msd.png')


if(__name__ == '__main__'):
  if(len(sys.argv) < 3):
    print("Correct useage: python postSim.py path/to/sim.cnf path/to/sim/dir/")
  else:
    conf = DataIO.readConf(sys.argv[1])
    postSim(conf, sys.argv[2])
