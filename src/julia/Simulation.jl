type Simulation
  id::Int64
  path::ASCIIString
  s::System
  dimConst::DimensionlessConst
  l::Log
end

function Simulation(id::Int64, path::ASCIIString, dc::DimensionlessConst, l::Log)
  s = System(dc)
  return Simulation(id, path, s, dc, l)
end

# Runs the simulation for the desired time
function run(sim::Simulation, r::Range{Int})


  nequil = first(r)-1
  freq = r.step
  nsteps = last(r)

  ndata = int(nsteps/freq)
  avgmsd = zeros(Float64, ndata, size(sim.dimConst.npart, 1)+1)

  tic()
  # Equilibriate
  for s in 1:nequil
    # Update cells
    if(s%10 == 1)
      assignParts(sim.s)
    end
    # Step
    step(sim.s)
  end


  # Reset particles' origins after equilibriating
  for p in sim.s.parts
    p.org = p.pos
    p.sqd = 0.0
  end
  
  # Run each step
  for s in 1:nsteps
  
    # Update cells
    if(s%10 == 1)
      assignParts(sim.s)
    end
    # Step
    step(sim.s)
    
    # Collect data
    if(s%freq == 0)
      print("[")
      print("#"^int(s/nsteps*70))
      print("-"^(70-int(s/nsteps*70)))
      print("] $(int(s/nsteps*100))%\r")
      #print("\r\t"^(myid()*3))
      #print("$(myid()): $(int(s/conf["nsteps"]*100))%   ")

      t = s*sim.dimConst.dt
      writeParts(joinpath(sim.path, "parts"), sim.s.parts, t)

      avgmsd[int(s/freq), 1] = t
      avgmsd[int(s/freq), 2:end] = avgMSD(sim.dimConst, sim.s.parts)

    end
  end

  writeMSD(joinpath(sim.path,"msd"), avgmsd)

  log(sim.l, "Finished trial $(sim.id) in $(toq()) seconds")

end
