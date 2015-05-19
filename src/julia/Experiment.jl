# An experiment handles running identical simulations
# It saves all simulation results inside its path for each one of its trials

type Experiment
  path::String
  trials::Array{Simulation,1}
  dimConst::DimensionlessConst
  l::Log
end

function Experiment(path::String, ntrials::Int64, pc::PhysicalConst)
  dc = DimensionlessConst(pc)
  Experiment(path, ntrials, dc, true)
end

# Experiment from physical constant
function Experiment(path::String, ntrials::Int64, pc::PhysicalConst, timestamp::Bool)
  dc = DimensionlessConst(pc)
  writeConstants(joinpath(path,"param.dat"), pc)
  return Experiment(path, ntrials, dc, timestamp)
end

# Default to a spherical system
function Experiment(path::String, ntrials::Int64, dc::DimensionlessConst, timestamp::Bool)
  return Experiment(path, ntrials, dc, Sphere(dc), timestamp)
end

# Experiment from dimensionless constant
# Params:
#   path - path to experiment directory
#   ntrials - number of identical experiments to run
#   dc - the dimensionless constants for the experiment
#   s - the simulation system
#   timestamp - whether or not to append a timestamp to experiment directory
function Experiment(path::String, ntrials::Int64, dc::DimensionlessConst, s::System, timestamp::Bool)
  if timestamp
    path = "$path-$(strftime("%m-%d-%y-%H%M", time()))"
  end
  # Check if this is a new experiment
  n = 0
  if !ispath(path)
    mkpath(path)
  else
    for f in readdir(path)
      if isdir(joinpath(path, f))
        n+=1
      end
    end
  end
  # Set up log
  l = Log(joinpath(path, "log.txt"))
  if n > 0
    log(l, "Found $n pre-existing trials in experiment directory.")
  end
  # Write out parameters
  writeConstants(joinpath(path,"param_dim.dat"),dc)
  # Initialize simulation trials
  trials = Array(Simulation, ntrials)
  for tr = 1:ntrials
    # Let the simulation find an id and trial directory
    trials[tr] = Simulation(path, s, dc, l)
    #trials[tr] = Simulation(tr, joinpath(path, "trial$tr"), dc, l)
  end
  log(l, "Initialize experiment at $(path)")
  return Experiment(path, trials, dc, l)
end


# Run each simulation
function run(exp::Experiment, r::Range{Int})

  tic()
  log(exp.l, "Starting experiment with $(length(exp.trials)) trials")

  # Run each simulation
  for sim in exp.trials
    run(sim, r)
  end

  log(exp.l, "Finished experiment in $(toq()) seconds")

end
