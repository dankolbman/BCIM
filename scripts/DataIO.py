"""
  Read and write operations for python scripts.
  
  readPos - Read position data
  readMsdave - Read average mean squared displacement
  readGr - Read g(r) data
  readConf - Read system configuration data
  i
  Dan Kolbman 2014
"""
import sys
import re
import numpy as np

def readPos(filen):
  """ readPos : String -> float[] float[] float[]
  Read position data from a file and return x y and z lists
  """
  xpos=[]
  ypos=[]
  zpos=[]
  try:
    f = open(filen)
    for line in f:
      if line[0] != "#":
        l = line.split()
        if len(l) < 3: break
        xpos.append(float(l[2]))
        ypos.append(float(l[3]))
        zpos.append(float(l[4]))
    f.close()
  except IOError as e:
    print('IO Error!', e.strerror)
  return xpos,ypos,zpos

def readPos2D(filen, state=-1):
  """ readPos2D : String int -> float[] float[]
  Read position data from a file and return x and y lists
  Read the last state by default, or a specified state
  """
  xpos=[]
  ypos=[]
  try:
    f = open(filen)
    # Read from bottom if looking for last state
    lines = reversed(list(f)) if state == -1 else list(f)
    numstates = -1

    for line in lines:
      # Bottom up
      if(state == -1):
        if(line[0] == "#"): break
        l = line.split()
        xpos.append(float(l[2]))
        ypos.append(float(l[3]))

      # Scan for wanted state
      if(line[0] == "#"): numstates+=1
      # If on the wanted state
      elif( numstates == state ):
        l = line.split()
        xpos.append(float(l[2]))
        ypos.append(float(l[3]))
      # If we passed the wanted state, get out
      elif( numstates > state): break
    f.close()
  except IOError as e:
    print('IO Error!', e.strerror)

  return xpos,ypos

def readAvgMSD(filen):
  """ readAvgMsd : String -> float[]
  Read averaged mean square displacement data and return time, msd data
  """
  msd=[]
  try:
    f = open(filen)
    for line in f:
      if line[0] != "#":
        l = line.split()
        msd.append([ float(l[0]), float(l[1]) ])
        #msd.append([ float(i) for i in l ])
  except IOError as e:
    print('IO Error!', e.strerror)
  f.close()
  return np.array(msd)

def readGr(filen):
  """ readGr : String -> float[] float[]
  Reads radial distribution function data from file
  Expected file format:
  run iteration time r g(r)
  """
  r=[]
  gr=[]
  try:
    f = open(filen)
    for line in f:
      l = line.split()
      if(len(l) >= 4):
        r.append(float(l[3]))
        gr.append(float(l[4]))
  except IOError as e:
    print('IO Error!', e.strerror)
  f.close()
  return r,gr

def readConf(filen):
  """ readConf : String -> Dict
  Reads a system parameter file and returns a dictionary with param val keys
  """
  conf=dict() 
  try:
    f = open(filen)
    for line in f:
      l = line.split()
      # Simple one value param
      if(len(l) == 2):
        if(re.fullmatch("[0-9e\.]*",l[1]) != None):
          conf[l[0]] = float(l[1])
      # If there is more than one value for the param
        else:
          conf[l[0]] = l[1]
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
        conf[l[0]] = val
  except IOError as e:
    print('Could not process file', e.strerror)
  return conf

if __name__ == '__main__':
  print('This is a file containing only helper functions. See source')
