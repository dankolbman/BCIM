import glob
import os
import sys
import re

import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec
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


def param_str1(params):
  """
  Creates a text box description of a system parameter dictionary
  
  Parameters
  ----------
  params : Dict
      The parameter dictionary (usually dimensionless parameters)
  
  Returns
  -------
  A string of the parameters formatted for a textbox summary
  """

  pstr = ''
  pstr += 'Particles: {0}\n'.format(params['npart'])
  pstr += 'Packing Frac: {0}\n'.format(params['phi'])
  pstr += 'Repulsion: {0}\n'.format(params['rep'])
  pstr += 'Adhesion: {0}\n'.format(params['adh'])
  pstr += 'Propulsion: {0}\n'.format(params['prop'])
  return pstr

def param_str2(params):
  pstr = ''
  pstr += 'Time unit: {0}\n'.format(params['utime'])
  pstr += 'pretrad: {0}\n'.format(params['pretrad'])
  pstr += 'prerotd: {0}\n'.format(params['prerotd'])
  return pstr

# Do all the post processing
def main(args):
  """
  Does all post processing for an experiment
  Computes the average MSD from msd files in experiment directory
  Then plots the average MSD on log-log
  Reads the parameter file and puts a textbox under the MSD with the experiment
  parameters.

  Parameters
  ----------
  path
    a path of an experiment directory
  """
  path = args[1]
  # Check for that the experiment exists
  if not os.path.exists(path):
    raise IOError('The specified experiment path does not exist')
  elif not os.path.exists(os.path.join(path, 'param_dim.dat')):
    raise IOError('There is no dimensionless parameter file in the specified \
                    directory')
  # Compute average msd
  avg_msd = averageMSD(path)

  # 2 X 3 grid
  gs = gridspec.GridSpec(5,2)

  # Read parameters
  params = dict()
  for f in os.listdir(path):
    if f == 'param_dim.dat':
      params = DataIO.read_params(os.path.join(path, f))
      break

  fig = plt.figure(dpi=72, figsize=( 10,8))

  ax = plt.subplot(gs[0:4, :])
  # MSD plot
  graphics.plot_msd(avg_msd)
  plt.gca().set_yscale('log')
  plt.gca().set_xscale('log')
  
  # Parameters 
  ax = plt.subplot(gs[-1,0:1])
  plt.axis('off')
  
  # Plot parameter in textbox below MSD plot
  fig.text(0.1, 0.0, param_str1(params), fontsize=18)
  fig.text(0.4, 0.0, param_str2(params), fontsize=18)

  # Save
  plt.savefig(os.path.join(path, 'overview.png'))
  plt.show()
     
  # Final conf plot
  parts = DataIO.read_parts(os.path.join(path, 'trial1/parts.dat'))
  ax = plt.subplot(gs[:], projection='3d')
  plt.title('Final System Configuration')
  graphics.plot_config(parts, params)
  plt.savefig(os.path.join(path, 'configuration.png'))
  plt.show()

if __name__ == "__main__":
  if(len(sys.argv) < 2):
    print("Usage: python post.py experiment_dir/")
  else:
    main(sys.argv)
