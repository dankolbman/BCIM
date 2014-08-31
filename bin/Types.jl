##
# Type for particle representation
#
# Dan Kolbman
##

import Base.show

type Part
  sp::Int32
  pos::Array{Float32}
  vel::Array{Float32}
  ang::Array{Float32}
  # The total square distance, used for msd
  sqd::Float64
  # The starting coordinate
  org::Array{Float32}

  Part(sp, pos, vel, ang, sqd) = new(sp, pos, vel, ang, sqd, pos)
  Part(sp, pos, vel, ang) = new(sp, pos, vel, ang, 0.0, pos)
end

# The following formats the output of particle data
# TODO this could be cleaned up some
function show(io::IO, p::Part)
  #println("$(p.sp) $(p.vel) $(p.ang) $(p.msd)")
  print(io, "$(p.sp) ")
  print_arr(io, float64(p.pos))
  print_arr(io, float64(p.vel))
  print_arr(io, float64(p.ang))
  print(io, "$(float64(p.sqd))")
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
