.. man-experiments:

**************
Experiments
**************

The experiment type is used to handle several trials of a simulation. It is 
responsible for creating paths for the trial simulations and saving parameters
for them.

Functions
---------

.. function:: Experiment( path, ntrials, pc, [timestamp=false] )

    Creates an experiment. Saves the pysical constants, ``pc``, and dimensionless
    constants calculated from ``pc``, to the ``path`` in ``.dat`` format. It
    creates ``ntrials`` number of simulations with parameters deteremined from
    ``pc`` and paths within the ``path`` directory. If ``timestamp`` is ``true``,
    the date is append to the ``path`` name.

.. function:: run( exp, r )

    Runs an experiment, ``exp``, by invoking ``run`` on each trial simulation.
    ``r`` is the range to run each simulation and is of the format:
    ``equilibrium:frequency:steps`` where ``equilibrium`` is the number of 
    steps to equilibriate the system for, ``frequency`` is how often to save
    the system state, and ``steps`` is how many steps to run for after
    equilibrium steps have been taken.


    
