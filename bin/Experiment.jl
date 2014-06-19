##
# A module for experiment procedure and trial functions
# Each experiment consists of one or many identical trial which are run
# then averaged.
#
# Dan Kolbman 2014
##

module Experiment

# Run an experiment by runing a group of identical trials
# Params
#   conf - the configuration dict containing experiment params
function run(conf)
  
  # TODO Spawn each trial on a different worker
  for trial in 1:conf["ntrials"]
    DataIO.log(string("Begin trial ", trial), conf)
  end
end


end
