BCIM
====

## Installing

BCIM is in a state of rapid development so the installation and stability of 
some features may not be reliable at all times. Nevertheless, here is the
general method of installation.

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

#### Pelican

BCIM includes note book functionality to keep track of simulation results and
notes. Note book scripts are written in python and parsed to html by 
[Pelican](http://blog.getpelican.com/). These features can also be disabled
by modifying the relevant parameters in a BCIM configuration file.

Pelican can be installed throug pip:

    sudo pip install pelican 
