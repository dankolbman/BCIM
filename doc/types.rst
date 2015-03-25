.. man-types:

**************
Types
**************


Experiment
**************

The experiment type is used to handle several trials of a simulation. It is 
responsible for creating paths for the trial simulations and saving parameters
for them.

Functions
----------

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


Simulation
**************

The simulation type is used to contstruct a simulation system and run it for a
desired amount of steps. It is responsible for steping the system and performing
scheduled analysis of the system state, including writing the state to disk and
calculating statistical quantities for the system.

Functions
---------


.. function:: Simulation( dir, dc, log)

    Create a simulation. An ``id`` is assigned based on the next available 
    directory in ``dir`` folling the convention: ``dir/trial$id``. ``dc`` is 
    a dimensionless contant object that is used to initialize the simulation
    system. ``log`` is a log object for the system to use for logging.


.. function:: Simulation( id, path, dc, log)

    Creates a simulation. ``id`` is a unique identifier for the simulation.
    ``path`` is where the simulation will place output files. ``dc`` is a 
    dimensienless constant object for creating the system with. ``log`` is
    used to log simulation messages.

.. function:: run( sim, r )

    Runs simulation, ``sim``, for range ``r``. ``r`` is of the format:
    ``equilibrium:frequency:steps`` where ``equilibrium`` is the number of 
    steps to equilibriate the system for, ``frequency`` is how often to save
    the system state, and ``steps`` is how many steps to run for after
    equilibrium steps have been taken.

.. code-block::

    # initialize sim for 100 steps, then run for 5000 steps
    # and take measurements every 1000 steps
    run( sim, 100:1000:5000 )


Physical Constants
******************

The  ``PhysicalConst`` type has many fields describing the physical (dimensional)
parameters of the system:

``dt`` - the time constant
``phi`` - the packing fration
``eta`` - the viscosity
``temp`` - the system temperature
``boltz`` - boltzmann's constant
``prop`` - the propulsion for each species
``rep`` - the repulsion for each species
``adh`` - the adhesion for each species
``contact`` - the contact distance as a fraction of the diameter
``dia`` - the diameter of each particle
``npart`` - the number of particles of each species
``diff`` - the diffusion
``rotdiff`` - the rotational diffusion



Dimensionless Constants
***********************

The DimensionlessConst type has many fields corresponding to dimensionless
parameters of the system. A dimensionless type can be invoked by passing it
a ``PhysicalConst`` type from which it will produce dimensionless parameters
by scaling appropriatly.

``dt`` - the time constant
``phi`` - the packing fration
``eta`` - the viscosity
``temp`` - the system temperature
``boltz`` - boltzmann's constant
``prop`` - the propulsion for each species
``rep`` - the repulsion for each species
``adh`` - the adhesion for each species
``contact`` - the contact distance as a fraction of the diameter
``dia`` - the diameter of each particle
``npart`` - the number of particles of each species
``diff`` - the diffusion
``rotdiff`` - the rotational diffusion
``pretrad`` - the prefactor for translational diffusion
``prerotd`` - the prefactor for rotational diffusion

System
******

The ``System`` type is used to represent a physical system. It holds a list of
particles which it is simulating, the dimensionless parameters of the system,
and a ``CellGrid`` which is used to efficiently sort and simulate the particles.

.. function:: System( dc )

    Initializes a system using the dimensionless parameters ``dc``. Constructs
    a cell grid and particles based on the specification of the parameters.

.. function:: uniformSphere( dc )

    Creates a list of particles, the number of which are specified by the npart
    field of ``dc``, that have been randomly distributed in a sphere.

.. function:: step( s )

    Steps a system ``s`` by one step by calling the force calculation function.

.. function:: assignParts( s )

    Assigns particles in a system into Cells in the system's ``CellGrid``. Called
    by ``Simulation`` during a run periodically.


Part
****

The ``Part`` type is used to represent a particle in the system.

Log
***


