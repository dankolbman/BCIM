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
  if !ispath(path)
    mkpath(path)
  end
  writeConstants(joinpath(path,"param.dat"), pc)
  writeConstants(joinpath(path,"param_dim.dat"),dc)
  l = Log(joinpath(path, "log.txt"))
  # Initialize simulation trials
  trials = Array(Simulation, ntrials)
  for tr = 1:ntrials
    trials[tr] = Simulation(tr, joinpath(path, "trial$tr"), dc, l)
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
