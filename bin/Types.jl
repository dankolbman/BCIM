##
# Type for particle representation
#
# Dan Kolbman
##

import Base.show

type Part
  sp::Int8
  pos::Array{Float64}
  vel::Array{Float64}
  ang::Array{Float64}
  msd::Float64
end

# The following formats the output of particle data
# TODO this could be cleaned up some
function show(io::IO, p::Part)
  #println("$(p.sp) $(p.vel) $(p.ang) $(p.msd)")
  print(io, "$(p.sp) ")
  print_arr(io, p.pos)
  print_arr(io, p.vel)
  print_arr(io, p.ang)
  print(io, "$(p.msd)")
end

function print_arr(io, X::AbstractArray)
    for i=1:size(X,1)
      print(io, "$(X[i]) ")
    end
end

function show(io::IO, part::Array{Part})
  for p in part
    show(io, p)
    print(io, "\n")
  end
end
