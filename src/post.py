import glob
import os
import sys
import re

import matplotlib.pyplot as plt
import numpy as np
import python.DataIO as DataIO
import python.graphics as graphics

# Format settings
from matplotlib import rc
font = {'size' : 32}
rc('font', **font)
rc('lines', **{'linewidth' : '4' } )
rc('axes', **{'labelsize' : '28', 'titlesize' : 32 } )
rc('axes', color_cycle=['#E82C2C', '#245BFF', 'c', 'm'])
rc('xtick', **{'labelsize' : '22' } )
rc('ytick', **{'labelsize' : '22', 'major.size' : '10', 'minor.size' : '10' } )

def averageMSD(path, out_path=None):
  """
  Computes the average MSD of an experiment given an experiment's directory path
  
  Parameters
  ----------
  path
    the path to an experiment's output directory
  out_path : string, optional
    the path to save the average msd output to
    Default is 'avg_msd.dat' in the experiment's directory
  """
  # Set out file to the experiment's directory if not specified
  if( out_path == None ):
    out_path = os.path.join(path, 'avg_msd.dat')

  # Read in msd data from each file
  msds = []
  # Iterates the experiment's directory to find the msd data files
  for root, dirs, files in os.walk(path):
    for f in files:
      if f == "msd.dat":
        msd_file = os.path.join(root, f)
        msds.append( np.loadtxt( msd_file ) )

  # Average the msds
  N = len(msds)
  avg_msd = msds[0]/N
  if len(msds) > 1:
    for msd in msds[1:]:
      avg_msd += msd/N

  np.savetxt( out_path, avg_msd, header='# [ time msd ... ]')
  return avg_msd

# Read parameters into dict
def read_params(path):
  """
  Reads a parameter file into a python dictionary

  Parameters
  ----------
  path : string
    the path of the parameter file
  
  Returns
  -------
  A python dictionary keyed on the parameter name.
  """

  params=dict() 
  try:
    f = open(path)
    for line in f:
      if line[0] == '#':
        continue
      l = line.split()
      # Simple one value param
      if(len(l) == 2):
        if(re.fullmatch("[0-9e\.]*",l[1]) != None):
          params[l[0]] = float(l[1])
      # If there is more than one value for the param
        else:
          params[l[0]] = l[1]
      # If there is more than one value for the param
      elif(len(l) > 2):
        val = []
        # Iterate through values
        for i in range(1,len(l)):
          # Is it a string
          if(re.fullmatch("[0-9e\.]*",l[i]) != None):
            val.append(float(l[i]))
          else:
            val.append(l[i])
        params[l[0]] = val
  except IOError as e:
    print('Could not process file', e.strerror)
  return params

def param_str(params):
  pstr = ''
  pstr += 'Repulsion: {0}\n'.format(params['rep'])
  pstr += 'Adhesion: {0}\n'.format(params['adh'])
  pstr += 'Propulsion: {0}\n'.format(params['prop'])
  return pstr


# Do all the post processing
def main(args):
  """
  Does all post processing for an experiment

  Parameters
  ----------
  path
    a path of an experiment directory
  """
  path = args[1]
  if not os.path.exists(path):
    raise IOError('The specified experiment path does not exist')
  # Compute average msd
  avg_msd = averageMSD(path)

  fig = plt.figure(dpi=72, figsize=( 10,8))

  ax = plt.subplot2grid((4,1), (0,0), rowspan=3)
  # MSD plot
  graphics.plot_msd(avg_msd)
  plt.gca().set_yscale('log')
  plt.gca().set_xscale('log')
  
  ax = plt.subplot2grid((4,1), (3,0))
  plt.axis('off')
  params = dict()
  for f in os.listdir(path):
    if f == 'param_dim.dat':
      params = read_params(os.path.join(path, f))
      break
  fig.text(0.1, 0.0, param_str(params), fontsize=18)
  plt.savefig(os.path.join(path, 'overview.png'))
  plt.show()
     


if __name__ == "__main__":
  if(len(sys.argv) < 2):
    print("Usage: python post.py experiment_dir/")
  else:
    main(sys.argv)
