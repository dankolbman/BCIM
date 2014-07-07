##
# The simulation environment.
# All simulation steps are controlled from here
#
# Dan Kolbman 2014
##

module Simulation

import DataIO
import Dynamics

# Runs a simulation from start to finish
# Params
#   conf - the configuration dict with experiment parameters
#   simPath - the path for the simulation to store files
function runSim(conf, simPath="")
  
  # Initialize simulation
  parts = init(conf, simPath)

  # Run each step
  for s in 1:conf["nsteps"]
    step(conf, parts)
    # Collect data
    if(s%conf["freq"] == 0)
      DataIO.writeParts("$(conf["path"])/$(simPath)parts$(int(s))", parts,1)
      #DataIO.writeParts("$(conf["path"])/$(simPath)parts", parts,1)
      println("Done step $s")
      if(conf["plot"] == 1)
        path = "$(conf["path"])$(simPath)parts$(int(s)).dat"
        cnf = "$(conf["path"])sim.cnf"
        cmd = `python ../scripts/posplot.py $cnf $path`
        #@spawn run(cmd)
      end
      
    end
  end
  
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
function init(conf, simPath="")
  # The length of a side of a cube for the required packing fraction
  #conf["size"] = cbrt(4/3*pi*conf["dia"]^3/2/(conf["phi"]))
  parts = makeRanSphere(conf)
  DataIO.writeParts("$(conf["path"])/$(simPath)init",parts)

  return parts
end

# One simulation step. All forces are calculated, then positions updated
# Params
#   conf - the configuration dict with experiment parameters
function step(conf,parts)
  # Update pos
  Dynamics.forceCalc(conf, parts)
end

# Generates particles randomly inside a sphere
# Params
#   conf - the configuration dict with experiment parameters
# Returns
#   A particle species array
function makeRanSphere(conf)
  # Create an array of particle matricies for each species
  parts = Array(Any, length(conf["npart"]))
  # Appearently can't specify arrays of arrays of floats?
  #parts = Array(Array{Float64}, length(conf["npart"])) 
  # Iterate through each species
  for sp in 1:length(conf["npart"])
    # An array for all particles in the species
    spn = Array(Float64,int(conf["npart"][sp]), 9)
    for i = 1:int(conf["npart"][sp])
      # This creates a uniform distribution in the sphere
      lam = (conf["size"]-conf["dia"]/2)*cbrt(rand())
      u = 2*rand()-1
      phi = 2*pi*rand()
      xyz = [ lam*sqrt(1-u^2)*cos(phi) lam*sqrt(1-u^2)*sin(phi) lam*u ]
      # Write the particle array
      spn[i,:] = [ xyz 0 0 0 2*pi*rand() 2*pi*rand() 0 ]
    end
    parts[sp] = spn
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
  sideNum = cbrt(ceil((conf["npart"])))
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

end
