using Base.Test
include("../src/julia/BCIM.jl")

my_tests = ["myTest.jl"]

println("Running tests:")

for test in my_tests
  println(" * $(test)")
  include(test)
end
