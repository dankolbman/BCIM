##
# The physical system
#
# Dan Kolbman
##

type System
  parts::Array{Part}
  cells::Array{Cell}
  size::Float64
end

# Generates particles randomly inside a sphere
# Params
#   conf - the configuration dict with experiment parameters
# Returns
#   A particle species array
function makeRanSphere(conf)
  # Creates an array for all the particles
  parts = Array(Part, int(conf["tpart"]))
  # Number of particles placed
  pl = 1
  # Iterate through each species
  for sp in 1:length(conf["npart"])
    for p = 1:int(conf["npart"][sp])
      # This creates a uniform distribution in the sphere
      lam = (conf["size"]-conf["dia"]/2)*cbrt(rand())
      u = 2*rand()-1
      phi = 2*pi*rand()
      xyz = [ lam*sqrt(1-u^2)*cos(phi), lam*sqrt(1-u^2)*sin(phi), lam*u ]
      parts[pl] = Part(pl, sp, xyz, [0, 0, 0], 2*pi*rand(2))
      pl += 1
    end
    #pl += int(conf["npart"][sp])
  end
  return parts
end


# Initialize neighbor cells
# Params
#   conf - the configuration dict
function initCells(conf)
  # Determine number of cells along a dimension
  conf["D"] = conf["dia"]*(2*conf["contact"]+1)
  conf["D"] = int(conf["size"]*2 / conf["D"])
  D = conf["D"]
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
function assignParts(conf, parts, cellGrid)
  cSize = conf["size"]*2 / conf["D"]
  D = conf["D"]
  # Clear all current particle lists for cells
  for c in cellGrid
    c.parts = Array(Part, 0)
  end
  for p in parts
    pos = p.pos + [conf["size"], conf["size"], conf["size"]]
    hash = (div(pos[1], cSize) + div(pos[2], cSize)*D
            + div(pos[3], cSize)*D*D + 1)
    hash = int(hash)
    push!(cellGrid[hash].parts, p)
  end
end
