##
# Function for calculating inter-particle forces.
#
# Dan Kolbman 2014
##

module Dynamics

# Calculate and apply all forces between particles
function forceCalc(conf, parts)

  # Apply a brownian force to all particle
  brownian(parts, conf)

  # Iterate through all interactions
  for p1 in 1:size(parts,1)
    for p2 in (p1+1):size(parts,1)
      # Apply the repulsive force
      repF(parts[p1,1:end], parts[p2,1:end], conf)
      # Apply the adhesive force
      adhF(parts[p1,1:end], parts[p2,1:end], conf)
      
    
    end
  end
end

# Applies a brownian force on all particles
# ie rotate earch particle then apply a random force in that direction
# Params
#   conf - the configuration dict
#   parts - the particle array
function brownian(parts, conf)
  for p in 1:size(parts,1) 
    # Update angle
    parts[p, end-1] += randn()*conf["prerotd"]
    v = conf["prop1"]*rand()*
    parts[p,1:3] = parts[p,1:3] + (rand() - 0.5)
  end
end

# Calculates the repulsive force between two particles
# Params
#   p1 - the first particle array
#   p2 - the second particl array
function repF(p1, p2, conf)
  r = dist(p1,p2)
  return r
end

# Calculates the adhesive force between two particles
# Params
#   p1 - the first particle array
#   p2 - the second particl array
function adhF(p1, p2, conf)
  r = dist(p1,p2)
  return r
end

# Calculate the distance between two particles
# Params
#   p1 - the first particle array
#   p2 - the second particl array
# Returns
#   The cartesian distance between the particles
function dist(p1, p2)
  x = p1[1] - p2[1]
  y = p1[2] - p2[2]
  z = p1[3] - p2[3]
  return sqrt(x**2 + y**2 + z**2)
end

end
