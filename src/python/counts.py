import numpy as np
from .DataIO import read_parts

def counts(filen, params):
  t = []
  counts = [ [0], [0] ]
  with open(filen, 'r') as f:
    ctime = ''
    for line in f:
      l = line.split()
      if l[0] != ctime and line[0] !='#':
        ctime = l[0]
        t.append( float(l[0]) )
        counts[0].append(0)
        counts[1].append(0)
      elif line[0] != '#':
        sp = int( l[1] ) - 1
        counts[sp][ -1 ] += 1

  counts[0] = counts[0][1:]
  counts[1] = counts[1][1:]
  return t, counts
