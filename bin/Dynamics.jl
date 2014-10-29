##
# Function for calculating inter-particle forces.
#
# Dan Kolbman 2014
##

module Dynamics

include("Types.jl")

# Calculate and apply all forces between particles
function forceCalc(conf, parts, cells)

  for p in parts
    p.vel = [ 0.0, 0.0, 0.0 ]
  end
  # Apply a brownian force to all particle
  brownian(conf, parts)
  # Apply propulsion to particles
  prop(conf, parts)
  # Repulsive force
  collisionCheck(conf, cells)

  bound = (conf["size"] - conf["dia"]/2.0)
  for p in parts
    newpos = p.pos + p.vel*conf["dt"]
    dist2 = newpos[1]^2 + newpos[2]^2 + newpos[3]^2
    # Within the sphere bounds
    if(dist2 <= bound^2)
      p.pos = newpos
    else
    # Place on the edge of the sphere
      thet = acos(newpos[3]/sqrt(dist2))
      phi = atan2(newpos[2],newpos[1])
      p.pos = bound*[ sin(thet)*cos(phi), sin(thet)*sin(phi), cos(thet) ]
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
    p.ang[1] += conf["rotdiffus"]*randn() % (2*pi)
    p.ang[2] += conf["rotdiffus"]*randn() % (2*pi)
    # Determine velocity components
    v = abs(conf["prop"][p.sp]*randn())
    u = cos(p.ang[1])
    vx = v*sqrt(1-u^2)*cos(p.ang[2])
    vy = v*sqrt(1-u^2)*sin(p.ang[2])
    vz = v*u
    # Update particle velocity
    p.vel += [ vx, vy, vz ]
  end
end

# Checks cells for collision pairs with their neighbors
# Params
#   conf - the configuration dict
#   cellGrid - a N dimensional array of cells
function collisionCheck(conf, cellGrid)
  for c1 in cellGrid
    # Collide neighbors of c1
    for c2 in c1.neighbors
      collideCells(conf, c1, c2)
    end
  end
end

# Collide the particles within two cells with one another
# Params
#   conf - the configuration dict
#   c1 - the first cell
#   c2 - the second cell
function collideCells(conf, c1, c2)
  for p1 in c1.parts
    for p2 in c2.parts
      repF(conf, p1, p2)
      adhF(conf, p1, p2)
    end
  end
end

# Calculates the repulsive force between particles
# Params
#   conf - the configuration dict
#   p1 - the first particle
#   p2 - the second particle
function repF(conf, p1, p2)
  if(p1.id < p2.id)
    dr = p1.pos - p2.pos
    d = sqrt(sum(dr.^2))
    # Direction
    thet = acos(dr[3]/d)
    phi = atan2(dr[2],dr[1])
    # Magnitude of force (linear)
    f = 1.0-d/conf["dia"]
    #f = (abs(f)+f)/2.0
    if d > conf["dia"]
      f = 0
    end
    # Force vector
    f *= [ sin(thet)*cos(phi),  sin(thet)*sin(phi), cos(thet) ]
    if( p1.sp != p2.sp)   # Different species interacting
      # Avoid division by 0
      #a = conf["rep"][p1.sp]*conf["rep"][p2.sp]
      #b = conf["rep"][p1.sp]+conf["rep"][p2.sp]
      #if(b == 0.0)
      #  f *= 0.0
      #else
      #  f *= 2.0*a/b
      #end
      f *= conf["rep"][3]
    else
      f *= conf["rep"][p1.sp]
    end
    # Add forces
    p1.vel += f
    p2.vel -= f
  end
end

# Calculates the adhesive force between particles
# Params
#   conf - the configuration dict
#   parts - an array of particle arrays for each species
function adhF(conf, p1, p2)
  if(p1.id < p2.id)
    dr = p1.pos - p2.pos
    d = sqrt(sum(dr.^2))
    if( d < conf["dia"]*(1+conf["contact"]) )
      # Direction
      thet = acos(dr[3]/d)
      phi = atan2(dr[2],dr[1])
      # Magnitude of force normalized to 1
      f = 0.0
      d = d/conf["dia"]
      if(d >= 1.0 && d <= 1.0+conf["contact"])
        f = abs(2*d/conf["contact"]
            - 2*(1+conf["contact"])/(conf["dia"]*conf["contact"]) - 1)
      end
      # Force vector
      f *= [ sin(thet)*cos(phi),  sin(thet)*sin(phi), cos(thet) ]
      if( false ) #p1.sp != p2.sp)   # Different species interacting
        # Avoid division by 0
        a = conf["adh"][p1.sp]*conf["adh"][p2.sp]
        b = conf["adh"][p1.sp]+conf["adh"][p2.sp]
        if(b == 0.0)
          f *= 0.0
        else
          f *= 2.0*a/b
        end
      else
        f *= conf["adh"][p1.sp]
      end
      # Add forces
      p1.vel += f
      p2.vel -= f
    end
  end
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
