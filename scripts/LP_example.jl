# SOURCE:
# https://jump.dev/JuMP.jl/stable/tutorials/Getting%20started/getting_started_with_JuMP/

## ACTIVATE PROJECT ENVIRONMENT
using DrWatson
@quickactivate "JuMP Tutorial" # <- project name

## IMPORT LIBRARIES
using JuMP
using GLPK

## CREATE MODEL
model = Model(GLPK.Optimizer)

## ADD VARIABLES
@variable(model, x ≥ 0)
@variable(model, 0 ≤ y ≤ 3)

## ADD CONSTRAINTS
@constraint(model, c1, 6x + 8y ≥ 100)
@constraint(model, c2, 7x + 12y ≥ 120)

## ADD OBJECTIVE FUNCTION
@objective(model, Min, 12x + 20y)

## SHOW MODEL
print(model)

## OPTMIZE MODEL
optimize!(model)
@show termination_status(model)
@show primal_status(model)
@show dual_status(model)
@show objective_value(model)
@show value(x)
@show value(y)
@show shadow_price(c1)
@show shadow_price(c2)