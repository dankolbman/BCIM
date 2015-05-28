## Runs a experiments for diffrent numbers of particles
# Each experiment consists of three trials
# Saves data to data/numparts/ relative to run path

include("../src/julia/BCIM.jl")
#using BCIM

# Our physical constants
pc = BCIM.PhysicalConst(  1.0e-5,           # dt
                          # Packing fraction
                          0.60,
                          # Eta
                          0.01,
                          # Temperature (K)
                          298.0,
                          # Boltzmann constant
                          1.38e-16,
                          # Propulsisions [ sp1, sp2 ]
                          [0.0,1.0e3],
                          # Repulsions [ sp1, sp2 ]
                          [1.5e4,1.5e3],
                          # Adhesions [ sp1, sp2, sp1-sp2 ]
                          [1.5e3, 0.0, 0.0 ],
                          # Cell division time ( 0 = no division)
                          [ 0.01, 0.01 ],
                          # Efective adhesive contact distance
                          0.1,
                          # Cell diameter
                          15.0e-4,
                          # Number of particles [ sp1, sp2 ]
                          [256,256])

##### 256 particles total
pc.npart = [128, 128]
# Initialize experiment with 3 trials in given directory with desired constants
exp = BCIM.Experiment("data/ex/256", 3, pc, false)

# Run the experiment
# Equilibriate for 1000 steps
# Collect every 1000 steps
# Run for 100000 steps
BCIM.run(exp, 1000:1000:100000)

##### Run again for 512 particles total
pc.npart = [256, 256]
exp = BCIM.Experiment("data/ex/512", 3, pc, false)
BCIM.run(exp, 1000:1000:100000)

##### 1024 particles total
pc.npart = [512, 512]
exp = BCIM.Experiment("data/ex/1024", 3, pc, false)
BCIM.run(exp, 1000:1000:100000)
