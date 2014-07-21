##
# Handles the generation of notebook entries.
#
# Dan Kolbman 2014
##

import time
import os
import sys

def makePage( path, name='Entry' ):
  f = open(os.path.join(path, name+'.md'), 'w')
  print(os.path.join(path,name+'.md'))

  # Contsruct header
  f.write('Title: '+name+'\n')
  f.write('Date: '+time.strftime('%Y-%m-%d %H:%M')+'\n')




# Makes a notebook entry from the files in the  specified path
# Params:
#   path - the path to save the entry to and to locate data
#   name - the name of the entry file to create
def makeEntry( path, name='entry'):
  f = open(os.path.join(path, name+'.md'), 'w')
  print('Writing to '+os.path.join(path,name+'.md'))

  # Contstruct the header

  if(os.path.isfile(os.path.join(path, 'summary.txt'))):
    print('Found summary file...')
  
  if(os.path.isfile(os.path.join(path, 'notes.txt'))):
    print('Found note file...')
  
  if(os.path.isfile(os.path.join(path, 'log.log'))):
    print('Found log file...')
  
  if(os.path.isfile(os.path.join(path, 'sim.cnf'))):
    print('Found configuration file...')
   


if __name__ == '__main__':
  if(len(sys.argv) < 2):
    print('Please specify a path')
  elif(len(sys.argv) == 2):
    makeEntry(sys.argv[1])
  elif(len(sys.argv) > 2):
    makeEntry(sys.arv[0], sys.argv[2])
