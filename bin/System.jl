##
# The physical system
#
# Dan Kolbman
##

type System
  parts::Array{Part}  # Particles in the system
  partCnts::Array{Int} # Number of particles in each species
  cells::Array{Cell}  # Cell list
  size::Float64       # Size of the system
  cellSize::Float64   # The size of each cell
end

# Construct from a config dict
function System(conf)
  # Size of the environment
  size = conf["size"]
  # Get particle counts for each species
  pCnts = Array(Int, length(conf["npart"]))
  for sp in 1:length(conf["npart"])
    pCnts[sp] = int(conf["npart"][sp])
  end

  # Generate a system for the desired number of particles
  p = uniformSphere(pCnts, size-conf["dia"]/2.0)
  
  # Determine cell size
  D = conf["dia"]*(2.0*conf["contact"]+1.0)
  D = int(conf["size"]*2.0 / D)
  # Make of the cell grid using the cell dimensions
  c = initCells(D)
  return System(p, pCnts, c,  D, size)
end


# Construct system with part counts and system size
function System(partCnts::Array{Int64,1}, size::Float64, cellSize::Float64)
  parts = uniformSphere(partCnts, size)
  D = int(ceil(size*2.0/cellSize))
  cells = initCells(D)
  return System(parts, partCnts, cells, size, cellSize)
end

# Generates particles randomly inside a sphere
# Params
#   pCnts - an array with the each element representing a species and # of particles
#   size - the size of the system
# Returns
#   A particle species array
function uniformSphere(pCnts::Array{Int}, size::Float64)
  # Creates an array for all the particles
  parts = Array(Part, sum(pCnts))
  # Number of particles placed
  pl = 1
  # Iterate through each species where each element of pCnts is a species
  for sp in 1:length(pCnts)
    # Place each particle in that species
    for p = 1:pCnts[sp]
      # This creates a uniform distribution in the sphere
      lam = size*cbrt(rand())
      u = 2.0*rand()-1.0
      phi = 2.0*pi*rand()
      xyz = [ lam*sqrt(1.0-u^2)*cos(phi), lam*sqrt(1.0-u^2)*sin(phi), lam*u ]
      parts[pl] = Part(pl, sp, xyz, [0.0, 0.0, 0.0], 2.0*pi*rand(2))
      pl += 1
    end
    #pl += int(conf["npart"][sp])
  end
  return parts
end


# Initialize neighbor cells
# Params
#   D - the number of cells per side
function initCells(D::Int)
  tCell = D*D*D
  cellGrid = Array(Cell, D, D, D)
  # Create cells
  for i in 1:tCell
    cell = Cell(i, Array(Cell,0), Array(Part,0))
    cellGrid[i] = cell
  end
  # Link cells
  for dep in 1:D
    for col in 1:D
      for row in 1:D
        n = [cellGrid[row,col,dep]]         # Add self reference
        for d in -1:1
          for c in -1:1
            for r in -1:1
              if( d != 0 && c != 0 && r != 0)
                if(getNeighbor(cellGrid, r, c,d, D) != None)
                  push!(n, getNeighbor(cellGrid, r, c, d, D))   # Beautiful
                end
              end
            end
          end
        end
        cellGrid[row,col,dep].neighbors = n # Neighbor list update
      end
    end
  end
  return cellGrid
end

# Gets a cell at the given location after checking that it is in bounds
# Parameters:
#   cellGrid - The 3D grid of cells to get a cell from
#   row - The row coordinate
#   col - The col coordinate
#   dep - The depth cordinate
#   D - The number of cells per dimension
# Returns:
#   A cell or None if request coord is out of bounds
function getNeighbor( cellGrid, row, col, dep, D )
  if( row > 0 && col > 0 && dep > 0 && row <= D && col <= D && dep <= D)
    return cellGrid[row, col, dep]
  else
    return None
  end
end

# Assign particles to cells
# Params
#   conf - the configuration dict
#   parts - the particle array
#   cellGrid - an N dimensional array of cells
function assignParts(system::System)
  cSize = system.cellSize
  # Clear all current particle lists for cells
  for c in system.cells
    c.parts = Array(Part, 0)
  end
  for p in system.parts
    pos = p.pos + [system.size, system.size, system.size]
    hash = (div(pos[1], cSize) + div(pos[2], cSize)*system.cellNum
            + div(pos[3], cSize)*system.cellNum^2 + 1)
    hash = int(hash)
    push!(system.cells[hash].parts, p)
  end
end
