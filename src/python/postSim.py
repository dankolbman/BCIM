"""
  Script run after every simulation
  Plot and save system configuration
  Plot and save msd

  Dan Kolbman 2014
"""
import matplotlib
#matplotlib.use('Agg')
import sys
import matplotlib.pyplot as plt

import Grfx
import DataIO

from matplotlib import rc
#rc('font',**{'family':'sans-serif','sans-serif':['dejavu']})
#rc('text', usetex=True)
rc('axes', labelsize=10)

plt.ioff()

def postSim(conf, path):
  """ postSim : Dict String -> None
  Plots system configuration, msd
  """
  #fig = plt.figure(dpi=200)
  #Grfx.plotNeighborVel(path, ['/parts.dat'], 10)
  # Configuration
  fig =  plt.figure(dpi=200)
  fig.add_subplot(111)
  Grfx.plotConfig3D(conf, path, ['/parts.dat'])
  plt.subplots_adjust(wspace=0.0, hspace=0.0)
  plt.tight_layout()
  #fig.set_size_inches(10,10)
  plt.savefig(path+'finalConf.png', dpi=200)
  # MSD
  fig =  plt.figure(dpi=200)
  fig.add_subplot(111)
  Grfx.plotMSD(path, ['/msd.dat'] )
  plt.savefig(path+'msd.png', dpi=200)
  # MSD log
  fig =  plt.figure(dpi=200)
  fig.add_subplot(111)
  Grfx.plotMSD(path, ['/msd.dat'] )
  plt.gca().set_yscale('log')
  plt.gca().set_xscale('log')
  plt.savefig(path+'msdlog.png', dpi=200)
  # g(r)
  #fig = plt.figure()
  #fig.add_subplot(111)
  #Grfx.plotGR(path, ['/gr.dat'] )
  #plt.savefig(path+'gr.png')


if(__name__ == '__main__'):
  if(len(sys.argv) < 3):
    print("Correct useage: python postSim.py path/to/sim.cnf path/to/sim/dir/")
  else:
    conf = DataIO.readConf(sys.argv[1])
    postSim(conf, sys.argv[2])
