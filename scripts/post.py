"""
  Script run after every batch

  Dan Kolbman 2014
"""
import sys
import math
import matplotlib.pyplot as plt

import Grfx
import DataIO

def postSim(conf, path):
  """ postSim : Dict String -> None
  Plots system configuration, msd
  """

  numPerRow = math.ceil(math.sqrt(conf['nexperiments']))
  fig = plt.figure()
  fig.gca().get_xaxis().set_visible(False)
  fig.gca().get_yaxis().set_visible(False)
  fig.gca().set_frame_on(False)
  plt.title('Finals Configurations')
  # Loop over all experiments
  for i in range(1,conf["nexperiments"]+1):
    # Load configuration snapshots of trial 1
    im = plt.imread(path+'/experiment'+str(i)+'/trial1/finalConf.png')
    fig.add_subplot(numPerRow, numPerRow, i)
    plt.title('Experiment '+str(i))
    plt.imshow(im)
    fig.gca().get_xaxis().set_visible(False)
    fig.gca().get_yaxis().set_visible(False)
    fig.gca().set_frame_on(False)

  print(path+'finalConf.png')
  plt.savefig(path+'/finalConf.png')
  plt.show()

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
    postSim(conf, sys.argv[2])
