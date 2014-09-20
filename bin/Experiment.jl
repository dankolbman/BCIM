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
import Stats
#import SimCL

# Run an experiment by runing a group of identical trials
# Params
#   conf - the configuration dict containing experiment params
#   expPath - the path for the experiment to keep files
function runExp(conf, expPath="")

  # The radius for a sphere with the desired packing fraction
  #conf["size"] = cbrt((conf["dia"]/2)^3*conf["npart"][1] / conf["phi"])
  conf["size"] = sqrt((conf["dia"]/2)^2*conf["tpart"] / conf["phi"])

  # Write configuration file for the trial
  DataIO.writeConf("$(conf["path"])$(expPath)sim", conf)
  
  procs = Array(Any, int(conf["ntrials"]))
  
  # Run each trial
  # TODO Spawn each trial on a different worker
  for trial in 1:conf["ntrials"]
    DataIO.log("Begin trial $(int(trial))", conf)
    tic()

    if(conf["ocl"] == 1)
      SimCL.runSim(conf, "$(expPath)trial$(int(trial))/")
    else
      Simulation.runSim(conf, "$(expPath)trial$(int(trial))/")
    end

    #p = @spawn Simulation.runSim(conf, "$(expPath)trial$(int(trial))/")
    #procs[trial] = p

    DataIO.log("Trial $(int(trial)) ended taking $(toq())", conf)

  end
  
  post(conf, expPath)
  
  # Wait on all processes
  #for p in procs
    #wait(p)
  #end
end

# Run at the end of every experiment
function post(conf, expPath)

  # Find all the g(r) data files
  grfiles::Array{String} = []
  for i in 1:int(conf["ntrials"])
      path  = "$(conf["path"])$(expPath)trial$(i)/gr.dat"
      prepend!(grfiles, [path])
  end
  # Average all the g(r) functions
  gr = Stats.avgGR(conf, grfiles)
  writedlm("$(conf["path"])$(expPath)avgGR.dat", gr)

  # Find all the msd data files
  msdfiles::Array{String} = []
  for i in 1:int(conf["ntrials"])
      path  = "$(conf["path"])$(expPath)trial$(i)/msd.dat"
      prepend!(msdfiles, [path])
  end
  # Average all msd functions
  msd = Stats.avgMSD(conf, msdfiles)
  writedlm("$(conf["path"])$(expPath)avgMSD.dat", msd)
  
  if(conf["postExpPy"] != "")
    path = "$(conf["path"])$(expPath)"
    cnf = "$(conf["path"])$(expPath)sim.cnf"
    cmd = `python $(conf["postExpPy"]) $cnf $path "$(conf["expName"])"`
    run(cmd)
  end
end

end
