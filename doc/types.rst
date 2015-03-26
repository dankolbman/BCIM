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

.. function:: Experiment( path, ntrials, pc, timestamp=false )

    :param path: the path to save the experiment directory in
    :param ntrials: nuber of identical simulations to run
    :param pc: the physical constants for the simulation systems
    :param timestamp: whether or not to append current time to the end of the
      experiment directory. Useful for avoiding name conflicts and over writing data.

    Creates an experiment. Saves the pysical constants, ``pc``, and dimensionless
    constants calculated from ``pc``, to the ``path`` in ``.dat`` format. It
    creates ``ntrials`` number of simulations with parameters deteremined from
    ``pc`` and paths within the ``path`` directory. If ``timestamp`` is ``true``,
    the date is append to the ``path`` name.

.. function:: run( exp, r )

    :param path: the experiment to run
    :param r: the step values to run each simulation for

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

    :param dir: the directory path where a simulation directory will be created
    :param dc: Dimensionless constants to be used for the simulation
    :param log: The log to use for the simulation

    Create a simulation. An ``id`` is assigned based on the next available 
    directory in ``dir`` folling the convention: ``dir/trial$id``. ``dc`` is 
    a dimensionless contant object that is used to initialize the simulation
    system. ``log`` is a log object for the system to use for logging.

.. function:: Simulation( id, path, dc, log)

    :param id: a unique integer identifier for the simulation
    :param path: the directory where the simulation files will be stored
    :param dc: the dimensionless constants for the simulation
    :param log: the log to use for the simulation

    Creates a simulation. ``id`` is a unique identifier for the simulation.
    ``path`` is where the simulation will place output files. ``dc`` is a 
    dimensienless constant object for creating the system with. ``log`` is
    used to log simulation messages.


.. function:: run( sim, r )

    :param sim: the simulation to be run
    :param r: the step parameters to run for

    Runs simulation, ``sim``, for range ``r``. ``r`` is of the format:
    ``equilibrium:frequency:steps`` where ``equilibrium`` is the number of 
    steps to equilibriate the system for, ``frequency`` is how often to save
    the system state, and ``steps`` is how many steps to run for after
    equilibrium steps have been taken.

    Example

    .. code-block:: julia

        # initialize sim for 100 steps, then run for 5000 steps
        # and take measurements every 1000 steps
        run( sim, 100:1000:5000 )


Physical Constants
******************

The  ``PhysicalConst`` type has many fields describing the physical (dimensional)
parameters of the system:

.. function:: PhysicalConst(dt,phi,eta,temp,boltz,prop,rep,adh,contact,dia,npart,diff,rotdiff)


    :param dt: the time constant
    :param phi: the packing fration
    :param eta: the viscosity
    :param temp: the system temperature
    :param boltz: boltzmann's constant
    :param prop: the propulsion for each species
    :param rep: the repulsion for each species
    :param adh: the adhesion for each species
    :param contact: the contact distance as a fraction of the diameter
    :param dia: the diameter of each particle
    :param npart: the number of particles of each species
    :param diff: the diffusion
    :param rotdiff: the rotational diffusion


Dimensionless Constants
***********************

The DimensionlessConst type has many fields corresponding to dimensionless
parameters of the system. A dimensionless type can be invoked by passing it
a ``PhysicalConst`` type from which it will produce dimensionless parameters
by scaling appropriatly.

.. function:: DimensionlessConst(dt,phi,eta,temp,boltz,prop,rep,adh,contact,dia,npart,diff,rotdiff,pretrad,prerotd)

    :param dt: the time constant
    :param phi: the packing fration
    :param eta: the viscosity
    :param temp: the system temperature
    :param boltz: boltzmann's constant
    :param prop: the propulsion for each species
    :param rep: the repulsion for each species
    :param adh: the adhesion for each species
    :param contact: the contact distance as a fraction of the diameter
    :param dia: the diameter of each particle
    :param npart: the number of particles of each species
    :param diff: the diffusion
    :param rotdiff: the rotational diffusion
    :param pretrad: the prefactor for translational diffusion
    :param prerotd: the prefactor for rotational diffusion


System
******

The ``System`` type is used to represent a physical system. It holds a list of
particles which it is simulating, the dimensionless parameters of the system,
and a ``CellGrid`` which is used to efficiently sort and simulate the particles.

.. function:: System( dc )

    :param dc: the dimensionless contstants for the system

    Initializes a system using the dimensionless parameters ``dc``. Constructs
    a cell grid and particles based on the specification of the parameters.

.. function:: uniformSphere( dc )

    :param dc: the dimensionless contstants for the system

    Creates a list of particles, the number of which are specified by the npart
    field of ``dc``, that have been randomly distributed in a sphere.

.. function:: step( s )

    :param s: the system to make a step on

    Steps a system ``s`` by one step by calling the force calculation function.

.. function:: assignParts( s )

    :param s: the system to assign particles in

    Assigns particles in a system into Cells in the system's ``CellGrid``. Called
    by ``Simulation`` during a run periodically so collision checks can be made
    efficiently using the cell grid.


Part
****

The ``Part`` type is used to represent a particle in the system.

.. function:: Part(id,sp,pos,vel,ang)

    :param id: the particle id
    :param sp: the particle species
    :param pos: the position vector of the particle
    :param vel: the velocity vector of the particle
    :param ang: the angle vector of the particle


Log
***

.. function:: Log(path, verbose=false)

    :param path: the file to output logs to
    :param verbose: whether or not to pipe log to STDIN in addition to the file

.. function:: log(l, output)

    :param l: the log instance being logged to
    :param output: the output string to write

