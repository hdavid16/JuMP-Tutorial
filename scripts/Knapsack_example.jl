# SOURCE:
# https://jump.dev/JuMP.jl/stable/tutorials/Mixed-integer%20linear%20programs/knapsack/

## ACTIVATE PROJECT ENVIRONMENT
using DrWatson
@quickactivate "JuMP Tutorial" # <- project name

## IMPORT LIBRARIES
using JuMP, GLPK

## DEFINE PARAMETERS
profit = [5, 3, 2, 7, 4]
weight = [2, 8, 4, 2, 5]
capacity = 10

## CREATE AND BUILD MODEL
model = Model(GLPK.Optimizer)
@variable(model, x[1:5], Bin)
# Objective: maximize profit
@objective(model, Max, profit' * x)
# Constraint: can carry all
@constraint(model, weight' * x ≤ capacity)

## OPTIMIZE MODEL
# Solve problem using MIP solver
optimize!(model)

## SHOW RESULTS
println("Termination Status: ", termination_status(model))
println("Primal Status: ", primal_status(model))
println("Objective is: ", objective_value(model))
println("Solution is:")
for i in 1:5
    print("x[$i] = ", value(x[i]))
    println(", p[$i]/w[$i] = ", profit[i] / weight[i])
end
