.. man-install

**************
Installation
**************

BCIM's simulation portion is written in the `Julia`_ programming language.
It is built using a relatively recent release of the development build (``0.4``).
It may work on the current stable release (``0.3.6``), though it has not been tested.

.. _Julia: http://julialang.org/

Intstalling Julia
-----------------

The nightly build is recommended as development on BCIM is done on the developmental
release branch. Nightlies can be found on the `Julia download page`_. Better yet, 
build julia from source using the directions on the `Julia github`_.

.. _Julia download page: http://julialang.org/downloads/

.. _Julia github: https://github.com/JuliaLang/julia#source-download-and-compilation

Python
------

Post processing is done in ``python 3.6``, though any release of ``python 3``
should work.
Follow a guide online on how to install ``python 3`` for your environment.

Matplotlib and Numpy
--------------------

BCIM uses ``Matplotlib`` for graphics and ``Numpy`` for numerical work.
Both can be installed using ``pip``:

.. doctest::

    pip install numpy matplotlib

BCIM
----

BCIM can be installed by cloning into the git repository on github:

.. doctest::
  
    git clone https://github.com/dankolbman/BCIM
    cd BCIM

The ``src`` directory will have to be added to your shell path or the
``src/julia/BCIM.jl`` module can be inculeded by absolute reference inside
your run files.
