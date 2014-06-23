##
# The simulation environment.
# All simulation steps are controlled from here
#
# Dan Kolbman 2014
##

module Simulation

import DataIO

# Runs a simulation from start to finish
# Params
#   conf - the configuration dict with experiment parameters
function run(conf)
  
  # Initialize simulation
  init(conf)

  for s in 1:conf["nsteps"]
    step(conf)
  end
  
end

# Initializes the physical environment
# Params
#   conf - the configuration dict with experiment parameters
# Returns
#   A particle array
function init(conf)
  # The length of a side of a cube for the required packing fraction
  #conf["size"] = cbrt(4/3*pi*conf["dia"]^3/2/(conf["phi"]))
  # The radius for a sphere with the desired packing fraction
  conf["size"] = cbrt((conf["dia"]/2)^3*conf["npart"] / conf["phi"])
  parts = makeRanSphere(conf)
  DataIO.writeParts("parts.dat",parts)
end

# One simulation step. All forces are calculated, then positions updated
# Params
#   conf - the configuration dict with experiment parameters
function step(conf)
  # Update pos
  pos = [0]
end

# Generates particles randomly inside a sphere
# Params
#   conf - the configuration dict with experiment parameters
# Returns
#   A particle array
function makeRanSphere(conf)
  parts = Array(Float64,int(conf["npart"]), 7)
  for i = 1:int(conf["npart"])
    lam = conf["size"]*cbrt(rand())
    u = 2*rand()-1
    phi = 2*pi*rand()
    xyz = [ lam*sqrt(1-u^2)*cos(phi) lam*sqrt(1-u^2)*sin(phi) lam*u ]
    parts[i,:] = [ xyz 0 0 0 0 ]
  end
  return parts
end

# Generates particles inside a box
# Params
#   conf - the configuration dict with experiment parameters
# Returns
#   A particle array
function makeBox(conf)
  # Number of particles per side
  sideNum = cbrt(ceil((conf["npart"])))
  # Space between particles
  lc = conf["size"]/sideNum
  
  parts = Array(Float64,int(conf["npart"]),7)
  np = 1
  for i = 1:sideNum
    for j = 1:sideNum
      for k = 1:sideNum
        if(np <= int(conf["npart"]))
          parts[np,:] = [ i*lc j*lc k*lc 0 0 0 0 ] 
          np += 1
        end
      end
    end
  end
  return parts
end

# Generate particles randomly in a box
function makeRanBox(conf)
  parts = Array(Float64,int(conf["npart"]),7)
  for i in 1:conf["npart"]
    parts[i,:] = [ conf["size"]*rand(1,3) 0 0 0 0 ]
  end
  return parts
end


end
