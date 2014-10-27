"""
  Creates a movie out of all the position data available

  Dan Kolbman 2014
"""
import matplotlib
matplotlib.use('Agg')
import sys
import math
import matplotlib.pyplot as plt
import matplotlib.animation as manimation

import Grfx
import DataIO

from matplotlib import rc
#rc('font',**{'family':'sans-serif','sans-serif':['dejavu']})
#rc('text', usetex=True)
# Turn off interactive plotting
plt.ioff()

def movie(conf, path, path_out="movie.mp4"):
  """ movie : String String -> None
  Creates a movie out of particle information data
  """
  # Set up movie stream
  FFMpegWriter = manimation.writers['ffmpeg']
  metadata = dict(title='Movie Test', artist='Matplotlib')
  writer = FFMpegWriter(fps=5, metadata=metadata)

  # Configure plot figure
  fig = plt.figure()
  colors = ['r', 'b', 'c', 'm']
  ax = fig.gca(projection='3d')
  ax.set_xlim3d(-conf["size"], conf["size"])
  ax.set_ylim3d(-conf["size"], conf["size"])
  ax.set_zlim3d(-conf["size"], conf["size"])
  Grfx.plotBounds3D(conf, plt.gcf().gca())

  t, sp, xpos, ypos, zpos = DataIO.readPos(path)
  clrs = [ colors[j-1] for j in sp ]
  pts = ax.scatter(xpos, ypos, zpos, c=clrs, s=200/conf['size'], lw=0)
  plt.tight_layout()

  ani = manimation.FuncAnimation(fig, update, frames=99, interval=1, fargs=(path, pts, ax, clrs, conf))
  ani.save('anim.mp4', fps=15, extra_args=['-vcodec', 'libx264'])
  # Now plot the frames
  #with writer.saving(fig, path_out, 72):
  #  for i in range(1, 10):
      #sp, xpos, ypos, zpos = DataIO.readPos(path, i*1)
      #ani = manimation.FuncAnimation(fig, update, fargs=(i,path, pts, ax, clrs, conf))
  #    writer.grab_frame()
  #plt.show()

def update(i, path, pts, ax, clrs, conf):
  print("Plotting frame", i)
  t, sp, xpos, ypos, zpos = DataIO.readPos(path, 99-i)
  ax.cla()
  Grfx.plotBounds3D(conf, plt.gcf().gca())
  pts = ax.scatter(xpos, ypos, zpos, c=clrs, s=2000/conf['size'], lw=0)
  #ax.set_xlim([-conf['size'], conf['size']])
  #ax.set_ylim([-conf['size'], conf['size']])
  #ax.set_zlim([-conf['size'], conf['size']])
  ax.w_xaxis.gridlines.set_lw(0.0)
  ax.w_yaxis.gridlines.set_lw(0.0)
  ax.w_zaxis.gridlines.set_lw(0.0)
  ax._axis3don = False
  plt.title('Time ='+str(t[0]))
  return pts
  
if(__name__ == '__main__'):
  if(len(sys.argv) == 4):
    conf = DataIO.readConf(sys.argv[1])
    movie(sys.argv[2], sys.argv[1])
  elif(len(sys.argv) == 3): # Use default output name
    conf = DataIO.readConf(sys.argv[1])
    movie(conf, sys.argv[2])
  elif(len(sys.argv) < 3):
    print("Correct useage: python movie.py path/to/sim.cnf path/to/part.dat [path/to/output.mp4]")
