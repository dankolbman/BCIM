##
# The simulation environment.
# All simulation steps are controlled from here
#
# Dan Kolbman 2014
##

module Simulation

import DataIO

# Runs a simulation from start to finish
# Params
#   conf - the configuration dict with experiment parameters
function run(conf)
  
  # Initialize simulation
  init(conf)

  for s in 1:conf["nsteps"]
    step(conf)
  end
  
end

# Initializes the physical environment
# Params
#   conf - the configuration dict with experiment parameters
function init(conf)

end

# One simulation step. All forces are calculated, then positions updated
# Params
#   conf - the configuration dict with experiment parameters
function step(conf)
  # Update pos
  pos = [0]
end


end
