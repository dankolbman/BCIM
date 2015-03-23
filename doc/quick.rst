.. man-quick:

**************
Quick Example
**************

The following can be found in ``examples/num_parts.jl`` in the source.
It creates an experiment with three trials and runs each one. It then
modifies the parameters and creates a new experiment with a different number
of particles. It repeats this three times for three different experiments each
with three identical trials.


.. doctest::

    include("../src/julia/BCIM.jl")
    #using BCIM
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

    ##### 256 particles total
    pc.npart = [128, 128]
    # Initialize experiment with 3 trials and predefined path
    exp = BCIM.Experiment("data/num_parts/256", 3, pc, false)
    # Run the experiment
    # Equilibriate for 1000 steps
    # Collect every 1000 steps
    # Run for 100000 steps
    BCIM.run(exp, 1000:1000:100000)
    
    ##### 512 particles total
    pc.npart = [256, 256]
    exp = BCIM.Experiment("data/num_parts/512", 3, pc, false)
    BCIM.run(exp, 1000:1000:100000)
    
    ##### 1024 particles total
    pc.npart = [512, 512]
    exp = BCIM.Experiment("data/num_parts/1024", 3, pc, false)
    BCIM.run(exp, 1000:1000:100000)
