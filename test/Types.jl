constants = BCIM.PhysicalConst(0.001,
                          0.3,
                          0.01,
                          298.0,
                          1.38e-16,
                          [100.0, 100.0],
                          [1.5e4, 1.5e3],
                          [1.5e4, 0.0],
                          0.1,
                          1.3e-4,
                          1000.0,
                          40000.0)

@assert constants.contact == 0.1

dimensionlessConstants = BCIM.DimensionlessConst(constants)
@assert dimensionlessConstants.boltz == constants.boltz
@assert dimensionlessConstants.dia != constants.dia
@assert dimensionlessConstants.dt != constants.dt
