##
# Data logging functions
#
# Dan Kolbman 2015
##

type Log
  stream::IOStream
  verbose::Bool
end

function Log(path::String)
  if(!isdir(dirname(path)))
    mkpath(dirname(path))
  end
  return Log(open(path, "a"), true)
end

function Log(path::String, verbose)
  if(!isdir(dirname(path)))
    mkpath(dirname(path))
  end
  return Log(open(path), verbose)
end

function Log(stream::IOStream)
  return Log(stream, true)
end

function log(l::Log, output::String)
  t = TmStruct(time())
  str = ""
  tstr = string("[",t.hour,":",t.min,":",t.sec,"]:")
  if(nprocs() > 1)
    str = "$tstr {Worker $( myid()), } $output\n"
  else
    str = "$tstr $output\n"
  end
  write(l.stream, str)
  if( l.verbose ) print(str) end
end
