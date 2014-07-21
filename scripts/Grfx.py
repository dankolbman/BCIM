"""
  Utility for plotting mean square displacements
  
  Dan Kolbman 2014
"""
import matplotlib.pyplot as plt
import numpy as np
import sys

import DataIO

################################################################################
# Plot the system configuration

def plotConfig2D(conf, path, files, show=False):
  """ plotConfig2D : Dict String String[] Bool  -> None
  Plots system configuration
  """
  colors = ['#E82C2C', '#245BFF', 'c', 'm']
  
  fig = plt.figure()
  fig.add_subplot(111, aspect='equal')

  for i in range(0,len(files)):
    #fig = plt.gcf()
    ax = fig.gca()
    sp, xpos, ypos = DataIO.readPos2D(path+files[i])
    circleScatter(xpos, ypos, ax,\
            sp, colors,\
            radius=conf['dia']/2)
    #s = [conf['diameter']**2/4*3.1415 for i in range(len(xpos))]
    #plt.scatter(xpos, ypos,color=colors[(i)%3])

  plotBounds(conf, plt.gcf().gca())
  plt.savefig('finalConf.png', figsize=(1,1), dpi=100)
  if(show):
    plt.show()


def plotBounds(conf, axes):
  """ plotBounds : Dict Axes -> True
  Makes a rectangle or circle depending on the geometry of the boundary
  """
  rad = conf["size"]
  plt.ylim( (-rad*1.1, rad*1.1) )
  plt.xlim( (-rad*1.1, rad*1.1) )
  shape = plt.Circle((0, 0), radius=rad)

  shape.fill = False
  axes.add_artist(shape)
  return True

def circleScatter(xpos, ypos, axes, sp, colors, **kwargs):
  """ circleScatter : float[] float[] -> True
  Creates a scatter plot of circles
  """
  #for x,y in zip(xpos, ypos):
  for i in range(len(xpos)):
    circle = plt.Circle((xpos[i],ypos[i]), color=colors[int(sp[i]-1)], **kwargs)
    axes.add_patch(circle)

  return True

################################################################################
# Plot the msd

def plotMSD(path, files, show=False):
  """ plotMsd : Dict String[] -> None
  Plots mean square displacement data
  """
  colors = ['#E82C2C', '#245BFF', 'c', 'm']
  for i in range(len(files)):
    msd = DataIO.readAvgMSD(str(path)+files[i])

    for j in range(1,len(msd[1,:])):
      # Line
      plt.loglog(msd[:,0], msd[:,j], color=colors[(j-1)%3], label=str(i))
      # Dots
      #plt.plot(t, msd, 'o', color=colors[(i)%3], label=str(i))
      # Current axes
      ax = plt.gcf().gca()
      # Linear fit
      slope,intercept=np.polyfit(msd[:,0],msd[:,j],1)
      # Put fit on graph
      plt.text(0.1, 0.9-j*0.06,\
        'Slope: '+str(slope),\
        transform = ax.transAxes)
  # Titles
  plt.gcf().gca().set_title('Mean Square Displacement')
  plt.xlabel('Time')
  plt.ylabel('MSD')
  plt.savefig(path+'msdlog.png')
  if(show):
    plt.show()


"""
  If called directly, only plot msd
"""
#if __name__ == '__main__':
  
