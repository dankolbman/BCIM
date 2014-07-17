##
# Functions for file reading and writing
# 
# TODO it might be better to pass file streams to these functions rather
# than open and close inside of the functions.
#
# Dan Kolbman 2014
##

module DataIO

include("Types.jl")

# Appends output to a logfile
# Params
#   str - the string to write
#   conf - the configuration Dict
function log(str,conf)
  path = string(conf["path"],"log.txt")
  f = open(path,"a")
  t = TmStruct(time())
  str = string("[",t.hour,":",t.min,":",t.sec,"]: ",str,"\n")
  write(f,str)
  if(conf["verbose"] == 1) print(str) end
  close(f)
end
# Read a configuration file and returns a new configuration dict
# Params:
#   filen - the path for the configuration file
# Returns:
#   A Dict with param, value pairs
function readConf(filen)
  params = Dict{String, Any}()
  readConf(filen, conf)
  return params
end

# Read a configuration file and assigns values to conf dict.
# Modifies the conf in place. Existing parameters may be overwritten
# Params:
#   filen - the path for the configuration file
#   conf - a configuration dict
function readConf(filen, conf, nExp=0)
  # Reads data into an array separated by ' '
  data = readdlm(filen,' ',comments=true)
  expScanned = 0
  # Each element in the array corresponds to a parameter
  for line in 1:size(data,1)
    if( nExp > 0 && data[line,1] == "experiment")
      if(expScanned == nExp+1)
        break   # Don't scan any more parameters after given experiment
      else
        expScanned += 1
      end
    end
    # The first element is the parameter name
    key = data[line,1]
    vals = Array(Any,0)
    # Strip all empty entries
    for elem in 2:size(data,2)
      if (data[line,elem] != "")
        push!(vals,data[line,elem])
      end
    end
    # If only one value, assign it to the key
    if(size(vals,1) == 1)
      conf[key] = vals[1]
    # If more than one value, assign the array as the value
    elseif(size(vals,1) > 1)
      conf[key] = vals
    end
  end
end

# Scan a configuration file for the number of experiments it contains
# Params:
#   filen - the file path for the configuation file
function getNumExp(filen)
  f = open(filen)
  nExp = 0
  # Each element in the array corresponds to a parameter
  for line in eachline(f)
    if(line == "experiment\n")
      nExp += 1
    end
  end
  close(f)
  return nExp
end

# Write a configuration file
# Params
#   filen - the path to write the configuration file to
#   conf - a Dict of parameters
function writeConf(filen, conf)
  if(!isdir(dirname(filen)))
    mkpath(dirname(filen))
  end
  f = open("$filen.cnf", "w")
  for key in keys(conf)
    line = key
    # If the parameter has multiple values..
    if(typeof(conf[key]) == Array{Any,1})
      # Write each value
      for val in conf[key]
        line = string(line, " ", val)
      end
    else
      # Or just write the single value
      line = string(line, " ", conf[key])
    end
    write(f, string(line,"\n"))
  end
  close(f)
end

# Reads particle data for all species from files begining with filen
# Params
#   filen - the path to write the file
# Returns
#   a species array
function readParts(filen)
  #TODO implement this. Not needed until we want to start simulations from
  # old states.
end

# Reads a single species from a data file
# Params
#   filen - the file name of the species
# Returns
#   An array of particle data for the species
function readSpecies(filen)
  parts = readdlm(filen,' ')
  return parts
end

# Write particle data to a file.
# If no species is defined, write all species to different data files
# Params
#   filen - the file to write to
#   parts - particle species array
#   t - time when data is being recorded
#   spec - which species to write
function writeParts(filen, parts, t=0.0, spec=0)
  # Make file structure if it doesn't exist
  if(!isdir(dirname(filen)))
    mkpath(dirname(filen))
  end
  f = open("$(filen).dat","a+")
  println(f,"### [ time species pos... vel... ang... sqd")
  for p in parts 
    println(f, "$t $(p)")
  end
  close(f)
end

# Write average MSD to file
# Params
#   filen - the file to write to
#   msd - msd data [ time msd... ]
function writeMSD(filen, msd)
  if(!isdir(dirname(filen)))
    mkpath(dirname(filen))
  end

  f = open("$(filen).dat", "a+")
  write(f, "# [ time  msd... ]\n")
  for i in 1:size(msd,1)
    print(f, "$(msd[i,1])")
    for j in 2:size(msd,2)
      print(f, " $(msd[i,j])")
    end
    print(f,"\n")
  end
  #writedlm(f, msd, ' ')
  close(f)
end

# Test functions
function test()
  #Configuration files
  #conf1 = readConf("defaults.cnf")
  #writeConf("newconf.cnf", conf1)
  #conf2 = readConf("newconf.cnf")
  #println(conf2)
  parts = Array(Part, 3)
  for i in 1:size(parts,1)
    parts[i] = Part(1, rand(2), rand(2), rand(1), 0.0)
  end
  print(parts)

  # Write positions
  println("Test DataIO.writeParts")
  writeParts("parts", parts)
end

end
