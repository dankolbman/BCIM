"""
  Utility for plotting mean square displacements
  
  Dan Kolbman 2014
"""
from mpl_toolkits.mplot3d import Axes3D
import matplotlib.pyplot as plt
import numpy as np
import pylab as P
import sys

import DataIO

plt.ioff()

################################################################################
# Plot the system configuration

def plotConfig2D(conf, path, files):
  """ plotConfig2D : Dict String String[]  -> None
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

  plotBounds2D(conf, plt.gcf().gca())

def plotBounds2D(conf, axes):
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

def plotConfig3D(conf, path, files):
  """ plotPos : Dict -> None
  Plots position data
  """
  colors = ['r', 'b', 'c', 'm']
  fig = plt.figure()
  ax = fig.gca(projection='3d')
  for i in range(0,len(files)):
    sp, xpos, ypos, zpos = DataIO.readPos(path+files[i])
    clrs = [ colors[j-1] for j in sp ]
    ax.scatter(xpos,ypos,zpos,c=clrs, s=200/conf['size'], lw=0)

  plotBounds3D(conf, plt.gcf().gca())
  ax.set_xlim3d(-conf["size"], conf["size"])
  ax.set_ylim3d(-conf["size"], conf["size"])
  ax.set_zlim3d(-conf["size"], conf["size"])

def plotBounds3D(conf, axes):
  """ plotBounds : Dict Axes -> True
  Draws a sphere with a radius of the system size
  """
  u = np.linspace(0, 2*np.pi, 100)
  v = np.linspace(0, np.pi, 100)

  x = conf["size"]*np.outer(np.cos(u), np.sin(v))
  y = conf["size"]*np.outer(np.sin(u), np.sin(v))
  z = conf["size"]*np.outer(np.ones(np.size(u)), np.cos(v))
  axes.plot_surface(x, y, z, rstride=4, cstride=4, color='b', alpha = 0.05,\
    linewidth=0)
  return True

################################################################################
# Plot histogram of neighbor velocities
def plotNeighborVel(path, files, rad):
  rad2 = rad*rad
  for i in range(len(files)):
    parts = DataIO.readParts(str(path)+files[i])
    # Look at each particle
    for p1 in parts:
      neigh = 0
      # Store the difference in v^2 from the mean for its neighbors
      v2diffs1 = []
      v2diffs2 = []
      # Look at each of the particle's neighbors
      for p2 in parts:
        d2 = (p1.x[0]-p2.x[0])**2 + (p1.x[1]-p2.x[1])**2 + (p1.x[2]-p2.x[2])**2
        if p2!=p1:
          if d2 < rad2:
            neigh += 1
            if p2.sp == 1.0:
              v2diffs1.append(p2.v2() - p1.v2())
            else:
              v2diffs2.append(p2.v2() - p1.v2())

      # Create a histogram for diffs
      bins = [ int(x*30) for x in range(-5,5) ]
      if (len(v2diffs1) > 0):
        n1, bins1, patches1 = P.hist(v2diffs1, bins, histtype='bar')
        P.setp(patches1, 'facecolor', 'r', 'alpha', 0.5)
      if (len(v2diffs2) > 0):
        n2, bins2, patches2 = P.hist(v2diffs2, bins, histtype='bar')
        P.setp(patches2, 'facecolor', 'b', 'alpha', 0.5)
      P.xlim([-150,150])
      #P.ylim([0,1.5])
      P.show()

################################################################################
# Plot the msd

def plotMSD(path, files):
  """ plotMsd : Dict String[] -> None
  Plots mean square displacement data
  """
  colors = ['#E82C2C', '#245BFF', 'c', 'm']
  for i in range(len(files)):
    msd = DataIO.readAvgMSD(str(path)+files[i])

    for j in range(1,len(msd[1,:])):
      # Line
      plt.plot(msd[:,0], msd[:,j], color=colors[(j-1)%3], label=str(i))
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

################################################################################
# Plot the g(r)

def plotGR(path, files):
  """ plotGR : Dict String[] -> None
  Plots g(r) data
  """
  colors = ['#E82C2C', '#245BFF', 'c', 'm']
  for i in range(len(files)):
    gr = DataIO.readGr(str(path)+files[i])
    for j in range(1, len(gr[1,:])):
      plt.plot(gr[:,0], gr[:,j], color=colors[(j-1)%3], label=str(i))
      
  # Titles
  plt.gcf().gca().set_title('Radial Distribution')
  plt.xlabel('r (diameters)')
  plt.ylabel('g(r)')


"""
  If called directly, only plot msd
"""
#if __name__ == '__main__':
  
