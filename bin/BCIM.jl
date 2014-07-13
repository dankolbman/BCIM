##
# A brownian colloid (s)imulator
#
# Dan Kolbman
##

import DataIO
import Experiment
using ArgParse

require("Types.jl")

# Initialize the file system by creating needed directories and files
# Params:
#   conf - the configuration Dict
function initFS(conf)
  path = conf["path"]
  # Create a new folder for this run in the path
  if(conf["autodir"]==1)
    n = 1
    # Find a suitable directory name
    # TODO might want to use temporal naming
    while(ispath("$(path)experiment$n"))
      n+=1
    end
    mkpath("$(path)experiment$n")
    conf["path"] = "$(path)experiment$n/"

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
  conf["ocl"] = 0
  conf["dim"] = 2
  conf["ntrials"] = 1
  conf["nsteps"] = 10000
  conf["freq"] = 100

  # Plotting
  conf["plot" ] = 1
  conf["posplot"] = "../scripts/posplot.py"
  conf["msdplot"] = "../scripts/msdplot.py"

  conf["numbins"] = 200

  # Simulation params
  conf["npart"] = {400.0,1.0}
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
  conf["prop"] = [ 0.01, 1.0 ]   # length / difftime
  conf["rep"] = [ 0.001, 0.001 ] # energy / length
  conf["adh"] = [ 0.01, 0.01 ]   # energy / length
  conf["contact"] = [ 0.1, 0.1 ] # length


  return conf
end

# Dedimensionalize all constants in configuration
# Params
#   conf - the configuration dict
# Returns
#   A configuration dict with nondimensional units
function dedimension(conf)
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

  return conf
end
    
# Main function loop
function main()
  # Generate default params
  conf = defaultConf()
  # Get the arguements passed to the program
  parsedArgs = parseArgs()
  # Assign params from the configuration file
  if(parsedArgs["config"]!=nothing)
    DataIO.readConf(parsedArgs["config"], conf)
  end
  # De-dimensionalise parameters
  dedimension(conf)
  # Override path if specified from cli
  if(parsedArgs["outdir"]!=nothing)
    conf["path"] = parsedArgs["outdir"]
  end
  # Initialize the file sysetm
  initFS(conf)
  # Log
  DataIO.log("Experiment starting...", conf)
  DataIO.log("Experiment path at $(conf["path"])", conf)

  
  #addprocs(3)

  #@everywhere include("./Experiment.jl")
  
  # TODO add an abstraction to allow several experiments with different params
  Experiment.runExp(conf)

end

function test()
  println("Testing particle creation and output:")
  parts = Array(Part, 3)
  for i in 1:size(parts,1)
    parts[i] = Part(1, rand(2), rand(2), rand(1), 0.0)
  end
  print(parts)

  Simulation.test()
  DataIO.test()
end
#test()
main()
