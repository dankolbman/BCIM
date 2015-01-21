# Our physical constants
pc = BCIM.PhysicalConst( 1.0e-4, 0.40, 0.01, 298.0, 1.38e-16,
                    [1.0e3,1.0e3], [1.5e4,1.0e3], [1.5e3, 0.0],
                    15.0e-4, 1.5e-3, [512,512], 15.0, 15.0 )

# Make them dimensionless
dc = BCIM.DimensionlessConst(pc)

@test dc.utime == pc.dia^2/pc.diffus

exp = BCIM.Experiment("experiment", 3, dc)

@test length(exp.trials) == 3
@test exp.trials[1].path == "experiment/trial1"
@test length(exp.trials[1].s.parts) == 1024
@test exp.trials[1].s.parts[1].sqd == 0.0
