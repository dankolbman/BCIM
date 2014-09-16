##
# The simulation environment.
# All simulation steps are controlled from here
#
# Dan Kolbman 2014
##

module Simulation

#import OpenCL
#const cl = OpenCL

import DataIO
import Dynamics
import Stats

include("Types.jl")

# Runs a simulation from start to finish
# Params
#   conf - the configuration dict with experiment parameters
#   simPath - the path for the simulation to store files
function runSim(conf, simPath="")

  # Initialize simulation
  parts = initParts(conf, simPath)
  cells = initCells(conf)

  ndata = int(conf["nsteps"]/conf["freq"])
  avgmsd = zeros(Float64, ndata, size(conf["npart"],1)+1)

  # Run each step
  for s in 1:conf["nsteps"]

    # Update cells
    if(s%10 == 1)
      assignParts(conf, parts, cells)
    end
    # Step
    step(conf, parts, cells)
    
    # Collect data
    if(s%conf["freq"] == 0)
      print("[")
      print("#"^int(s/conf["nsteps"]*70))
      print("-"^(70-int(s/conf["nsteps"]*70)))
      print("] $(int(s/conf["nsteps"]*100))%\r")

      t = s*conf["dt"]
      DataIO.writeParts("$(conf["path"])$(simPath)parts", parts, t)

      # Calculate msd
      avgmsd[int(s/conf["freq"]), 1] = t
      # avgMSD() updates sq displacements and returns avg msd for all species
      avgmsd[int(s/conf["freq"]), 2:end] = Stats.avgMSD(conf,parts)
    end
  end
  println()
  DataIO.writeMSD("$(conf["path"])$(simPath)msd", avgmsd)

  post(conf, parts, simPath)

end

# Initializes the physical environment
# Determine size of the system
# Generate particles
# Write data to file
# Params
#   conf - the configuration dict with experiment parameters
#   simPath - the path for the simulation to store files
# Returns
#   A particle array
function initParts(conf, simPath="")
  parts = makeRanSphere(conf)
  DataIO.writeParts("$(conf["path"])/$(simPath)init",parts)
  return parts
end

# Initialize neighbor cells
# Params
#   conf - the configuration dict
function initCells(conf)
  # Determine number of cells along a dimension
  conf["D"] = conf["dia"]*(2*conf["contact"]+1)
  conf["D"] = int(conf["size"]*2 / conf["D"])
  D = conf["D"]
  tCell = D*D*D
  cellGrid = Array(Cell, D, D, D)
  # Create cells
  for i in 1:tCell
    cell = Cell(i, Array(Cell,0), Array(Part,0))
    cellGrid[i] = cell
  end
  # Link cells
  for dep in 1:D
    for col in 1:D
      for row in 1:D
        n = [cellGrid[row,col,dep]]         # Add self reference
        for d in -1:1
          for c in -1:1
            for r in -1:1
              if( d != 0 && c != 0 && r != 0)
                if(getNeighbor(cellGrid, r, c,d, D) != None)
                  push!(n, getNeighbor(cellGrid, r, c, d, D))   # Beautiful
                end
              end
            end
          end
        end
        cellGrid[row,col,dep].neighbors = n # Neighbor list update
      end
    end
  end
  return cellGrid
end

# Gets a cell at the given location after checking that it is in bounds
# Parameters:
#   cellGrid - The 3D grid of cells to get a cell from
#   row - The row coordinate
#   col - The col coordinate
#   dep - The depth cordinate
#   D - The number of cells per dimension
# Returns:
#   A cell or None if request coord is out of bounds
function getNeighbor( cellGrid, row, col, dep, D )
  if( row > 0 && col > 0 && dep > 0 && row <= D && col <= D && dep <= D)
    return cellGrid[row, col, dep]
  else
    return None
  end
end

# Assign particles to cells
# Params
#   conf - the configuration dict
#   parts - the particle array
#   cellGrid - an N dimensional array of cells
function assignParts(conf, parts, cellGrid)
  cSize = conf["size"]*2 / conf["D"]
  D = conf["D"]
  # Clear all current particle lists for cells
  for c in cellGrid
    c.parts = Array(Part, 0)
  end
  for p in parts
    pos = p.pos + [conf["size"], conf["size"], conf["size"]]
    hash = (div(pos[1], cSize) + div(pos[2], cSize)*D
            + div(pos[3], cSize)*D*D + 1)
    hash = int(hash)
    push!(cellGrid[hash].parts, p)
  end
end

# Runs post processing after the simulation has ended
# Params
#   conf - the configuration dict
#   simPath the path of the simulation
function post(conf, parts, simPath="")
  gr = Stats.gr(conf, parts)
  writedlm("$(conf["path"])$(simPath)gr.dat", gr)
  if(conf["postSimPy"] != "")
    path = "$(conf["path"])$(simPath)"
    cnf = "$(conf["path"])$(simPath)../sim.cnf"
    cmd = `python $(conf["postSimPy"]) $cnf $path`
    run(cmd)
  end
end

# One simulation step. All forces are calculated, then positions updated
# Params
#   conf - the configuration dict with experiment parameters
#   parts - the particle array
#   cellGrid - an N dimensional array of cells
function step(conf, parts, cells)
  # Update pos
  Dynamics.forceCalc(conf, parts, cells)
end

# Generates particles randomly inside a sphere
# Params
#   conf - the configuration dict with experiment parameters
# Returns
#   A particle species array
function makeRanSphere(conf)
  # Creates an array for all the particles
  parts = Array(Part, int(conf["tpart"]))
  # Number of particles placed
  pl = 1
  # Iterate through each species
  for sp in 1:length(conf["npart"])
    for p = 1:int(conf["npart"][sp])
      # This creates a uniform distribution in the sphere
      lam = (conf["size"]-conf["dia"]/2)*cbrt(rand())
      u = 2*rand()-1
      phi = 2*pi*rand()
      xyz = [ lam*sqrt(1-u^2)*cos(phi), lam*sqrt(1-u^2)*sin(phi), lam*u ]
      parts[pl] = Part(pl, sp, xyz, [0, 0, 0], 2*pi*rand(2))
      pl += 1
    end
    #pl += int(conf["npart"][sp])
  end
  return parts
end

# Generates particles inside a box
# TODO Update to new particle format
# Params
#   conf - the configuration dict with experiment parameters
# Returns
#   A particle array
function makeBox(conf)
  # Number of particles per side
  sideNum = cbrt(ceil((conf["tpart"])))
  # Space between particles
  lc = conf["size"]/sideNum
  # An array of parcicle arrays for each species
  parts = Array(Float64,length(conf["npart"]))
  # Number of particles placed so far
  np = 1
  # Iterate through each species
  for sp in 1:int(conf["npart"])
    # Place on lattice
    for i = 1:sideNum
      for j = 1:sideNum
        for k = 1:sideNum
          if(np <= int(conf["npart"][sp]))
            parts[np,:] = [ i*lc j*lc k*lc 0 0 0 2*pi*rand() 2*pi*rand() 0 ] 
            np += 1
          end
        end
      end
    end
  end
  return parts
end

# Generate particles randomly in a box
function makeRanBox(conf)
  # An array of particle arrays for each species
  parts = Array(Any,length(conf["npart"]))
  # Iterate each species
  for sp in 1:length(conf["npart"])
    # The particle array for this species
    spn = Array(Float64,int(conf["npart"][sp]))
    # Make each particle
    for i in 1:conf["npart"][sp]
      xyz = [ (conf["size"]-conf["dia"])*rand(1,3) ] + ones(1,3)*conf["dia"]/2.0
      parts[sp][i,:] = [ xyz 0 0 0 2*pi*rand() 2*pi*rand() 0 ]
    end
  end
  return parts
end

function test()
  println("Test scoping of particle type")
  part = Part(1, rand(2), rand(2), rand(1), 0.0)
  print(part)
end

end
