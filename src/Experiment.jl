type Experiment
  path::ASCIIString
  trials::Array{Simulation,1}
  dimConst::DimensionlessConst
end

function Experiment(path::ASCIIString, ntrials::Int64, dc::DimensionlessConst)
  # Initialize simulation trials
  trials = Array(Simulation, ntrials)
  for tr = 1:ntrials
    trials[tr] = Simulation(joinpath(path, "trial$tr"), dc)
  end
  return Experiment(path, trials, dc)
end

function run(exp::Experiment, r::Range{Int})
  # Run each simulation
  for sim in exp.trials
    run(sim, r)
  end
end

function post(Experiment)

end
