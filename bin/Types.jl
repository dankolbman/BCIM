##
# Types for particle and cell representation
#
# Dan Kolbman
##

import Base.show

type Part
  id::Int
  sp::Int32
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
  # Constructures
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
function forces(p)
  print("FORCES FOR PARTICLE $(p.id)\n")
  print("BRN: $(p.brn)\n")
  print("PRP: $(p.prp)\n")
  print("ADH: $(p.adh)\n")
  print("REP: $(p.rep)\n")
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
