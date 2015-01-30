##
# A brownian colloid (s)imulator
#
# Dan Kolbman
##

module BCIM
  # Types
  include("Types.jl")

  # Saving particle data and configurations
  #include("DataIO.jl")
  
  #require("Notebook.jl")

  # For loading configs
  #include("Configuration.jl")

  # Statistics
  #include("Stats.jl")

  
  # Simulations and experiments
  include("CellGrid.jl")
  include("System.jl")
  include("Simulation.jl")
  include("Experiment.jl")

  # Dynamics and physics
  include("Dynamics.jl")

end
