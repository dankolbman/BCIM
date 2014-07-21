##
# The simulation environment.
# All simulation steps are controlled from here
#
# Dan Kolbman 2014
##

module Simulation

#using Winston

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
  parts = init(conf, simPath)

  ndata = int(conf["nsteps"]/conf["freq"])
  avgmsd = zeros(Float64, ndata, size(conf["npart"],1)+1)


  # Run each step
  for s in 1:conf["nsteps"]
    # Step
    step(conf, parts)

    # Collect data
    if(s%conf["freq"] == 0)
      print("[")
      print("#"^int(s/conf["nsteps"]*70))
      print("-"^(70-int(s/conf["nsteps"]*70)))
      print("] $(int(s/conf["nsteps"]*100))%\r")

      t = s*conf["dt"]
      #DataIO.writeParts("$(conf["path"])/$(simPath)parts$(int(s))", parts)
      DataIO.writeParts("$(conf["path"])$(simPath)parts", parts, t)

      # Calculate msd
      avgmsd[int(s/conf["freq"]), 1] = t
      # avgMSD() updates sq displacements and returns avg msd for all species
      avgmsd[int(s/conf["freq"]), 2:end] = Stats.avgMSD(conf,parts)

      #DataIO.log("Write g(r)", conf)
      #gr = Stats.gr(parts, conf)
      #writedlm("$(conf["path"])/$(simPath)gr$(int(s)).dat",gr)

      #p1 = plot(avgmsd[:,1],avgmsd[:,2])
      #display(p1)

      if(false)#conf["plot"] == 1)
        path = "$(conf["path"])$(simPath)parts$(int(s)).dat"
        #path = "$(conf["path"])$(simPath)parts.dat"
        cnf = "$(conf["path"])sim.cnf"
        cmd = `python ../scripts/posplot.py $cnf $path`
        #@spawn run(cmd)
      end
    end
  end
  #savefig("awsome.png")
  #println("Press enter to continue: ")
  #readline(STDIN)
  println()
  DataIO.writeMSD("$(conf["path"])$(simPath)avgMSD", avgmsd)

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
function init(conf, simPath="")
  # The length of a side of a cube for the required packing fraction
  #conf["size"] = cbrt(4/3*pi*conf["dia"]^3/2/(conf["phi"]))
  parts = makeRanSphere(conf)
  DataIO.writeParts("$(conf["path"])/$(simPath)init",parts)

  return parts
end

# Runs post processing after the simulation has ended
# Params
# conf - the configuration dict
# simPath the path of the simulation
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
  # Creates an array for all the particles
  parts = Array(Part, int(conf["tpart"]))
  # Number of particles placed
  pl = 0
  # Iterate through each species
  for sp in 1:length(conf["npart"])
    for p = 1:int(conf["npart"][sp])
      # This creates a uniform distribution in the sphere
      lam = (conf["size"]-conf["dia"]/2)*cbrt(rand())
      u = 2*rand()-1
      phi = 2*pi*rand()
      xyz = [ lam*sqrt(1-u^2)*cos(phi), lam*sqrt(1-u^2)*sin(phi), lam*u ]
      parts[pl+p] = Part(sp, xyz, [0, 0, 0], 2*pi*rand(2))
    end
    pl += int(conf["npart"][sp])
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
