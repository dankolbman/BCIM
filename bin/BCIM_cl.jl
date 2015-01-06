##
# A command line interface for BCIM
#
# Dan Kolbman
##

using ArgParse
using BCIM

# Parse arguements from the command line
# Returns
#   A dict with the agruement flags and their values
function parseArgs()
  s = ArgParseSettings()
  s.prog = "bcim"

  @add_arg_table s begin
    "-c", "--config"
      help = "The configuration file"
      arg_type = String
    "-o", "--outdir"
        help = "The directory path to save output to"
        arg_type = String
    "run"
      help = "Run an experiment"
      action = :command
    "put"
      help = "Put lab book to server"
      action = :command
    "get"
      help = "Get all newer files from server (May overwrite old files)"
      action = :command
  end
  return parse_args(s)
end

# Main program
# First generate a default configuration with defaults for all variables
# Parse arguements and read user config and save to the directory
# Create necesarry file structure and figure out how many experiments to run
# Run each experiment with appropriate params
function main()
  # Get the arguements passed to the program
  parsedArgs = parseArgs()
  # Generate default params
  conf = defaultConf()
  # Need a config
  if(parsedArgs["config"]==nothing)
    error("Please specifiy a configuration file with the -o flag")
  end
  # Override path if specified from cli
  if(parsedArgs["outdir"]!=nothing)
    conf["path"] = parsedArgs["outdir"]
  end
  if( parsedArgs["%COMMAND%"] == "run" )
    runSim(parsedArgs, conf)
  elseif( parsedArgs["%COMMAND%"] == "put" )
    DataIO.readConf(parsedArgs["config"], conf, 1)
    putSite(conf)
  elseif( parsedArgs["%COMMAND%"] == "get" )
    DataIO.readConf(parsedArgs["config"], conf, 1)
    getSite(conf)
  end
end
main()

