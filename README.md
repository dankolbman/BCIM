BCIM
====
[![Documentation Status](https://readthedocs.org/projects/bcim/badge/?version=latest)](https://readthedocs.org/projects/bcim/?badge=latest)

### Dependencies

#### Julia

The simulation functionality relies on [Julia](http://julialang.org/) which is
itself under constant release. BCIM is developed on the latest versions of
Julia, though release 0.3 and later should be sufficient to run BCIM.

See the [downloads page](http://julialang.org/downloads/) for the latest
Julia releases.

#### Numpy and Matplotlib

Post processing in done in python (3.4) and [numpy](www.numpy.org) with 
plotting in [matplotlib](http://matplotlib.org/). If post processing is not
required, the appropriate python scripts can be removed from the configuration
file for simulations.

Numpy and matplotlib can be installed through pip:

    sudo pip install numpy
    sudo pip install matplotlib
