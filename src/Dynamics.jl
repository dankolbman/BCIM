##
# Function for calculating inter-particle forces.
#
# Dan Kolbman 2014
##

# Calculate and apply all forces between particles
function forceCalc(s::System)

  for p in s.parts
    #p.vel = [ 0.0, 0.0, 0.0 ]
    p.brn = [ 0.0, 0.0, 0.0 ]
    p.prp = [ 0.0, 0.0, 0.0 ]
    p.adh = [ 0.0, 0.0, 0.0 ]
    p.rep = [ 0.0, 0.0, 0.0 ]
  end

  # Apply a brownian force to all particle
  brownian(s)
  # Apply propulsion to particles
  prop(s)
  # Repulsive force
  collisionCheck(s::System)

  bound = (s.dimConst.size - s.dimConst.dia/2.0)
  for p in s.parts
    # Update velocities from components
    p.vel = p.brn + p.prp + p.adh + p.rep
    # Print for any obnormal interactions
    #if( norm(p.rep) > 0.0)
    #  forces(p)
    #end

    newpos = p.pos + p.vel*s.dimConst.dt
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
function brownian(s::System)
  # Iterate each particle
  for p in s.parts 
    # Add some normal velocity
    p.brn += s.dimConst.pretrad * randn(3)
  end
end

# Applies a propulsion to all particles
# Params
#   conf - the configuration dict
#   parts - an array of particle arrays for each species
function prop(s::System)
  # Iterate each particle
  for p in s.parts
    p.ang[1] += s.dimConst.rotdiffus*randn() % (2.0*pi)
    p.ang[2] += s.dimConst.rotdiffus*randn() % (2.0*pi)
    # Determine velocity components
    v = abs(s.dimConst.prop[p.sp])
    u = cos(p.ang[1])
    vx = v*sqrt(1-u^2)*cos(p.ang[2])
    vy = v*sqrt(1-u^2)*sin(p.ang[2])
    vz = v*u
    # Update particle velocity
    p.prp += [ vx, vy, vz ]
  end
end

# Checks cells for collision pairs with their neighbors
# Params
#   conf - the configuration dict
#   cellGrid - a N dimensional array of cells
function collisionCheck(s::System)
  for c1 in s.cellGrid
    # Collide neighbors of c1
    for c2 in c1.neighbors
      collideCells(s.dimConst, c1, c2)
    end
  end
end

# Collide the particles within two cells with one another
# Params
#   conf - the configuration dict
#   c1 - the first cell
#   c2 - the second cell
function collideCells(dc::DimensionlessConst, c1::Cell, c2::Cell)
  for p1 in c1.parts
    for p2 in c2.parts
      repF(dc, p1, p2)
      adhF(dc, p1, p2)
    end
  end
end

# Calculates the repulsive force between particles
# Params
#   conf - the configuration dict
#   p1 - the first particle
#   p2 - the second particle
function repF(dc::DimensionlessConst, p1::Part, p2::Part)
  if(p1.id < p2.id)
    dr = p1.pos - p2.pos
    d = norm(dr)
    # Check that they are touching
    if( d < dc.dia)
      # Direction
      thet = acos(dr[3]/d)
      phi = atan2(dr[2],dr[1])
      # Magnitude of force (linear)
      f = 1.0-d/dc.dia
      # Force vector
      f *= [ sin(thet)*cos(phi),  sin(thet)*sin(phi), cos(thet) ]
      if( p1.sp != p2.sp)   # Different species interacting
        f *= dc.rep[p1.sp]
      else
        f *= dc.rep[p1.sp]
      end
      # Add forces
      p1.rep += f
      p2.rep -= f
    end
  end
end

# Calculates the adhesive force between particles
# Params
#   conf - the configuration dict
#   parts - an array of particle arrays for each species
function adhF(dc::DimensionlessConst, p1::Part, p2::Part)
  if(p1.id < p2.id)
    dr = p1.pos - p2.pos
    d = norm(dr)
    if( d < dc.dia*(1+2*dc.contact) )
      # Direction
      thet = acos(dr[3]/d)
      phi = atan2(dr[2],dr[1])
      # Magnitude of force normalized to 1
      f = 0.0
      if( dc.dia < d < dc.dia*(1 + 2*dc.contact))
        f = abs(d - (dc.dia + dc.contact))/dc.contact - 1
      end
      # Force vector
      f *= [ sin(thet)*cos(phi),  sin(thet)*sin(phi), cos(thet) ]
      if( p1.sp == p2.sp == 1)
        f *= dc.adh[p1.sp]
      end
      p1.adh += f
      p2.adh -= f
    end
  end
end

