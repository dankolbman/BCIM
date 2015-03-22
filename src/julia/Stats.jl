# Compute average msd for an array of particles
function avgMSD(dc::DimensionlessConst, parts::Array)
  # Update displacements
  sqdtot = zeros(Float64, size(dc.npart,1))
  for p in parts
    d = (p.pos - p.org)
    sqdtot[p.sp] += sum((d).^2)
  end
  return sqdtot ./ float(sum(dc.npart))
end
