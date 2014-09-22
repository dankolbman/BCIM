"""
  Script run after every experiment

  Dan Kolbman 2014
"""
import matplotlib
matplotlib.use('Agg')
import sys
import matplotlib.pyplot as plt

import Grfx
import DataIO

from matplotlib import rc
#rc('font',**{'family':'sans-serif','sans-serif':['dejavu']})
#rc('text', usetex=True)

plt.ioff()

def postSim(conf, path, title=""):
  """ postSim : Dict String -> None
  Plots system configuration, msd
  """
  plt.close()
  # g(r)
  fig = plt.figure(dpi=200)
  fig.add_subplot(111)
  Grfx.plotGR(path, ['/avgGR.dat'] )
  plt.savefig(path+'gr.png', dpi=200)

  # msd
  fig = plt.figure(dpi=200)
  fig.add_subplot(111)
  Grfx.plotMSD(path, ['/avgMSD.dat'] )
  if(title != ""):
    plt.title(title)
  plt.savefig(path+'avgMSD.png', dpi=200)

  # msd log
  fig = plt.figure(dpi=200)
  fig.add_subplot(111)
  Grfx.plotMSD(path, ['/avgMSD.dat'])
  plt.gca().set_yscale('log')
  plt.gca().set_xscale('log')
  if(title != ""):
    plt.title(title)
  plt.savefig(path+'avgMSDlog.png', dpi=200)

if(__name__ == '__main__'):
  if(len(sys.argv) < 3):
    print("Correct useage: python postSim.py path/to/sim.cnf path/to/sim/dir/")
  else:
    conf = DataIO.readConf(sys.argv[1])
    if(len(sys.argv) > 3):
      postSim(conf, sys.argv[2], title=sys.argv[3])
    else:
      postSim(conf, sys.argv[2])
