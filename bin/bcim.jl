##
# A brownian colloid (s)imulator
#
# Dan Kolbman
##

import DataIO
import Experiment
using ArgParse

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
end

# Parse arguements from the command line
# Returns
#   A dict with the agruement flags and their values
function parseArgs()
  s = ArgParseSettings()
  s.prog = "bcim"

  @add_arg_table s begin
    "config"
      help = "The configuration file"
      required = true
      arg_type = String
    "-o", "--outdir"
        help = "The directory path to save output to"
        arg_type = String
    "run"
      help = "Run an experiment"
      action = :command
  end
  return parse_args(s)
end
    
# Main function loop
function main()
  parsedArgs = parseArgs()
  # Read the configuration file
  conf = DataIO.readConf(parsedArgs["config"])

  if(parsedArgs["outdir"]!=nothing)
    conf["path"] = parsedArgs["outdir"]
  end
  # Initialize the file sysetm
  initFS(conf)
  # Log
  DataIO.log("Experiment starting...", conf)
  Experiment.run(conf)
end

main()
