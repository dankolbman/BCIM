##
# A brownian colloid (s)imulator
#
# Dan Kolbman
##

module BCIM
  # Types
  include("Types.jl")

  # Statistics
  include("Stats.jl")

  
  # Simulations and experiments
  include("CellGrid.jl")
  include("System.jl")
  include("Simulation.jl")
  include("Experiment.jl")

  # Saving particle data and configurations
  include("DataIO.jl")

  # Dynamics and physics
  include("Dynamics.jl")

end
