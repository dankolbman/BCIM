"""
  Script run after every batch

  Dan Kolbman 2014
"""
import matplotlib
matplotlib.use('Agg')
import sys
import math
import matplotlib.pyplot as plt

import Grfx
import DataIO

from matplotlib import rc
#rc('font',**{'family':'sans-serif','sans-serif':['dejavu']})
#rc('text', usetex=True)

plt.ioff()

def post(conf, path):
  """ post : Dict String -> None
  Plots system configuration, msd
  """
  plt.close()
  numPerRow = math.ceil(math.sqrt(conf['nexperiments']))
  fig = plt.figure()
  fig.gca().get_xaxis().set_visible(False)
  fig.gca().get_yaxis().set_visible(False)
  fig.gca().set_frame_on(False)
  #plt.suptitle('Final Configurations')
  # Loop over all experiments
  for i in range(1,conf["nexperiments"]+1):
    # Load configuration snapshots of trial 1
    im = plt.imread(path+'/experiment'+str(i)+'/trial1/finalConf.png')
    fig.add_subplot(numPerRow, numPerRow, i)
    #plt.title('Experiment '+str(i))
    plt.imshow(im)
    fig.gca().get_xaxis().set_visible(False)
    fig.gca().get_yaxis().set_visible(False)
    fig.gca().set_frame_on(False)

  #fig.set_size_inches( 6, 6 )
  #plt.subplots_adjust(wspace=-0.3, hspace=-0.3)
  plt.tight_layout()
  plt.savefig(path+'/finalConf.png', transparant=True, frameon=False, dpi=200,bbox_inches='tight')
  if(conf["serverMode"] == 0): plt.show()

  # MSD
  fig = plt.figure()
  fig.gca().get_xaxis().set_visible(False)
  fig.gca().get_yaxis().set_visible(False)
  fig.gca().set_frame_on(False)
  #plt.suptitle('MSD')
  # Loop over all experiments
  for i in range(1,conf["nexperiments"]+1):
    # Load configuration snapshots of trial 1
    im = plt.imread(path+'/experiment'+str(i)+'/avgMSD.png')
    fig.add_subplot(numPerRow, numPerRow, i)
    #plt.title('Experiment '+str(i))
    plt.imshow(im)
    fig.gca().get_xaxis().set_visible(False)
    fig.gca().get_yaxis().set_visible(False)
    fig.gca().set_frame_on(False)

  plt.tight_layout()
  plt.savefig(path+'/avgMSD.png', transparant=True, frameon=False, dpi=200,bbox_inches='tight')
  if(conf["serverMode"] == 0): plt.show()

  # MSD log
  fig = plt.figure()
  fig.gca().get_xaxis().set_visible(False)
  fig.gca().get_yaxis().set_visible(False)
  fig.gca().set_frame_on(False)
  #plt.suptitle('MSD')
  # Loop over all experiments
  for i in range(1,conf["nexperiments"]+1):
    # Load configuration snapshots of trial 1
    im = plt.imread(path+'/experiment'+str(i)+'/avgMSDlog.png')
    fig.add_subplot(numPerRow, numPerRow, i)
    #plt.title('Experiment '+str(i))
    plt.imshow(im)
    fig.gca().get_xaxis().set_visible(False)
    fig.gca().get_yaxis().set_visible(False)
    fig.gca().set_frame_on(False)

  #fig.set_size_inches( 6, 6 )
  #plt.subplots_adjust(wspace=-0.3, hspace=-0.3)
  plt.tight_layout()
  plt.savefig(path+'/avgMSDlog.png', transparant=True, frameon=False, dpi=200,bbox_inches='tight')
  if(conf["serverMode"] == 0): plt.show()

  # Configuration
  #fig = plt.figure()
  #fig.add_subplot(111)
  #Grfx.plotConfig2D(conf, path, ['/parts.dat'])
  #plt.savefig(path+'finalConf.png', figsize=(1,1), dpi=100)
  # MSD
  #fig = plt.figure()
  #fig.add_subplot(111)
  #Grfx.plotMSD(path, ['/msd.dat'] )
  #plt.savefig(path+'msd.png')
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
    post(conf, sys.argv[2])
