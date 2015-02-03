##
# Types for particle and cell representation
#
# Dan Kolbman
##

import Base.show

# Holds dimensional physical parameters
type PhysicalConst
  dt::Float64
  phi::Float64
  eta::Float64
  temp::Float64
  boltz::Float64

  prop::Array{Float64,1}
  rep::Array{Float64,1}
  adh::Array{Float64,1}
  contact::Float64
  dia::Float64
  npart::Array{Int64,1}
  
  rotdiffus::Float64
  diffus::Float64
end

function PhysicalConst(
              dt::Float64,
              phi::Float64,
              eta::Float64,
              temp::Float64,
              boltz::Float64,
              prop::Array{Float64,1},
              rep::Array{Float64,1},
              adh::Array{Float64,1},
              contact::Float64,
              dia::Float64,
              npart::Array{Int64,1})
  diff = boltz*temp/(3*pi*eta*dia)
  rotdiff = 500*boltz*temp/(pi*eta*dia^3)
  return PhysicalConst(
              dt,
              phi,
              eta,
              temp,
              boltz,
              prop,
              rep,
              adh,
              contact,
              dia,
              npart,
              diff,
              rotdiff)
end
# Holds dimensionless parameters
type DimensionlessConst
  dt::Float64
  phi::Float64
  eta::Float64
  temp::Float64
  boltz::Float64

  prop::Array{Float64,1}
  rep::Array{Float64,1}
  adh::Array{Float64,1}
  contact::Float64
  dia::Float64
  npart::Array{Int64,1}
  size::Float64

  utime::Float64
  ulength::Float64
  uenergy::Float64

  rotdiffus::Float64
  diffus::Float64
  pretrad::Float64
  prerotd::Float64
end

# Converts physical parameters to dimensionless parameters
function DimensionlessConst(pc::PhysicalConst)
  utime = pc.dia^2/pc.diffus
  ulength = pc.dia
  uenergy = pc.boltz*pc.temp
  rotdiffus = pc.rotdiffus*utime
  diffus = pc.diffus*utime/(ulength^2)
  dia = pc.dia./ulength
  size = sqrt((dia/2.0)^2*sum(pc.npart)/pc.phi)
  dt = pc.dt/utime
  rep = pc.rep./ulength
  contact = pc.contact./ulength
  adh = pc.adh./contact
  pretrad = sqrt(2.0/dt)
  prerotd = sqrt(2.0*rotdiffus*dt)

  return DimensionlessConst( dt,
                            pc.phi,
                            pc.eta,
                            pc.temp,
                            pc.boltz,
                            pc.prop,
                            rep,
                            adh,
                            contact,
                            dia,
                            pc.npart,
                            size,
                            utime,
                            ulength,
                            uenergy,
                            rotdiffus,
                            diffus,
                            pretrad,
                            prerotd)
end

type Part
  id::Int
  sp::Int8
  pos::Array{Float64}
  vel::Array{Float64}
  ang::Array{Float64}
  # The total square distance, used for msd
  sqd::Float64
  # The starting coordinate
  org::Array{Float64}
  # Force contributions
  brn::Array{Float64}
  prp::Array{Float64}
  adh::Array{Float64}
  rep::Array{Float64}
  # Constructors
  Part(id, sp, pos, vel, ang, sqd) = new(id, sp, pos, vel, ang, sqd, pos,
       [0.0,0.0,0.0],[0.0,0.0,0.0],[0.0,0.0,0.0],[0.0,0.0,0.0])
  Part(id, sp, pos, vel, ang) = new(id, sp, pos, vel, ang, 0.0, pos,
       [0.0,0.0,0.0],[0.0,0.0,0.0],[0.0,0.0,0.0],[0.0,0.0,0.0])
end

type Cell
  id::Int
  parts::Array{Part}
  neighbors::Array{Cell}
end

function show(io::IO, c::Cell)
  print(io, "$(c.id)")
end

# The following formats the output of particle data
# TODO this could be cleaned up some
function show(io::IO, p::Part)
  #println("$(p.sp) $(p.vel) $(p.ang) $(p.msd)")
  print(io, "$(p.sp) ")
  print_arr(io, p.pos)
  print_arr(io, p.vel)
  print_arr(io, p.ang)
  print(io, "$(p.sqd)")
  if io == STDOUT
    forces(p)
  end
end

# Print the force contributions for the particle
function forces(p::Part)
  print("FORCES FOR PARTICLE $(p.id)\n")
  print("BRN: $(norm(p.brn))\n")
  print("PRP: $(norm(p.prp))\n")
  print("ADH: $(norm(p.adh))\n")
  print("REP: $(norm(p.rep))\n")
end

function print_arr(io, X::AbstractArray)
    for i=1:size(X,1)
      print(io, "$(X[i])\t")
    end
end

function show(io::IO, part::Array{Part})
  for p in part
    show(io, p)
    print(io, "\n")
  end
end
