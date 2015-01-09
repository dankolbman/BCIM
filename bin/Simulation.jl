##
# The simulation environment.
# All simulation steps are controlled from here
#
# Dan Kolbman 2014
##

type ExpConst
  nequil::Int
  nstep::Int
  freq::Int
end


type Simulation
  path::ASCIIString
  exp::Experiment
  system::System
end

function Simulation(path::ASCIIString, exp::Experiment)

  
end

# Runs a simulation from start to finish
# Params
#   conf - the configuration dict with experiment parameters
#   simPath - the path for the simulation to store files
function run(sim::Simulation)

  # Initialize system
  parts = initParts(conf, simPath)
  cells = initCells(conf)
  sim.system = System(parts, cells)

  ndata = int(conf["nsteps"]/conf["freq"])
  avgmsd = zeros(Float64, ndata, size(conf["npart"],1)+1)
  tic()
  # Equilibriate
  for s in 1:conf["nequil"]
    # Update cells
    if(s%10 == 1)
      assignParts(conf, parts, cells)
    end
    # Step
    step(conf, parts, cells)
  end

  # Reset particles' origins after equilibrating
  for p in parts
    p.org = p.pos
  end

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
      #print("\r\t"^(myid()*3))
      #print("$(myid()): $(int(s/conf["nsteps"]*100))%   ")

      t = s*conf["dt"]
      DataIO.writeParts("$(conf["path"])$(simPath)parts", parts, t)

      # Calculate msd
      avgmsd[int(s/conf["freq"]), 1] = t
      # avgMSD() updates sq displacements and returns avg msd for all species
      avgmsd[int(s/conf["freq"]), 2:end] = Stats.avgMSD(conf,parts)
    end
  end
  DataIO.writeMSD("$(conf["path"])$(simPath)msd", avgmsd)

  post(conf, parts, simPath)
  
  DataIO.log("Trial ended taking $(toq()) seconds", conf)

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

