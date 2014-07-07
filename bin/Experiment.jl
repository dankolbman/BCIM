##
# A module for experiment procedure and trial functions
# Each experiment consists of one or many identical trial which are run
# then averaged.
#
# Dan Kolbman 2014
##

module Experiment

import DataIO
import Simulation

# Run an experiment by runing a group of identical trials
# Params
#   conf - the configuration dict containing experiment params
#   expPath - the path for the experiment to keep files
function runExp(conf, expPath="")

  # The radius for a sphere with the desired packing fraction
  conf["size"] = 10*cbrt((conf["dia"]/2)^3*conf["npart"][1] / conf["phi"])

  # Write configuration file for the trial
  DataIO.writeConf("$(conf["path"])sim", conf)
  
  procs = Array(Any, int(conf["ntrials"]))
  
  # Run each trial
  # TODO Spawn each trial on a different worker
  for trial in 1:conf["ntrials"]
    DataIO.log("Begin trial $(int(trial))", conf)
    tic()

    Simulation.runSim(conf, "$(expPath)trial$(int(trial))/")
    #p = @spawn Simulation.runSim(conf, "$(expPath)trial$(int(trial))/")
    #procs[trial] = p

    DataIO.log("Trial $(int(trial)) ended taking $(toc())", conf)
    
    if(conf["plot"] == 1)
      path = "$(conf["path"])$(expPath)trial$(int(trial))/initSP1.dat"
      cnf = "$(conf["path"])$(expPath)sim.cnf"
      cmd = `python ../scripts/posplot.py $cnf $path`
      @spawn run(cmd)
    end
  end
  
  # Wait on all processes
  for p in procs
    wait(p)
  end
end

end
