##
# Functions for file reading and writing
#
# Dan Kolbman 2014
##

module DataIO

# Read a configuration file
# Params:
#   filen - the path for the configuration file
# Returns:
#   A Dict with param, value pairs
function readConf(filen)
  # Reads data into an array separated by ' '
  data = readdlm(filen,' ')
  params = Dict{String, Any}()
  # Each element in the array corresponds to a parameter
  for line in 1:size(data,1)
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
      params[key] = vals[1]
    # If more than one value, assign the array as the value
    elseif(size(vals,1) > 1)
      params[key] = vals
    end
  end
  return params

end

# Write a configuration file
# Params
#   filen - the path to write the configuration file to
#   conf - a Dict of parameters
function writeConf(filen, conf)
  f = open(filen, "w")
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

# Appends output to a logfile
# Params
#   str - the string to write
#   conf - the configuration Dict
function log(str,conf)
  path = string(conf["path"],"log.txt")
  f = open(path,"w+")
  t = TmStruct(time())
  str = string("[",t.hour,":",t.min,":",t.sec,"]: ",str)
  write(f,str)
  if(conf["verbose"] == 1) println(str) end
  close(f)
end

#Testing
#conf1 = readConf("defaults.cnf")
#writeConf("newconf.cnf", conf1)
#conf2 = readConf("newconf.cnf")
#println(conf2)

end
