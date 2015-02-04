include("../src/BCIM.jl")

# Our physical constants
pc = BCIM.PhysicalConst(1.0e-4,          # dt
                        0.40,            # phi
                        0.01,             # eta
                        298.0,            # temp
                        1.38e-16,         # boltzmann
                        [1.0e3,1.0e3],    # prop
                        [1.5e4,1.0e3],    # rep
                        [1.5e3, 0.0],     # adh
                        15.0e-4,          # contact
                        1.5e-3,           # dia
                        [512,512] )       # npart

exp = BCIM.Experiment("two-species", 3, pc)

BCIM.run(exp, 100:100:1000)
