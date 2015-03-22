# Our physical constants
pc = BCIM.PhysicalConst(  1.0e-5,           # dt
                          0.60,             # phi
                          0.01,             # eta
                          298.0,            # temp
                          1.38e-16,         # boltz
                          [0.0,1.0e3],      # prop
                          [1.5e4,1.5e3],    # rep
                          [1.5e3, 0.0],     # adh
                          0.1,              # contact
                          15.0e-4,          # dia
                          [256,256])        # npart

pc.diffus = 0.000001
pc.rotdiffus = 0.00001

exp = BCIM.Experiment("experiment", 3, pc, false)

@test length(exp.trials) == 3
@test exp.trials[1].path == "experiment/trial1"
@test length(exp.trials[1].s.parts) == 512
@test exp.trials[1].s.parts[1].sqd == 0.0

BCIM.run(exp, 100:100:10000)
