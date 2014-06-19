##
# A brownian colloid (s)imulator
#
# Dan Kolbman
##

import DataIO


# Initialize the file system by creating needed directories and files
# Params:
#   conf - the configuration Dict
function initFS(conf)
  path = conf["path"]
  if(!isdir(path))
    mkpath(path)
  # Check for existing data
  elseif(isfile(string(path,"log.txt")))
    println("WARNING: Data exists in the path. Overwrite? (y/n)")
    input = chomp(readline())
    if(input != "y")
      exit()
    end
  end
  # Log
  DataIO.log("Simulation started", conf)
end


function main()
  # Read the configuration file
  conf = DataIO.readConf("defaults.cnf")
  # Initialize the file sysetm
  initFS(conf)
  Experiment.run()
end

main()
