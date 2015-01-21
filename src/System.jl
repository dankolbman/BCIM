type System
  parts::Array{Part,1}
  cellGrid::Array{Cell}
  dimConst::DimensionlessConst
end

# Construct a system given particle counts and dimensionless parameters
function System(dc::DimensionlessConst)
  p = constructParts(dc)
  c = constructCells(dc)

  return System(p, c, dc)
end

# Build particles for the system
function constructParts(dc::DimensionlessConst)
  return uniformSphere(dc)
end

function uniformSphere(dc::DimensionlessConst)
  parts = Array(Part,sum(dc.npart))
  pl = 1
  for sp in 1:length(sum(dc.npart))
    for p in 1:dc.npart[sp]
      # This creates a uniform distribution in the sphere
      lam = (dc.size-dc.dia/2.0)*cbrt(rand())
      u = 2*rand()-1
      phi = 2*pi*rand()
      xyz = [ lam*sqrt(1-u^2)*cos(phi), lam*sqrt(1-u^2)*sin(phi), lam*u ]
      parts[pl] = Part(pl, sp, xyz, [0, 0, 0], 2*pi*rand(2)) 
      pl += 1
    end
  end
  return parts
end

# Make cells
function constructCells(dc::DimensionlessConst)
  return Array(Cell,1)
end

################################################################################

function step(s::System)
  forceCalc(s::System)
end

function updateCells(s::System)

end
