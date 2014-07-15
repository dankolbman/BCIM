"""
  Plot positions of a multispecies system in 2d

  Dan Kolbman 2014
"""
import matplotlib.pyplot as plt
import sys

import DataIO

def plotSys(conf, arg):
  """ plotPos : Dict -> None
  Plots position data
  """
  colors = ['#E82C2C', '#245BFF', 'c', 'm']

  for i in range(0,len(arg)):
    fig = plt.gcf()
    ax = fig.gca()
    sp, xpos, ypos = DataIO.readPos2D(arg[i])
    circleScatter(xpos, ypos, ax,\
            sp, colors,\
            radius=conf['dia']/2)
    #s = [conf['diameter']**2/4*3.1415 for i in range(len(xpos))]
    #plt.scatter(xpos, ypos,color=colors[(i)%3])

  plotBounds(conf, plt.gcf().gca())
  plt.savefig('fpos.png', figsize=(1,1), dpi=100)


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


"""
  If called directly, only show the position plot
"""
if __name__ == '__main__':
  if(len(sys.argv) < 3):
    print('Correct usage: python posplot.py sysparam.dat pos1.dat pos2.dat ...')
  else:
    # Get the configuration variables
    conf = DataIO.readConf(sys.argv[1])
    plt.gcf().add_subplot(111, aspect='equal')
    plotSys(conf, sys.argv[3:])
    plt.savefig(sys.argv[2])
    plt.show()
  

