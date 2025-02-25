# Getting Started with Nonlinear Rootfinding in Julia

NonlinearSolve.jl is a system for solving rootfinding problems, i.e. finding
the value $$u$$ such that $$f(u) = 0$$. In this tutorial we will go through
the basics of NonlinearSolve.jl, demonstrating the core ideas and leading you
to understanding the deeper parts of the documentation.

## The Three Types of Nonlinear Systems

There are three types of nonlinear systems:

 1. The "standard nonlinear system", i.e. the `NonlinearProblem`. This is a
    system of equations with an initial condition where you want to satisfy
    all equations simultaniously.
 2. The "interval rootfinding problem", i.e. the `IntervalNonlinearProblem`.
    This is the case where you're given an interval `[a,b]` and need to find
    where `f(u) = 0` for `u` inside the bounds.
 3. The "steady state problem", i.e. find the `u` such that `u' = f(u) = 0`.
    While related to (1), it's not entirely the same because there's a uniquely
    defined privledged root.
 4. The nonlinear least squares problem, which is an overconstrained nonlinear
    system (i.e. more equations than states) which might not be satisfiable, i.e.
    there may be no `u` such that `f(u) = 0`, and thus we find the `u` which
    minimizes `||f(u)||` in the least squares sense.

For now let's focus on the first two. The other two are covered in later tutorials,
but from the first two we can show the general flow of the NonlinearSolve.jl package.

## Problem Type 1: Solving Nonlinear Systems of Equations

A nonlinear system $$f(u) = 0$$ is specified by defining a function `f(u,p)`,
where `p` are the parameters of the system. For example, the following solves
the vector equation $$f(u) = u^2 - p$$ for a vector of equations:

```@example 1
using NonlinearSolve

f(u, p) = u .* u .- p
u0 = [1.0, 1.0]
p = 2.0
prob = NonlinearProblem(f, u0, p)
sol = solve(prob)
```

where `u0` is the initial condition for the rootfinder. Native NonlinearSolve.jl
solvers use the given type of `u0` to determine the type used within the solver
and the return. Note that the parameters `p` can be any type, but most are an
AbstractArray for automatic differentiation.

### Investigating the Solution

To investigate the solution, one can look at the elements of the `NonlinearSolution`.
The most important value is `sol.u`: this is the `u` that satisfies `f(u) = 0`. For example:

```@example 1
u = sol.u
```

```@example 1
f(u, p)
```

This final value, the difference of the solution against zero, can also be found with `sol.resid`:

```@example 1
sol.resid
```

To know if the solution converged, or why the solution had not converged we can check the return
code (`retcode`):

```@example 1
sol.retcode
```

There are multiple return codes which can mean the solve was successful, and thus we can use the
general command `SciMLBase.successful_retcode` to check whether the solution process exited as
intended:

```@exmaple
SciMLBase.successful_retcode(sol)
```

If we're curious about what it took to solve this equation, then you're in luck because all of the
details can be found in `sol.stats`:

```@example 1
sol.stats
```

For more information on `NonlinearSolution`s, see the [`NonlinearSolution` manual page](@ref solution).

### Interacting with the Solver Options

While `sol = solve(prob)` worked for our case here, in many situations you may need to interact more
deeply with how the solving process is done. First things first, you can specify the solver using the
positional arguments. For example, let's set the solver to `TrustRegion()`:

```@example 1
solve(prob, TrustRegion())
```

For a complete list of solver choices, see [the nonlinear system solvers page](@ref nonlinearsystemsolvers).

Next we can modify the tolerances. Here let's set some really low tolerances to force a tight solution:

```@example 1
solve(prob, TrustRegion(), reltol = 1e-12, abstol = 1e-12)
```

There are many more options for doing this configuring. Specifically for handling termination conditions,
see the [Termination Conditions](@ref termination_condition) page for more details. And for more details on
all of the available keyword arguments, see the [solver options](@ref solver_options) page.

## Problem Type 2: Solving Interval Rootfinding Problems with Bracketing Methods

For scalar rootfinding problems, bracketing methods exist in NonlinearSolve. The difference with bracketing
methods is that with bracketing methods, instead of giving a `u0` initial condition, you pass a `uspan (a,b)`
bracket in which the zero is expected to live. For example:

```@example 1
using NonlinearSolve
f(u, p) = u * u - 2.0
uspan = (1.0, 2.0) # brackets
prob_int = IntervalNonlinearProblem(f, uspan)
sol = solve(prob_int)
```

All of the same option handling from before works just as before, now just with different solver choices
(see the [bracketing solvers](@ref bracketing) page for more details). For example, let's set the solver
to `ITP()` and set a high absolute tolerance:

```@example 1
sol = solve(prob_int, ITP(), abstol = 0.01)
```

## Going Beyond the Basics: How to use the Documentation

Congrats, you now know how to use the basics of NonlinearSolve.jl! However, there is so much more to
see. Next check out:

  - [Some code optimization tricks to know about with NonlinearSolve.jl](@ref code_optimization)
  - [An iterator interface which lets you step through the solving process step by step](@ref iterator)
  - [How to handle large systems of equations efficiently](@ref large_systems)
  - [Ways to use NonlinearSolve.jl that is faster to startup and can statically compile](@ref fast_startup)
  - [More detailed termination conditions](@ref termination_conditions_tutorial)

And also check out the rest of the manual.
