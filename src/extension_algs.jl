# This file only include the algorithm struct to be exported by LinearSolve.jl. The main
# functionality is implemented as package extensions
"""
    LeastSquaresOptimJL(alg = :lm; linsolve = nothing, autodiff::Symbol = :central)

Wrapper over [LeastSquaresOptim.jl](https://github.com/matthieugomez/LeastSquaresOptim.jl)
for solving `NonlinearLeastSquaresProblem`.

## Arguments:

- `alg`: Algorithm to use. Can be `:lm` or `:dogleg`.
- `linsolve`: Linear solver to use. Can be `:qr`, `:cholesky` or `:lsmr`. If
  `nothing`, then `LeastSquaresOptim.jl` will choose the best linear solver based
  on the Jacobian structure.
- `autodiff`: Automatic differentiation / Finite Differences. Can be `:central` or `:forward`.

!!! note
    This algorithm is only available if `LeastSquaresOptim.jl` is installed.
"""
struct LeastSquaresOptimJL{alg, linsolve} <: AbstractNonlinearSolveAlgorithm
    autodiff::Symbol
end

function LeastSquaresOptimJL(alg = :lm; linsolve = nothing, autodiff::Symbol = :central)
    @assert alg in (:lm, :dogleg)
    @assert linsolve === nothing || linsolve in (:qr, :cholesky, :lsmr)
    @assert autodiff in (:central, :forward)

    if Base.get_extension(@__MODULE__, :NonlinearSolveLeastSquaresOptimExt) === nothing
        error("LeastSquaresOptimJL requires LeastSquaresOptim.jl to be loaded")
    end

    return LeastSquaresOptimJL{alg, linsolve}(autodiff)
end

"""
    FastLevenbergMarquardtJL(linsolve = :cholesky)

Wrapper over [FastLevenbergMarquardt.jl](https://github.com/kamesy/FastLevenbergMarquardt.jl) for solving
`NonlinearLeastSquaresProblem`.

!!! warning
    This is not really the fastest solver. It is called that since the original package
    is called "Fast". `LevenbergMarquardt()` is almost always a better choice.

!!! warning
    This algorithm requires the jacobian function to be provided!

## Arguments:

- `linsolve`: Linear solver to use. Can be `:qr` or `:cholesky`.

!!! note
    This algorithm is only available if `FastLevenbergMarquardt.jl` is installed.
"""
@concrete struct FastLevenbergMarquardtJL{linsolve} <: AbstractNonlinearSolveAlgorithm
    factor
    factoraccept
    factorreject
    factorupdate::Symbol
    minscale
    maxscale
    minfactor
    maxfactor
end

function FastLevenbergMarquardtJL(linsolve::Symbol = :cholesky; factor = 1e-6,
    factoraccept = 13.0, factorreject = 3.0, factorupdate = :marquardt,
    minscale = 1e-12, maxscale = 1e16, minfactor = 1e-28, maxfactor = 1e32)
    @assert linsolve in (:qr, :cholesky)
    @assert factorupdate in (:marquardt, :nielson)

    if Base.get_extension(@__MODULE__, :NonlinearSolveFastLevenbergMarquardtExt) === nothing
        error("LeastSquaresOptimJL requires FastLevenbergMarquardt.jl to be loaded")
    end

    return FastLevenbergMarquardtJL{linsolve}(factor, factoraccept, factorreject,
        factorupdate, minscale, maxscale, minfactor, maxfactor)
end
