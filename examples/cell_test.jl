## Runs a experiments for diffrent numbers of particles
# Each experiment consists of three trials
# Saves data to data/numparts/ relative to run path

include("../src/julia/BCIM.jl")
#using BCIM

# Our physical constants
pc = BCIM.PhysicalConst(  1.0e-5,           # dt
                          0.7,             # phi
                          0.01,             # eta
                          298.0,            # temp
                          1.38e-16,         # boltz
                          [0.0,1.0e3],      # prop
                          [1546, 510.6],    # rep
                          [1500, 0.0],     # adh
                          [ 0.0, 0.0 ],     # div
                          0.2,              # contact
                          15.0e-4,          # dia
                          [256,256])        # npart

dc = BCIM.DimensionlessConst(pc)
dc.rotdiffus = 0.01 * dc.rotdiffus
dc.prerotd = sqrt( 2.0*dc.rotdiffus*dc.dt )

##### 256 particles total
# Initialize experiment with 3 trials and predefined path
#s = BCIM.Cylinder(dc)
s = BCIM.Sphere(dc)
exp = BCIM.Experiment("data/grid_test", 1, dc, s, false)
BCIM.run(exp, 10:10:1000)
