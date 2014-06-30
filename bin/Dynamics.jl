##
# Function for calculating inter-particle forces.
#
# Dan Kolbman 2014
##

module Dynamics

# Calculate and apply all forces between particles
function forceCalc(conf, parts)

  # Apply a brownian force to all particle
  prop(conf, parts)
  # Iterate through each species
  for sp in 1:size(parts,1)
    # Iterate through all particles
    for p1 in 1:size(parts[sp],1)
      parts[sp][p1,1:3] += parts[sp][p1,4:6]
    end
  end
end

# Applies a brownian force on all particles
# ie rotate earch particle then apply a random force in that direction
# Params
#   conf - the configuration dict
#   parts - an array of particle arrays for each species
function brownian(parts, conf)
  #
end

# Applies a propulsion to all particles
# Params
#   conf - the configuration dict
#   parts - an array of particle arrays for each species
function prop(conf, parts)
  # Iterate each species
  for sp in 1:size(parts,1)
    # Iterate each particle
    for p in 1:size(parts[sp],1) 
      phi = parts[sp][p,end-2] + conf["rotdiffus"]*randn()
      thet = parts[sp][p,end-1] + conf["rotdiffus"]*randn()
      # Update vars
      parts[sp][p,end-2] = phi
      parts[sp][p,end-1] = thet
      # Determine velocity components
      v = abs(conf["prop"][sp]*randn())
      u = cos(phi)
      vx = v*sqrt(1-u^2)*cos(thet)
      vy = v*sqrt(1-u^2)*sin(thet)
      vz = v*u
      # Update particle velocity
      parts[sp][p,4:6] = parts[sp][p,4:6] + [ vx vy vz ]
    end
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
  return sqrt(x^2 + y^2 + z^2)
end

end
