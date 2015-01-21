type Simulation
  path::ASCIIString
  s::System
  nequil::Int
  nsteps::Int
  freq::Int
  dimConst::DimensionlessConst
end

function Simulation(path::ASCIIString, r::Range{Int}, dc::DimensionlessConst)
  nequil = first(r)-1
  freq = r.step
  nsteps = last(r)
  return Simulation(path, nequil, nsteps, freq, dc)
end

function Simualtion(path::ASCIIString, nequil::Int, nsteps::Int, freq::Int, dc::DimensionlessConst)
  s = System(dc)
  return Simulation(path, s, nequil, nsteps, freq, dc)
end

function run(sim::Simulation, steps::Range{int})

  tic()
  # Equilibriate
  for s in 1:sim.nequil
    # Update cells
    if(s%10 == 1)
      assignParts(sim.system)
    end
    # Step
    step(sim.system, sim.exp.dimConst)
  end

  # Reset particles' origins after equilibrating
  for p in sim.s.parts
    p.org = p.pos
  end

  # Run each step
  for s in 1:sim.exp.nstep

    # Update cells
    if(s%10 == 1)
      assignParts(sim.system)
    end
    # Step
    step(sim.system)
    
    # Collect data
    if(s%sim.freq == 0)
      print("[")
      print("#"^int(s/sim.nstep*70))
      print("-"^(70-int(s/sim.nstep*70)))
      print("] $(int(s/sim.nstep*100))%\r")
      #print("\r\t"^(myid()*3))
      #print("$(myid()): $(int(s/conf["nsteps"]*100))%   ")

      t = s*sim.dimConst.dt
      DataIO.writeParts("$(sim.path)parts", sim.s.parts, t)

      # Calculate msd
      avgmsd[int(s/sim.exp.freq), 1] = t
      # avgMSD() updates sq displacements and returns avg msd for all species
      avgmsd[int(s/sim.exp.freq), 2:end] = Stats.avgMSD(sim.system)
    end
  end
  DataIO.writeMSD("$(sim.path)msd", avgmsd)

  post(sim)
  
  DataIO.log("Trial ended taking $(toq()) seconds")

end

function save(sim::Simulation)

end

function load(sim::Simulation)

end

function post(sim::Simulation)

end
