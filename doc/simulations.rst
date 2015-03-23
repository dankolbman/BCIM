.. _man-simulations:

**************
Simulations
**************

The simulation type is used to contstruct a simulation system and run it for a
desired amount of steps. It is responsible for steping the system and performing
scheduled analysis of the system state, including writing the state to disk and
calculating statistical quantities for the system.

Functions
--------


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

.. doctest::

    # initialize sim for 100 steps, then run for 5000 steps
    # and take measurements every 1000 steps
    run( sim, 100:1000:5000 )

