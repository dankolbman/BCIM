##
# Function for calculating inter-particle forces.
#
# Dan Kolbman 2014
##

module Dynamics

# Calculate and apply all forces between particles
function forceCalc(conf, parts)

  # Apply a brownian force to all particle
  brownian(conf, parts)
  # Apply propulsion to particles
  prop(conf, parts)
  # Repulsive force
  repF(conf, parts)
  
  # Update positions
  # Iterate through each species
  for sp in 1:size(parts,1)
    # Iterate through all particles
    for p1 in 1:size(parts[sp],1)
      # Calculate new position
      newpos = parts[sp][p1,1:3] + parts[sp][p1,4:6]
      
      # Apply boundaries
      dist = sqrt(sum(newpos.^2))
      if(dist <= conf["size"] - conf["dia"]/2.0)
        parts[sp][p1,1:3] = newpos
        # MSD
        parts[sp][p1,end] += dist
      else
        thet = acos(newpos[3]/dist)
        phi = atan2(newpos[2],newpos[1])
        r = conf["size"]-conf["dia"]/2.0
        # MSD
        parts[sp][p1,end] += r - sqrt(sum(parts[sp][p1,1:3].^2))
        parts[sp][p1,1:3] = r*[ sin(thet)*cos(phi)  sin(thet)*sin(phi) cos(thet) ]
      end
    end
  end
end

# Applies a brownian force on all particles
# ie rotate earch particle then apply a random force in that direction
# Params
#   conf - the configuration dict
#   parts - an array of particle arrays for each species
function brownian(conf, parts)
  # Iterate each species
  for sp in 1:size(parts,1)
    # Iterate each particle
    for p in 1:size(parts[sp],1) 
      # Add some normal velocity
      parts[sp][p,4:6] += conf["pretrad"].*randn(3).'
    end
  end
  
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
function repF(conf, parts)
  # Iterate each species
  for sp in 1:size(parts,1)
    # Iterate each particle
    for p1 in 1:(size(parts[sp],1)-1)
      for p2 in (p1+1):size(parts[sp],1)
        # Separations
        dr = parts[sp][p1,1:3] .- parts[sp][p2,1:3]
        # Distance
        d = sqrt(sum(dr.^2))
        # Direction
        thet = acos(dr[3]/d)
        phi = atan2(dr[2],dr[1])
        # Magnitude of force (linear)
        f = 1-conf["dia"]/d
        f = (abs(f)-f)/2.0
        # Force vector
        f = f * [ sin(thet)*cos(phi)  sin(thet)*sin(phi) cos(thet) ]
        f = conf["rep"][sp] * f
        # Add forces
        parts[sp][p1,4:6] += f
        parts[sp][p2,4:6] -= f
      end
    end
  end
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
