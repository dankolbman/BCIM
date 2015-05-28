.. man-examples

**************
Examples
**************

Running
*******

To run a simulation like the example below, Julia must be invoked from the top
level directory of the repository (where the ``src`` folder resides), a from
a directory that is appropriate for the ``include`` statement to find the source
files. The simulation can then be run by passing the script to Julia:

    julia examples/num_part.jl

Running on a Cluster
*******************

Using slurm, many identical simulations can be run at once. The following will
run the `adh.jl` script on 10 different cores with 2048Mb allocated on each.

     srun -N 10 -t 2000 --mem-per-cpu=2048 julia runs/vary_params/adh.jl 



Quick Example
**************


The following can be found in ``examples/num_parts.jl`` in the source.
It creates an experiment with three trials and runs each one. It then
modifies the parameters and creates a new experiment with a different number
of particles. It repeats this three times for three different experiments each
with three identical trials.

.. literalinclude:: ../examples/num_parts.jl
    :linenos:
    :language: julia
