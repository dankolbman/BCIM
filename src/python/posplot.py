"""
  Plot positions of a multispecies spherical system

  Dan Kolbman 2014
"""
from mpl_toolkits.mplot3d import Axes3D
import matplotlib.pyplot as plt
import numpy as np
import sys

import DataIO

def plotSys(conf, arg):
  """ plotPos : Dict -> None
  Plots position data
  """
  colors = ['r', 'b', 'c', 'm']
  fig = plt.figure()
  ax = fig.gca(projection='3d')
  for i in range(0,len(arg)):
    xpos, ypos, zpos = DataIO.readPos(arg[i])
    ax.scatter(xpos,ypos,zpos,s=200)

    #for (xi,yi,zi) in zip(xpos, ypos, zpos):
    #  (xs,ys,zs) = drawSphere(xi,yi,zi,np.pi*(conf["dia"]/2)**2)
    #  ax.plot_wireframe(xs, ys, zs, color="r")

    #circleScatter(xpos, ypos, ax,\
    #        radius=conf['diameter']/2,\
    #        color=colors[i%len(colors)])
    #s = [conf['diameter']**2/4*3.1415 for i in range(len(xpos))]
    #plt.scatter(xpos, ypos, s=s,color=colors[(i)%3])

  plotBounds(conf, plt.gcf().gca())
  ax.set_xlim3d(-conf["size"], conf["size"])
  ax.set_ylim3d(-conf["size"], conf["size"])
  ax.set_zlim3d(-conf["size"], conf["size"])

def drawSphere(xC, yC, zC, r):
    u, v = np.mgrid[0:2*np.pi:20j, 0:np.pi:10j]
    x=np.cos(u)*np.sin(v)
    y=np.sin(u)*np.sin(v)
    z=np.cos(v)
    x = r*x + xC
    y = r*y + yC
    z = r*z + zC
    return (x,y,z)

def plotBounds(conf, axes):
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

"""
  If called directly, only show the position plot
"""
if __name__ == '__main__':
  if(len(sys.argv) < 3):
    print('Correct usage: python posplot.py sysparam.dat out.dat pos1.dat...')
  else:
    # Get the configuration variables
    conf = DataIO.readConf(sys.argv[1])
    plotSys(conf, sys.argv[3:])
    plt.savefig(sys.argv[2])
