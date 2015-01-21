## Test the System type
# Contstruct from a configuration dict
syst = BCIM.System(conf)
@test size(syst.parts) == (1024,)
@test syst.partCnts == {512, 512}
@test size(syst.cells) == (42, 42, 42)
@test syst.size > 25

# Contstruct
mySys = BCIM.System([256, 256], 20.0, 1.0+0.2)

@test size(mySys.parts) == (512,)
@test mySys.partCnts == [256, 256]
