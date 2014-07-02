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

def readPos(filen):
  """ readPos : String -> float[] float[]
  Read position data from a file and return x and y lists
  """
  xpos=[]
  ypos=[]
  zpos=[]
  try:
    f = open(filen)
    for line in f:
      l = line.split()
      if len(l) < 3: break
      xpos.append(float(l[0]))
      ypos.append(float(l[1]))
      zpos.append(float(l[2]))
  except IOError as e:
    print('IO Error!', e.strerror)
  f.close()
  return xpos,ypos,zpos

def readMsdave(filen):
  """ readMsdave : String -> float[] float[]
  Read averaged mean square displacement data and return time, msd data
  """
  time=[]
  msd=[]
  try:
    f = open(filen)
    for line in f:
      l = line.split()
      if len(l) < 4: break
      time.append(float(l[2]))
      msd.append(float(l[3]))
  except IOError as e:
    print('IO Error!', e.strerror)
  f.close()
  return time, msd

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
