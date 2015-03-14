import numpy as np
import matplotlib.pyplot as plt

def plot_msd(msd):
  for i in range(1,len(msd[1,:])):
    # Line
    plt.plot(msd[:,0], msd[:,i], label='Species %d'%i )
    # Current axes
    ax = plt.gcf().gca()
    # Linear fit
    slope,intercept=np.polyfit(msd[:,0],msd[:,i], 1)
    slope = int(slope*100)/100
    # Put fit on graph
    plt.text(0.05, 0.7-i*0.05,\
      'Sp. {0}: {1}'.format(i,slope),\
      transform = ax.transAxes,fontsize=18)
  # Titles
  plt.gcf().gca().set_title('Mean Square Displacement')
  plt.xlabel('Time')
  plt.ylabel('MSD')
  plt.legend(loc=2, fontsize=22)
