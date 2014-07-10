"""
  Utility for plotting mean square displacements
  
  Dan Kolbman 2014
"""
import matplotlib.pyplot as plt
import numpy as np
import sys

import DataIO

def plotMsd(conf, arg):
  """ plotMsd : Dict String[] -> None
  Plots mean square displacement data
  """
  colors = ['#E82C2C', '#245BFF', 'c', 'm']
  for i in range(len(arg)):
    msd = DataIO.readAvgMSD(arg[i])
    for j in range(1,len(msd)-1):
      # Line
      plt.loglog(msd[:,0], msd[:,1], color=colors[(i)%3], label=str(i))
      # Dots
      #plt.plot(t, msd, 'o', color=colors[(i)%3], label=str(i))
      # Current axes
      ax = plt.gcf().gca()
      # Linear fit
      slope,intercept=np.polyfit(msd[:,0],msd[:,1],1)
      # Put fit on graph
      plt.text(0.1, 0.9-i*0.06,\
        'Slope: '+str(int(slope)),\
        transform = ax.transAxes)
  # Titles
  plt.gcf().gca().set_title('Mean Square Displacement')
  plt.xlabel('Time')
  plt.ylabel('MSD')
  plt.savefig('msdlog.png')


"""
  If called directly, only plot msd
"""
if __name__ == '__main__':
  if(len(sys.argv) < 4):
    print('Correct usage: python msdplot.py sysparam.dat out.png msd1.dat...')
  else:
    # Get the configuration variables
    conf = DataIO.readConf(sys.argv[1])
    plotMsd(conf, sys.argv[3:])
    plt.savefig(sys.argv[2])
    plt.show()
  
