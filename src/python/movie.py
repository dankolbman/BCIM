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

import graphics
import DataIO

from matplotlib import rc
#rc('font',**{'family':'sans-serif','sans-serif':['dejavu']})
#rc('text', usetex=True)
# Turn off interactive plotting
plt.ioff()

def movie(params, path, path_out="movie.mp4"):
  """ movie : String String -> None
  Creates a movie out of particle information data
  """
  # Set up movie stream
  FFMpegWriter = manimation.writers['ffmpeg']
  metadata = dict(title='Movie Test', artist='Matplotlib')
  writer = FFMpegWriter(fps=5, metadata=metadata)

  # Configure plot figure
  fig = plt.figure()

  # Read in the particles
  parts = DataIO.read_parts(path)

  ax = plt.subplot(1,1,1, projection='3d')
  ax._axis3don = False

  plt.suptitle( 'Diffus: {0}, Rot. Diffus: {1}'.format(params['pretrad'], params['prerotd']))

  graphics.plot_config( parts, params )


  ani = manimation.FuncAnimation(fig, update, frames=100, interval=1, fargs=(path, ax, params))
  ani.save('anim.mp4', fps=15, extra_args=['-vcodec', 'libx264'])
  # Now plot the frames
  #with writer.saving(fig, path_out, 72):
  #  for i in range(1, 10):
      #sp, xpos, ypos, zpos = DataIO.readPos(path, i*1)
      #ani = manimation.FuncAnimation(fig, update, fargs=(i,path, pts, ax, clrs, params))
  #    writer.grab_frame()
  #plt.show()

def update(i, path, ax, params):
  print("Plotting frame", i)
  ax.cla()
  # Read in new particle data
  parts = DataIO.read_parts(path, 99-i)
  graphics.plot_config( parts, params )
  
  
if(__name__ == '__main__'):
  if(len(sys.argv) == 4):
    params = DataIO.read_params(sys.argv[1])
    movie(sys.argv[2], sys.argv[1])
  elif(len(sys.argv) == 3): # Use default output name
    params = DataIO.read_params(sys.argv[1])
    movie(params, sys.argv[2])
  elif(len(sys.argv) < 3):
    print("Correct useage: python movie.py path/to/dim_param.dat path/to/part.dat [path/to/output.mp4]")
