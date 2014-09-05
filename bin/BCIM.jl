##
# A brownian colloid (s)imulator
#
# Dan Kolbman
##

import DataIO
import Experiment
using ArgParse

require("Types.jl")
require("Notebook.jl")

# Initialize the file system by creating needed directories and files
# Params:
#   conf - the configuration Dict
function initFS(conf)
  path = conf["path"]
  # Create a new folder for this run in the path
  if(conf["autodir"]==1)
    #n = 1
    # Find a suitable directory name
    # TODO might want to use temporal naming
    #while(ispath("$(path)experiment$n"))
    #  n+=1
    #end
    #mkpath("$(path)experiment$n")
    #conf["path"] = "$(path)experiment$n/"

    # Using date-time
    dir = "$(path)$(strftime("%m-%d-%y-%H%M", time()))"
    mkpath(dir)
    conf["path"] = "$dir/"
    
  elseif(!isdir(path))
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

# Creates a default configuration
# Returns
#   A configuration dict with nondimensional units
function defaultConf()
  conf = Dict{String, Any}()
  # Program params
  conf["path"] = "../data/"
  conf["autodir"] = 1
  conf["verbose"] = 1
  conf["ocl"] = 1
  conf["dim"] = 2
  conf["ntrials"] = 1
  conf["nequil"] = 100000
  conf["nsteps"] = 100000
  conf["freq"] = 1000

  # Plotting
  conf["plot" ] = 1
  conf["postSimPy"] = ""
  conf["postExpPy"] = ""
  conf["postPy"] = ""
  conf["editor"] = "vim"
  conf["ignorenotebook"] = 0
  conf["notebook"] = "../notebook/generator.py"
  conf["pelican"] = "../site/"

  conf["numbins"] = 200

  # Simulation params
  conf["npart"] = {512,512}
  conf["phi"] = 0.40      # Packing frac
  conf["eta"] = 1.0e-2    # g / (cm s)
  conf["dt"] = 1.0e-4     # s
  conf["temp"] = 298.0    # K
  conf["boltz"] = 1.38e-16 # erg / K
  # Diameter of particles
  conf["dia"] = 15.0e-4   # g / (cm s)
  # Radius of boundary (this gets overwritten by Experiment.runExp())
  conf["size"] = 1.0

  conf["diffus"] = conf["boltz"]*conf["temp"]/(3*pi*conf["eta"]*conf["dia"])
  conf["rotdiffus"] = 500*conf["boltz"]*conf["temp"]/(
    pi*conf["eta"]*conf["dia"]^3)

  # Coefficients
  conf["prop"] = [ 1.0e3, 1.0e3 ]   # length / difftime
  conf["rep"] = [ 1.5e4, 0.5e4 ] # energy / length
  conf["adh"] = [ 0.01, 0.01 ]   # energy / length
  conf["contact"] = 0.1 # length

  return conf
end

# Dedimensionalize all constants in configuration
# Params
#   conf - the configuration dict
# Returns
#   A configuration dict with nondimensional units
function dedimension(conf)
  conf["contact"] = conf["dia"]*conf["contact"]
  push!(conf["rep"], 2*conf["rep"][1]*conf["rep"][2]/sum(conf["rep"]))
  # Dimensionless units
  conf["utime"] = (conf["dia"])^2/conf["diffus"]
  conf["ulength"] = conf["dia"]
  conf["uenergy"] = conf["boltz"]*conf["temp"]
  conf["rotdiffus"] = conf["rotdiffus"]*conf["utime"]
  conf["diffus"] = conf["diffus"]*conf["utime"]/(conf["ulength"]^2)
  conf["dia"] = conf["dia"]./conf["ulength"]
  conf["dt"] = conf["dt"]/conf["utime"]
  conf["rep"] = conf["rep"]./conf["ulength"]
  conf["contact"] = conf["contact"]./conf["ulength"]
  conf["adh"] = conf["adh"]./conf["contact"]
  conf["pretrad"] = sqrt(2.0/conf["dt"])
  conf["prerotd"] = sqrt(2.0*conf["rotdiffus"]*conf["dt"])

  conf["tpart"] = sum(conf["npart"])

  return conf
end

# Syncronize the lab book website
function putSite(conf)
    p = pwd()
    cd(conf["pelican"])
    run(`make ftp_upload`)
    cd(p)
end

# Gets all newer files from the server
function getSite(conf)
    p = pwd()
    cd(conf["pelican"])
    run(`make ftp_mirror`)
    cd(p)
end

# Run command
# Runs a simulation batch
# Params:
#   args - parsedArgs dictionary
function runSim(args, conf)
  # Initialize the file sysetm
  initFS(conf)
  # Make a copy of the configuration file
  cp(args["config"], "$(conf["path"])batch.cnf")
  # Get the number of experiments in the batch
  nExperiments = DataIO.getNumExp(args["config"])
  DataIO.readConf(args["config"], conf, 1)

  # If no experiment separators present, assume 1 experiment
  if(nExperiments == 0)
    nExperiments = 1
  end
  
  DataIO.log("$nExperiments experiment(s) found", conf)

  if( conf["ignorenotebook"] == 0 )
    s = @spawn writeSummary(conf)
  end

  # Run each experiment
  for experiment in 1:nExperiments
    # Fetch parameters for current experiment
    DataIO.readConf(args["config"], conf, experiment)
    # De-dimensionalise parameters
    dedimension(conf)
    # Log
    DataIO.log("Experiment $experiment starting...", conf, )
    DataIO.log("Experiment path at $(conf["path"])experiment$experiment/", conf)
    
    Experiment.runExp(conf, "experiment$experiment/")
  end

  post(conf)

  if( conf["ignorenotebook"] == 0 )
    # Wait for summary and notes entry to end
    n = @spawn writeNotes(conf)
    fetch(s)
    fetch(n)
  end
  
  println("Would you like to publish the summary to the lab book? (y/N)")
  publish = chomp(readline())
  # Generate a markdown file for the notebook
  if( lowercase(publish) == "y")
    run(`python $(conf["notebook"]) $(conf["path"])`)
  else
    run(`python $(conf["notebook"]) $(conf["path"]) draft`)
  end
  
  println("Would you like to sync with the lab book web server? (y/N)")
  sync = chomp(readline())
  if( lowercase(sync) == "y" )
    putSite(conf)
  end
end

# Run post processing for the batch
# Params
#   conf - the configuration dict
function post(conf)
  if(conf["postPy"] != "")
    path = "$(conf["path"])"
    cnf = "$(conf["path"])batch.cnf"
    cmd = `python $(conf["postPy"]) $cnf $path`
    run(cmd)
  end
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
  # Take care of ftp stuff
  # TODO command actions should be moved outside of main
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
