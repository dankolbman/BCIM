type Experiment
  path::ASCIIString
  trials::Array{Simulation,1}
  dimConst::DimensionlessConst
  l::Log
end

function Experiment(path::ASCIIString, ntrials::Int64, pc::PhysicalConst)
  Experiment(path, ntrials, pc, true)
end

function Experiment(path::ASCIIString, ntrials::Int64, pc::PhysicalConst, timestamp::Bool)
  dc = DimensionlessConst(pc)
  if timestamp
    path = "$path-$(strftime("%m-%d-%y-%H%M", time()))"
  end
  # Set up log
  l = Log(joinpath(path, "log.txt"))
  # Check if this is a new experiment
  if !ispath(path)
    mkpath(path)
  else
    n = 0
    for f in readdir(path)
      if isdir(joinpath(path, f))
        n+=1
      end
    end
    log(l, "Found $n pre-existing trials in experiment directory.")
  end
  # Write out parameters
  writeConstants(joinpath(path,"param.dat"), pc)
  writeConstants(joinpath(path,"param_dim.dat"),dc)
  # Initialize simulation trials
  trials = Array(Simulation, ntrials)
  for tr = 1:ntrials
    # Let the simulation find an id and trial directory
    trials[tr] = Simulation(path, dc, l)
    #trials[tr] = Simulation(tr, joinpath(path, "trial$tr"), dc, l)
  end
  log(l, "Initialize experiment at $(path)")
  return Experiment(path, trials, dc, l)
end

function run(exp::Experiment, r::Range{Int})

  tic()
  log(exp.l, "Starting experiment with $(length(exp.trials)) trials")

  # Run each simulation
  for sim in exp.trials
    run(sim, r)
  end

  log(exp.l, "Finished experiment in $(toq()) seconds")

end
