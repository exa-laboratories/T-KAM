using Test, Random, LinearAlgebra, Lux

ENV["GPU"] = true
ENV["FULL_QUANT"] = "FP32"
ENV["HALF_QUANT"] = "FP32"

include("../src/T-KAM/univariate_functions.jl")
include("../src/utils.jl")
using .univariate_functions
using .Utils

function test_fwd()
    Random.seed!(42)
    x = rand(half_quant, 5, 3) |> device
    f = init_function(5, 2)

    Random.seed!(42)
    ps, st = Lux.setup(Random.GLOBAL_RNG, f)
    ps, st = ps |> device, st |> device

    y = fwd(f, ps, st, x)
    @test size(y) == (5, 2, 3)
end

function test_grid_update()
    Random.seed!(42)
    x = rand(half_quant, 5, 3) |> device
    f = init_function(5, 2)
    ps, st = Lux.setup(Random.GLOBAL_RNG, f)
    ps, st = ps |> device, st |> device

    y = fwd(f, ps, st, x)
    grid, coef = update_fcn_grid(f, ps, st, x)
    @test size(grid) == (5, 12)
end

@testset "Univariate Funtion Tests" begin
    test_fwd()
    test_grid_update()
end