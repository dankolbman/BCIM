type System
  parts::Array{Part,1}
  cellGrid::CellGrid
  dimConst::DimensionlessConst
end

# Construct a system given particle counts and dimensionless parameters
function System(dc::DimensionlessConst)
  # The minimum size of the cells
  cellSize = dc.dia*(2*dc.contact+1)
  # The minimum number of cells of the given size
  cellNum = int(2*dc.size/cellSize)
  # The actual size of the cells
  cellSize = 2*dc.size/cellNum
  p = constructParts(dc)
  c = constructCells(cellNum, cellSize)

  return System(p, c, dc)
end

# Build particles for the system
function constructParts(dc::DimensionlessConst)
  return uniformSphere(dc)
end

function uniformSphere(dc::DimensionlessConst)
  parts = Array(Part,sum(dc.npart))
  pl = 1
  for sp in 1:length(dc.npart)
    for p in 1:dc.npart[sp]
      # This creates a uniform distribution in the sphere
      lam = (dc.size-dc.dia/2.0)*cbrt(rand())
      u = 2*rand()-1
      phi = 2*pi*rand()
      xyz = [ lam*sqrt(1-u^2)*cos(phi), lam*sqrt(1-u^2)*sin(phi), lam*u ]
      parts[pl] = Part(pl, sp, xyz, [0, 0, 0], 2*pi*rand(2)) 
      pl += 1
    end
  end
  return parts
end


# Initialize neighbor cells
function constructCells(D::Int, cellSize::Float64)
  tCell = D*D*D
  cells = Array(Cell, D, D, D)
  # Create cells
  for i in 1:tCell
    cell = Cell(i, Array(Cell,0), Array(Part,0))
    cells[i] = cell
  end
  # Link cells
  for dep in 1:D
    for col in 1:D
      for row in 1:D
        n = [cells[row,col,dep]]         # Add self reference
        for d in -1:1
          for c in -1:1
            for r in -1:1
              if( d != 0 && c != 0 && r != 0)
                if(getNeighbor(cells, r, c,d, D) != None)
                  push!(n, getNeighbor(cells, r, c, d, D))   # Beautiful
                end
              end
            end
          end
        end
        cells[row,col,dep].neighbors = n # Neighbor list update
      end
    end
  end
  return CellGrid(cells, D, cellSize)
end

# Gets a cell at the given location after checking that it is in bounds
# Parameters:
#   cellsGrid - The 3D grid of cells to get a cell from
#   row - The row coordinate
#   col - The col coordinate
#   dep - The depth cordinate
#   D - The number of cells per dimension
# Returns:
#   A cell or None if request coord is out of bounds
function getNeighbor( cells::Array{Cell}, row, col, dep, D )
  if( row > 0 && col > 0 && dep > 0 && row <= D && col <= D && dep <= D)
    return cells[row, col, dep]
  else
    return None
  end
end

# Assign particles to cells
# Params
#   conf - the configuration dict
#   parts - the particle array
#   cells - an N dimensional array of cells
function assignParts(s::System)
  cSize = s.cellGrid.cellSize
  # Clear all current particle lists for cells
  for c in s.cellGrid.cells
    c.parts = Array(Part, 0)
  end
  for p in s.parts
    pos = p.pos + [s.dimConst.size, s.dimConst.size, s.dimConst.size]
    hash = (div(pos[1], cSize) + div(pos[2], cSize)*s.cellGrid.cellNum
            + div(pos[3], cSize)*s.cellGrid.cellNum^2 + 1)
    hash = int(hash)
    push!(s.cellGrid.cells[hash].parts, p)
  end
end

function step(s::System)
  forceCalc(s::System)
end