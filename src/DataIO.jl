##
# Functions for file reading and writing
# 
# Dan Kolbman 2014
##

# Write particle data to a file.
# If no species is defined, write all species to different data files
# Params
#   filen - the file to write to
#   parts - particle species array
#   t - time when data is being recorded
#   spec - which species to write
function writeParts(filen::ASCIIString, parts::Array{Part}, t=0.0, spec=0)
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

  f = open("$(filen).dat", "w")
  write(f, "# [ time  msd... ]\n")
  writedlm(f, msd, ' ')
  close(f)
end
