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


function writeConstants(path::ASCIIString, pc::PhysicalConst)
  f = open(path, "a")
  println(f, "dt\t$(pc.dt)")
  println(f, "phi\t$(pc.phi)")
  println(f, "eta\t$(pc.eta)")
  println(f, "temp\t$(pc.temp)")
  println(f, "boltz\t$(pc.boltz)")
  println(f, "## Physical properties")
  println(f, "prop\t$(pc.prop)")
  println(f, "rep\t$(pc.rep)")
  println(f, "adh\t$(pc.adh)")
  println(f, "contact\t$(pc.contact)")
  println(f, "dia\t$(pc.dia)")
  println(f, "npart\t$(pc.npart)")
  println(f, "##")
  println(f, "diffus\t$(pc.diffus)")
  println(f, "rotdiffus\t$(pc.rotdiffus)")
  close(f)
end

function writeConstants(path::ASCIIString, dc::DimensionlessConst)
  f = open(path, "a")
  println(f, "dt\t$(dc.dt)")
  println(f, "phi\t$(dc.phi)")
  println(f, "eta\t$(dc.eta)")
  println(f, "temp\t$(dc.temp)")
  println(f, "boltz\t$(dc.boltz)")
  println(f, "## Physical properties")
  println(f, "prop\t$(dc.prop)")
  println(f, "rep\t$(dc.rep)")
  println(f, "adh\t$(dc.adh)")
  println(f, "contact\t$(dc.contact)")
  println(f, "dia\t$(dc.dia)")
  println(f, "npart\t$(dc.npart)")
  println(f, "##")
  println(f, "utime\t$(dc.utime)")
  println(f, "ulength\t$(dc.ulength)")
  println(f, "uenergy\t$(dc.uenergy)")
  println(f, "##")
  println(f, "diffus\t$(dc.diffus)")
  println(f, "rotdiffus\t$(dc.rotdiffus)")
  println(f, "pretrad\t$(dc.pretrad)")
  println(f, "prerotd\t$(dc.prerotd)")
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

function readConfig(filen::ASCIIString, frame=1)

end
