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
function run(conf, expPath="")
  
  # TODO Spawn each trial on a different worker
  for trial in 1:conf["ntrials"]
    DataIO.log("Begin trial $(int(trial))", conf)

    # The radius for a sphere with the desired packing fraction
    conf["size"] = 10*cbrt((conf["dia"]/2)^3*conf["npart"][1] / conf["phi"])

    # Write configuration file for the trial
    DataIO.writeConf("$(conf["path"])sim", conf)

    Simulation.run(conf, "$expPath/trial$(int(trial))/")
  end
end


end
