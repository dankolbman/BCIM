abstract System

type Sphere <: System
  parts::Array{Part,1}
  cellGrid::CellGrid
  dimConst::DimensionlessConst
  radius::Float64
end

type Cylinder <: System
  parts::Array{Part,1}
  cellGrid::CellGrid
  dimConst::DimensionlessConst
  radius::Float64
  height::Float64
end

function Sphere(dc::DimensionlessConst)
  c = initCells(dc)
  p = uniformSphere(dc)
  r = dc.size
  return Sphere(p, c, dc, r)
end

function Cylinder(dc::DimensionlessConst)
  r = dc.size
  h = 5*r
  p = uniformCylinder(dc, r, h)
  c = initCells(2*r, 2*r, h, dc)
  return Cylinder(p, c, dc, r, h)
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
      parts[pl] = Part(pl, sp, xyz, [0, 0, 0], 2*pi*rand(2), rand()*dc.div[sp])
      pl += 1
    end
  end
  return parts
end

# Create a cylinder of particles
function uniformCylinder(dc::DimensionlessConst, r, h)
  parts = Array(Part,sum(dc.npart))
  pl = 1
  for sp in 1:length(dc.npart)
    for p in 1:dc.npart[sp]
      # This creates a uniform distribution in the sphere
      thet = 2*pi*rand()
      xyz = sqrt(r)*[ cos(thet), sin(thet), h*(rand()-0.5) ]
      parts[pl] = Part(pl, sp, xyz, [0, 0, 0], 2*pi*rand(2), rand()*dc.div[sp])
      pl += 1
    end
  end
  return parts
end

# Construct a system given particle counts and dimensionless parameters
function initCells(dc::DimensionlessConst)
  # The minimum size of the cells
  cellSize = dc.dia*(2*dc.contact+1.0)
  # The minimum number of cells of the given size
  cellNum = int(2*dc.size/cellSize)
  # The actual size of the cells
  cellSize = 2*dc.size/cellNum
  c = constructCells(cellNum, cellSize)

  return c
end

# Initializes cells for given width/length/height
function initCells(w::Float64, l::Float64, h::Float64, dc::DimensionlessConst)
  # Minimium cell size
  cellSize = dc.dia*(2*dc.contact+1.0)
  # Number of cells along each dimension
  D = int(w/cellSize)
  E = int(l/cellSize)
  F = int(h/cellSize)
  c = constructCells(D, E, F, cellSize)
  return c
end

# Initialize neighbor cells
function constructCells(D::Int, cellSize::Float64)
  return constructCells(D, D, D, cellSize)
end

function constructCells(D::Int, E::Int, F::Int, cellSize::Float64)
  tCell = D*E*F
  cells = Array(Cell, D, E, F)
  # Create cells
  for i in 1:tCell
    cell = Cell(i, Array(Cell,0), Array(Part,0))
    cells[i] = cell
  end
  # Link cells
  for dep in 1:D
    for col in 1:E
      for row in 1:F
        n = [cells[row,col,dep]]         # Add self reference
        for d in -1:1
          for c in -1:1
            for r in -1:1
              if( !(d == 0 && c == 0 && r == 0) )
                if(getNeighbor(cells, row+r, col+c, dep+d, D, E, F) != None)
                  push!(n, getNeighbor(cells, row+r, col+c, dep+d, D, E, F))   # Beautiful
                end
              end
            end
          end
        end
        cells[row,col,dep].neighbors = n # Neighbor list update
      end
    end
  end
  return CellGrid(cells, [D, E, F], cellSize)
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
function getNeighbor( cells::Array{Cell}, row, col, dep, D, E, F )
  if( row > 0 && col > 0 && dep > 0 && row <= D && col <= E && dep <= F)
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
    # Transpose to positive coords
    pos = p.pos + [s.dimConst.size, s.dimConst.size, s.dimConst.size]
    hash = (div(pos[1], cSize) + div(pos[2], cSize)*s.cellGrid.cellNum[2]
            + div(pos[3], cSize)*s.cellGrid.cellNum[3]^2 + 1)
    hash = int(hash)
    push!(s.cellGrid.cells[hash].parts, p)
  end
end

# Logistic function with k = 5/div_time
# Params:
#   div_timer - the current timer on the particle
#   div_time - the time to divide
function div_prob( div_timer, div_time )
  #return 1/(1+exp(-1000/div_time*(div_timer - div_time)))
  return div_timer < div_time ? 0 : 1
end

function divide(s::System)
  if( maximum(s.dimConst.div) > 0.0)
    for p in s.parts
      # Should the cell be divided
      if rand() < div_prob( p.div, s.dimConst.div[p.sp] )
        p.div = 0
        part = deepcopy(p)
        #append!(s.parts, part)
        s.parts = [ s.parts, part ]
        # Choose random direction to seperate in
        thet = 2*pi*rand()
        phi = 2*pi*rand()
        # Seperate particles by one radius in given direction
        d = s.dimConst.dia/2.0 *  [ sin(thet)*cos(phi),  sin(thet)*sin(phi), cos(thet) ]
        p.pos += d
        part.pos -= d
        part.org = part.pos
        # NB don't worry about containment issues, will be taken care of later in step
      else
        p.div += 1
      end
    end 
  end
end

function step(s::System)
  divide(s::System)
  forceCalc(s::System)
end
