"""
  Read and write operations for python scripts.
  
  readPos - Read position data
  readMsdave - Read average mean squared displacement
  readGr - Read g(r) data
  readConf - Read system configuration data
  Dan Kolbman 2014
"""
import sys
import re
import numpy as np


class Part:
  def __init__(self, sp, x, v, ang):
    self.sp = int(sp)
    self.x = x
    self.v = v
    self.ang = ang

  def v2(self):
    return self.x[0]**2 + self.x[1]**2 + self.x[2]**2

def read_parts(filen, state=1):
  """ readParts : String Int -> Part[]
  Read particles in from the state specified from the last state
  ie state = 1 will read the last state
     state = 2 will read the second to last state...

  Parameters
  ----------
  filen - The path to the file containing particle data output
  state=1 - What state of the system to read in, from the bottom of the file.
          state=1 corresponds to the last state in the file
  Returns
  -------
    A list of particle types
  """
  parts = []
  try:
    f = open(filen)
    lines = list(f)
    # get rid of the unwanted states
    if(state-1 > 0):
      curr_state = 0
      while (curr_state < state):
        line = lines.pop()
        if(line[0] == "#"):
          curr_state += 1

    lines = reversed(lines)

    for line in lines:
      if line[0] != "#":
        l = line.split()
        vals = [ float(x) for x in l ]
        p = Part(vals[1], vals[2:5], vals[5:8], vals[8:10])
        parts.append(p)
      else:
        break
  except IOError as e:
    print('IO Error!', e.strerror)
  return parts
        

def readPos(filen, state=0):
  """ readPos : String -> float[] float[] float[] float[]
  Read position data from a file and return x y and z lists
  """
  t = []
  sp=[]
  xpos=[]
  ypos=[]
  zpos=[]
  try:
    f = open(filen)
    lines = list(f)
    if( state > 0):
      curr_state = 0
      while (curr_state < state):
        line = lines.pop()
        l = line.split()
        if(l[0][0] == '#'):
          curr_state += 1
    # We've been popping them off the end of the file so now we should reverse
    # So we can use an iterator from the end
    lines = reversed(lines)

    for line in lines:
      l = line.split()
      if l[0][0] != '#':
        if len(l) < 3: break
        t.append(float(l[0]))
        sp.append(int(l[1]))
        xpos.append(float(l[2]))
        ypos.append(float(l[3]))
        zpos.append(float(l[4]))
      else:
        break
    f.close()
  except IOError as e:
    print('IO Error!', e.strerror)
  return t, sp, xpos,ypos,zpos

def readPos2D(filen, state=-1):
  """ readPos2D : String int -> float[] float[]
  Read position data from a file and return x and y lists
  Read the last state by default, or a specified state
  """
  sp = []
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
        sp.append(int(l[1]))
        xpos.append(float(l[2]))
        ypos.append(float(l[3]))

      # Scan for wanted state
      if(line[0] == "#"): numstates+=1
      # If on the wanted state
      elif( numstates == state ):
        l = line.split()
        sp.append(int(l[1]))
        xpos.append(float(l[2]))
        ypos.append(float(l[3]))
      # If we passed the wanted state, get out
      elif( numstates > state): break
    f.close()
  except IOError as e:
    print('IO Error!', e.strerror)

  return sp,xpos,ypos

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
        msd.append([ float(i) for i in l ])
        #msd.append([ float(i) for i in l ])
    f.close()
  except IOError as e:
    print('IO Error!', e.strerror)
  return np.array(msd)

def readGr(filen):
  """ readGr : String -> float[] float[]
  Reads radial distribution function data from file
  Expected file format:
  run iteration time r g(r)
  """
  gr=[]
  try:
    f = open(filen)
    for line in f:
      l = line.split()
      gr.append([ float(i) for i in l ])
    f.close()
  except IOError as e:
    print('IO Error!', e.strerror)
  return np.array(gr)

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

if __name__ == '__main__':
  print('This is a file containing only helper functions. See source')
