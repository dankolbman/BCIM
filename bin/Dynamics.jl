##
# Function for calculating inter-particle forces.
#
# Dan Kolbman 2014
##

module Dynamics

include("Types.jl")

# Calculate and apply all forces between particles
function forceCalc(conf, parts)

  for p in parts
    p.vel = [ 0, 0, 0 ]
  end
  # Apply a brownian force to all particle
  brownian(conf, parts)
  # Apply propulsion to particles
  prop(conf, parts)
  # Repulsive force
  repF(conf, parts)

  for p in parts
    newpos = p.pos + p.vel*conf["dt"]
    dist2 = newpos[1]^2 + newpos[2]^2 + newpos[3]^2
    # Within the sphere bounds
    if(dist2 <= (conf["size"] - conf["dia"]/2.0)^2)
      p.pos = newpos
    else
    # Place on the edge of the sphere
      thet = acos(newpos[3]/sqrt(dist2))
      phi = atan2(newpos[2],newpos[1])
      r = conf["size"]-conf["dia"]/2.0
      p.pos = r*[ sin(thet)*cos(phi), sin(thet)*sin(phi), cos(thet) ]
    end
  end
end

# Applies a brownian force on all particles
# ie rotate earch particle then apply a random force in that direction
# Params
#   conf - the configuration dict
#   parts - an array of particle arrays for each species
function brownian(conf, parts)
  # Iterate each particle
  for p in parts 
    # Add some normal velocity
    p.vel += conf["pretrad"] * randn(3)
  end
end

# Applies a propulsion to all particles
# Params
#   conf - the configuration dict
#   parts - an array of particle arrays for each species
function prop(conf, parts)
  # Iterate each particle
  for p in parts
    p.ang[1] += conf["rotdiffus"]*randn()
    p.ang[2] += conf["rotdiffus"]*randn()
    # Determine velocity components
    v = conf["prop"][p.sp]*randn()
    u = cos(p.ang[1])
    vx = v*sqrt(1-u^2)*cos(p.ang[2])
    vy = v*sqrt(1-u^2)*sin(p.ang[2])
    vz = v*u
    # Update particle velocity
    p.vel += [ vx, vy, vz ]
  end
end

# Calculates the repulsive force between particles
# Params
#   conf - the configuration dict
#   parts - an array of particle arrays for each species
function repF(conf, parts)
  for i1 in 1:(size(parts,1)-1)
    for i2 in (p1+1):size(parts,1)
      p1 = parts[i1]
      p2 = parts[i2]
      dr = p1.pos - p2.pos
      d = sqrt(sum(dr.^2))
      # Direction
      thet = acos(dr[3]/d)
      phi = atan2(dr[2],dr[1])
      # Magnitude of force (linear)
      f = 1.0-conf["dia"]/d
      f = (abs(f)-f)/2.0
      # Force vector
      f *= [ sin(thet)*cos(phi),  sin(thet)*sin(phi), cos(thet) ]
      if( p1.sp != p2.sp)   # Different species interacting
        f *= 2*(conf["rep"][p1.sp]*conf["rep"][p2.sp] / 
            (conf["rep"][p1.sp]+conf["rep"][p2.sp]))
      else
        f *= conf["rep"][p1.sp]
      end
      # Add forces
      p1.vel += f
      p2.vel -= f
    end
  end
end

# Calculates the adhesive force between particles
# Params
#   conf - the configuration dict
#   parts - an array of particle arrays for each species
function adhF(p1, p2, conf)
  for p1 in parts
    for p2 in parts
      if(p1 != p2)
        dr = p1.pos - p2.pos
        d = sqrt(sum(dr.^2))
        # Direction
        thet = acos(dr[3]/d)
        phi = atan2(dr[2],dr[1])
        # Magnitude of force (linear)
        x = d-conf["dia"]/d
        y = x - 2*conf["contact"]
        f = (abs(f)-f)/2.0
        # Force vector
        f *= [ sin(thet)*cos(phi),  sin(thet)*sin(phi), cos(thet) ]
        if( p1.sp != p2.sp)   # Different species interacting
          f *= 2*(conf["rep"][p1.sp]*conf["rep"][p2.sp] / 
              (conf["rep"][p1.sp]+conf["rep"][p2.sp]))
        else
          f *= conf["rep"][p1.sp]
        end
        # Add forces
        p1.vel += f
        p2.vel -= f
      end
    end
  end

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
