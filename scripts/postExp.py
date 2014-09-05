"""
  Script run after every experiment

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
  # g(r)
  fig = plt.figure(dpi=200)
  fig.add_subplot(111)
  Grfx.plotGR(path, ['/avgGR.dat'] )
  plt.savefig(path+'gr.png', dpi=200)

  # msd
  fig = plt.figure(dpi=200)
  fig.add_subplot(111)
  Grfx.plotMSD(path, ['/avgMSD.dat'] )
  plt.savefig(path+'avgMSD.png', dpi=200)

if(__name__ == '__main__'):
  if(len(sys.argv) < 3):
    print("Correct useage: python postSim.py path/to/sim.cnf path/to/sim/dir/")
  else:
    conf = DataIO.readConf(sys.argv[1])
    postSim(conf, sys.argv[2])
