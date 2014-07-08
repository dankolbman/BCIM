##
# Statistical functions for evaluation of results
#
# Dan Kolbman 2014
##

module Stats

# Compute radial distribution function and return an array [ r gr ]
# Params
#   parts - the particles
#   conf - the configuration dict
function gr(parts, conf)
  binsep = 0.5*conf["size"]/conf["numbins"]
  gofr = Array(Float64, conf["numbins"],2)

  # Iterate each species
  for sp in 1:size(parts,1)
    if 
    # Iterate each particle
    for p1 in 1:(size(parts[sp],1)-1)
      for p2 in (p1+1):size(parts[sp],1)
        # Separations
        dr = parts[sp][p1,1:3] .- parts[sp][p2,1:3]
        # Distance
        d = sqrt(sum(dr.^2))

        if(d < 0.5*conf["size"])
          gr[ floor(d/binsep), 2] += 2
        end
      end
    end
    for i in 1:conf["numbins"]
      gofr[i,2] /= (4/3)*pi*((i+1)^3 - i^3)*binsep^3*conf["phi"]/conf["npart"][sp]
      gofr[i,1] = (i+0.5)*binsep/conf["dia"]
    end
  end
  

  return gofr
end

end
