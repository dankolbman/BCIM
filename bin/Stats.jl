##
# Statistical functions for evaluation of results
#
# Dan Kolbman 2014
##

module Stats

include("Types.jl")

# Compute radial distribution function and return an array [ r gr ]
# Params
#   parts - the particles
#   conf - the configuration dict
function gr(conf, parts)
  binsep = 0.5*conf["size"]/conf["numbins"]
  gofr = zeros(Float64, conf["numbins"],1+size(conf["npart"],1))

  # Iterate each species
  for sp in 1:size(conf["npart"],1)
    # Iterate each particle
    for p1 in 1:(conf["tpart"]-1)
      for p2 in (p1+1):conf["tpart"]
        if(parts[p1].sp == sp && parts[p2].sp == sp)
          # Separations
          dr = parts[p1].pos .- parts[p2].pos
          # Distance
          d = sqrt(sum(dr.*dr))
          if(d < 0.5*conf["size"])
            gofr[ floor(d/binsep)+1, sp+1] += 2
          end
        end
      end
    end
    for i in 1:conf["numbins"]
      gofr[i,sp+1] /= (4/3)*pi*((i+1)^3 - i^3)*binsep^3*conf["phi"]/conf["npart"][sp]
      gofr[i,1] = (i+0.5)*binsep/conf["dia"]
    end
  end

  return gofr
end

# Average a list of specified g(r) data files
function avgGR(conf, files::Array)
  nfiles = size(files,1)
  gr = zeros(Float64, countlines(files[1]),  1+size(conf["npart"],1) )
  # Read in each file, divide it, and add it
  for i in 1:nfiles
    if(ispath(files[i]))
      tgr = readdlm(files[i])
      tgr[:,2:end] = tgr[:,2:end] ./ nfiles
      # This only needs to happen once
      gr[:,1] = tgr[:,1]
      gr[:,2:end] += tgr[:,2:end]
    end
  end
  return gr
end

function avgMSD(conf, files::Array{String})
  nfiles = size(files,1)
  msd = zeros(Float64, countlines(files[1]),  1+size(conf["npart"],1) )
  # Read in each file, divide it, and add it
  for i in 1:nfiles
    if(ispath(files[i]))
      tmsd = readdlm(files[i])
      tmsd[:,2:end] = tmsd[:,2:end] ./ nfiles
      # This only needs to happen once
      msd[:,1] = tmsd[:,1]
      msd[:,2:end] += tmsd[:,2:end]
    end
  end
  return msd
end

# Compute average msd for an array of particles
function avgMSD(conf, parts::Array)
  # Update displacements
  sqdtot = zeros(Float64, size(conf["npart"],1))
  
  for p in parts
    d = (p.pos - p.org)
    sqdtot[p.sp] +=  sum((d).^2)
   # sqdtot[p.sp] += d[1]^2 + d[2]^2 + d[3]^2
    #sqdtot[p.sp] += p.sqd
  end
  return  sqdtot ./ float(conf["npart"])
end

end
