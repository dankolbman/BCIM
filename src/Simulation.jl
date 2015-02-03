type Simulation
  path::ASCIIString
  s::System
  dimConst::DimensionlessConst
end

function Simulation(path::ASCIIString, dc::DimensionlessConst)
  s = System(dc)
  return Simulation(path, s, dc)
end

# Runs the simulation for the desired time
function run(sim::Simulation, r::Range{Int})

  nequil = first(r)-1
  freq = r.step
  nsteps = last(r)
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

    end
  end

end
