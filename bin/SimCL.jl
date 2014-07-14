##
# Simulation using opencl #
# Dan Kolbman 2014
##

module SimCL

import OpenCL
const cl = OpenCL

import DataIO
import Dynamics
import Stats

include("Types.jl")

# Run a simulation using openCL
function runSim(conf, simPath="")

  ndata = int(conf["nsteps"]/conf["freq"])
  avgmsd = zeros(Float64, ndata, size(conf["npart"],1)+1)

  # Create the context
  DataIO.log("Creating OpenCL context", conf)
  device, ctx, queue = cl.create_compute_context()


  DataIO.log("-"^60, conf)
  DataIO.log("OpenCL Device Information:", conf)
  DataIO.log("Name: $(device[:name])", conf)
  DataIO.log("Type: $(device[:device_type])", conf)
  DataIO.log("Mem: $(device[:global_mem_size]/(1024^2))MB", conf)
  DataIO.log("Max Mem Alloc: $(device[:max_mem_alloc_size]/(1024^2))MB", conf)
  DataIO.log("Max Clock Freq: $(device[:max_clock_frequency])MHZ", conf)
  DataIO.log("Max Compute Units: $(device[:max_compute_units])", conf)
  DataIO.log("Max Work Group Size: $(device[:max_work_group_size])", conf)
  DataIO.log("Max Work Item Size$(device[:max_work_item_size])", conf)
  DataIO.log("-"^60, conf)

  # Initialize particles
  DataIO.log("Initializing system of particles", conf)
  parts = init(conf, simPath)

  # The dimensionality of the system (2 or 3)
  DIMS = int(conf["dim"])

  # Need to turn all the particles into arrays of their parameters
  nparts = int(sum(conf["npart"]))
  h_sp = Array(Int32, nparts)
  h_pos = rand(Float32, nparts*DIMS)
  h_vel = Array(Float32, nparts*DIMS)
  h_ang = Array(Float32, nparts*(DIMS-1))

  # Need to linearize particle data to arrays
  for p in 1:size(parts,1)
    elm = ((p-1)*DIMS+1)
    h_sp[p] = parts[p].sp
    h_pos[elm:((p)*DIMS)] = [ parts[p].pos ]
    h_vel[elm:((p)*DIMS)] = parts[p].vel
    h_ang[(p-1)*(DIMS-1)+1:((p)*(DIMS-1))] = parts[p].ang
  end

  # Create device buffers for the parameter arrays
  DataIO.log("Creating OpenCL device buffers", conf)
  d_sp = cl.Buffer(Int32, ctx, :copy, hostbuf=h_sp)
  d_pos = cl.Buffer(Float32, ctx, :copy, hostbuf=h_pos)
  d_vel = cl.Buffer(Float32, ctx, :copy, hostbuf=h_vel)
  d_ang = cl.Buffer(Float32, ctx, :copy, hostbuf=h_ang)

  # Build the program
  DataIO.log("Building the OpenCL kernel functions", conf)
  #prg = cl.Program(ctx, source=buildKernel(conf, ctx)) |> cl.build!
  # buildKernel() now constructs a program object and returns it
  prg = buildKernel(conf,ctx)

  # This is faster than a modularized solution
  dynamics2D = cl.Kernel(prg, "dynamics2D")
  move2D = cl.Kernel(prg, "move2D")
  #brownian2D = cl.Kernel(prg, "brownian2D")
  #movePos2D = cl.Kernel(prg, "movePos2D")
  
  DataIO.log("Starting equilibriaton", conf)
  DataIO.writeParts("$(conf["path"])$(simPath)parts",parts,0.0)
  tic()
  for s in 1:int(conf["nequil"])
    cl.call(queue, dynamics2D, (nparts,) , nothing,
      int32(nparts), int32(2), int32(s),
      float32(conf["pretrad"]), float32(conf["prerotd"]),
      float32(conf["dia"]), float32(conf["contact"]),
      cl.Buffer(Float32, ctx, :copy, hostbuf=float32(conf["prop"])),
      cl.Buffer(Float32, ctx, :copy, hostbuf=float32(conf["rep"])),
      cl.Buffer(Float32, ctx, :copy, hostbuf=float32(conf["adh"])),
      d_sp, d_pos, d_vel, d_ang )

    cl.call(queue, move2D, (nparts,) , nothing,
      int32(nparts), int32(2), float32(conf["dt"]),
      float32(conf["dia"]), float32(conf["size"]),
      d_pos, d_vel )

  end
  toc()

  tic()
  DataIO.log("Starting simulation steps", conf)
  # Start the steps
  for s in 1:conf["nsteps"]

    cl.call(queue, dynamics2D, (nparts,) , nothing,
      int32(nparts), int32(2), int32(s),
      float32(conf["pretrad"]), float32(conf["prerotd"]),
      float32(conf["dia"]), float32(conf["contact"]),
      cl.Buffer(Float32, ctx, :copy, hostbuf=float32(conf["prop"])),
      cl.Buffer(Float32, ctx, :copy, hostbuf=float32(conf["rep"])),
      cl.Buffer(Float32, ctx, :copy, hostbuf=float32(conf["adh"])),
      d_sp, d_pos, d_vel, d_ang )

    cl.call(queue, move2D, (nparts,) , nothing,
      int32(nparts), int32(2), float32(conf["dt"]),
      float32(conf["dia"]), float32(conf["size"]),
      d_pos, d_vel )
    # This is slower because of the memory overhead required
    #cl.call(queue, brownian2D, (nparts,), nothing,
    #    int32(nparts), int32(DIMS), int32(s), float32(conf["pretrad"]), d_vel)
    #cl.call(queue, movePos2D, (nparts, DIMS), nothing,
    #    int32(nparts), int32(DIMS), float32(conf["dt"]), d_pos, d_vel)
    

    # Record data
    if(s%conf["freq"] == 0)
      print("[")
      print("#"^int(s/conf["nsteps"]*70))
      print("-"^(70-int(s/conf["nsteps"]*70)))
      print("] $(int(s/conf["nsteps"]*100))%\r")

      t = (s+int(conf["nequil"]))*conf["dt"]

      h_sp = cl.read(queue, d_sp)
      h_pos = cl.read(queue, d_pos)
      h_vel = cl.read(queue, d_vel)
      h_ang = cl.read(queue, d_ang)
      
      for p in 1:nparts
        # Copy back parameters into particle types
        elm = ((p-1)*DIMS+1)
        parts[p].sp = h_sp[p]
        parts[p].pos = h_pos[elm:p*DIMS]
        parts[p].vel = h_vel[elm:p*DIMS]
        parts[p].ang = h_ang[(p-1)*(DIMS-1)+1:(p*(DIMS-1))]
      end

      # TODO Now that all the particles are updated and stored on the host,
      # we can spawn a new process to take care of the analysis while the
      # main loop continues on with the simulation

      DataIO.writeParts("$(conf["path"])$(simPath)parts",parts,t)

      # Calculate msd
      avgmsd[int(s/conf["freq"]), 1] = t
      # avgMSD() updates sq displacements and returns avg msd for all species
      avgmsd[int(s/conf["freq"]), 2:end] = Stats.avgMSD(conf,parts)

    end

  end
  toc()
  println()
  DataIO.writeMSD("$(conf["path"])$(simPath)avgMSD", avgmsd)

end

# Initializes the physical environment
# Determine size of the system
# Generate particles
# Write data to file
# Params
#   conf - the configuration dict with experiment parameters
#   simPath - the path for the simulation to store files
# Returns
#   A particle array
function init(conf, simPath="")
  # The length of a side of a cube for the required packing fraction
  #conf["size"] = cbrt(4/3*pi*conf["dia"]^3/2/(conf["phi"]))
  if(conf["dim"] == 3)
    parts = makeRanSphere(conf)
  else 
    parts = makeRanCirc(conf)
  end
  DataIO.writeParts("$(conf["path"])/$(simPath)init",parts)

  return parts
end

# Generates particles randomly inside a sphere
# Params
#   conf - the configuration dict with experiment parameters
# Returns
#   An array of particles
function makeRanSphere(conf)
  # Creates an array for all the particles
  parts = Array(Part, int(sum(conf["npart"])),1)
  # Number of particles placed
  pl = 0
  # Iterate through each species
  for sp in 1:length(conf["npart"])
    for p = 1:int(conf["npart"][sp])
      # This creates a uniform distribution in the sphere
      lam = (conf["size"]-conf["dia"]/2)*cbrt(rand())
      u = 2*rand()-1
      phi = 2*pi*rand()
      xyz = [ lam*sqrt(1-u^2)*cos(phi), lam*sqrt(1-u^2)*sin(phi), lam*u ]
      parts[pl+p] = Part(sp, xyz, [0.0, 0.0, 0.0], 2*pi*rand(2))
    end
    pl += int(conf["npart"][sp])
  end
  return parts
end

# Generate particles randomly in a 2D circle
#   conf - the configuration dict with experiment parameters
# Returns
#   An array of particles
function makeRanCirc(conf)
  parts = Array(Part, int(sum(conf["npart"])),1)
  pl = 0
  for sp in 1:length(conf["npart"])
    for p in 1:int(conf["npart"][sp])
      r = sqrt(rand())
      thet = 2*pi*rand()
      xy = (conf["size"] - conf["dia"]/2)*r*[ cos(thet), sin(thet) ]
      parts[pl+p] = Part(sp, xy, [0.0, 0.0], [2*pi*rand()])
    end
    pl += int(conf["npart"][sp])
  end
  return parts
end

# Build kernel source and return Program
function buildKernel(conf, ctx)
 # ksrc = open(readall, "Dynamics.cl")
  err_code = Array(cl.CL_int, 1)
  # create program
  kernel_source = open(readall, "Dynamics.cl")

  bytesource = bytestring(kernel_source)
  prg_id = cl.api.clCreateProgramWithSource(ctx.id, 1, [bytesource], C_NULL, err_code)
  if err_code[1] != cl.CL_SUCCESS
      error("Failed to create program")
  end

  flags = bytestring("-I ./")

  # build program
  err = cl.api.clBuildProgram(prg_id, 0, C_NULL, flags, C_NULL, C_NULL)
  if err != cl.CL_SUCCESS
      println(err)
      error("Failed to build program")
  end

  return cl.Program(prg_id)
end

function test()
  #ranTest = cl.Kernel(prg, "ranTest")
  h_rand = zeros(Float32, nparts*(DIMS))
  println(h_rand)
  d_rand = cl.Buffer(Float32, ctx, :copy, hostbuf=h_rand)
  cl.call(queue, ranTest, (25,), nothing, int32(100), d_rand)
  h_rand = cl.read(queue, d_rand)
  println(h_rand)

end

end
