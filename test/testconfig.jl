conf = Dict{String, Any}()
# Program params
#conf["path"] = "../data/"
conf["autodir"] = 1
conf["verbose"] = 1
conf["ocl"] = 1
conf["dim"] = 2
conf["ntrials"] = 1
conf["nequil"] = 100000
conf["nsteps"] = 100000
conf["freq"] = 1000
conf["expName"] = ""

# Plotting
conf["serverMode"] = 0
conf["postSimPy"] = ""
conf["postExpPy"] = ""
conf["postPy"] = ""
conf["editor"] = "vim"
conf["ignorenotebook"] = 0
conf["notebook"] = "../notebook/generator.py"
conf["pelican"] = "../site/"

conf["numbins"] = 200

# Simulation params
conf["npart"] = {512,512}
conf["phi"] = 0.40      # Packing frac
conf["eta"] = 1.0e-2    # g / (cm s)
conf["dt"] = 1.0e-4     # s
conf["temp"] = 298.0    # K
conf["boltz"] = 1.38e-16 # erg / K

# Diameter of particles
conf["dia"] = 15.0e-4   # g / (cm s)

conf["diffus"] = conf["boltz"]*conf["temp"]/(3*pi*conf["eta"]*conf["dia"])
conf["rotdiffus"] = 500*conf["boltz"]*conf["temp"]/(
  pi*conf["eta"]*conf["dia"]^3)

# Coefficients
conf["prop"] = [ 1.0e3, 1.0e3 ]   # length / difftime
conf["rep"] = [ 1.5e4, 0.5e4 ] # energy / length
conf["adh"] = [ 0.01, 0.01 ]   # energy / length
conf["contact"] = 0.1 # length


conf["contact"] = conf["dia"]*conf["contact"]
push!(conf["rep"], 2*conf["rep"][1]*conf["rep"][2]/sum(conf["rep"]))
# Dimensionless units
conf["utime"] = (conf["dia"])^2/conf["diffus"]
conf["ulength"] = conf["dia"]
conf["uenergy"] = conf["boltz"]*conf["temp"]
conf["rotdiffus"] = conf["rotdiffus"]*conf["utime"]
conf["diffus"] = conf["diffus"]*conf["utime"]/(conf["ulength"]^2)
conf["dia"] = conf["dia"]./conf["ulength"]
conf["dt"] = conf["dt"]/conf["utime"]
conf["rep"] = conf["rep"]./conf["ulength"]
conf["contact"] = conf["contact"]./conf["ulength"]
conf["adh"] = conf["adh"]./conf["contact"]
conf["pretrad"] = sqrt(2.0/conf["dt"])
conf["prerotd"] = sqrt(2.0*conf["rotdiffus"]*conf["dt"])

conf["tpart"] = sum(conf["npart"])

conf["size"] = sqrt((conf["dia"]/2)^2*conf["tpart"] / conf["phi"])
