# SOURCE:
# https://jump.dev/JuMP.jl/stable/tutorials/Mixed-integer%20linear%20programs/facility_location/

## ACTIVATE PROJECT ENVIRONMENT
using DrWatson
@quickactivate "JuMP Tutorial" # <- project name

## IMPORT LIBRARIES
using JuMP, GLPK, DataFrames, Distributions, LinearAlgebra
include(srcdir("plot_facilities.jl"))

## DEFINE PARAMETERS
num_customers = 12 #number of customers
num_facilities = 20 #number of facilities

# Customers
customers = DataFrame(
    id = 1:num_customers,
    x = rand(num_customers),
    y = rand(num_customers),
    demand = rand(Normal(10,2), num_customers)
)

# Facilities
facilities = DataFrame(
    id = 1:num_facilities,
    x = rand(num_facilities),
    y = rand(num_facilities),
    capacity = rand(10:15, num_facilities),
    fixed_cost = rand(num_facilities)
)

# Distance
dist = Dict()
for facility in eachrow(facilities)
    for customer in eachrow(customers)
        Δx = facility.x - customer.x #delta x coordinate
        Δy = facility.y - customer.y #delta y coordinate
        δ = √(Δx^2 + Δy^2) #euclidian distance
        dist[facility.id, customer.id] = δ #store in dictionary
    end
end

# Create dictionaries for other parameters
demand = Dict(customers.id .=> customers.demand)
fixed_costs = Dict(facilities.id .=> facilities.fixed_cost)
capacities = Dict(facilities.id .=> facilities.capacity)

## SHOW TOPOLOGY
topology = show_network(customers, facilities; plot_filename = "facility_example_topology")

## DEFINE MODEL
CFL = Model(GLPK.Optimizer)
# Variables
@variable(CFL, y[f = facilities.id], Bin) #binary indicating facility c is built
@variable(CFL, 0 ≤ x[f = facilities.id, c = customers.id] ≤ demand[c]) #indicating amount of material shipped on the link joining customer f with facility c
# Constraints
@constraint(
    CFL, 
    customer_service[c = customers.id], 
    sum(x[:, c]) ≤ demand[c]
)
@constraint(
    CFL, 
    capacity[f = facilities.id], 
    sum(x[f,c] for c in customers.id) ≤ capacities[f] * y[f]
)
# Objective
@objective(
    CFL, 
    Min, 
    sum(fixed_costs[f] * y[f] for f = facilities.id) 
    +
    sum(dist[f,c] * x[f,c] for f in facilities.id, c = customers.id)
    +
    sum(demand[c] - sum(x[:, c]) for c in customers.id)
)
optimize!(CFL)
println("Optimal value: ", objective_value(CFL))

## PLOT RESULTS
optimal_network = show_network(customers, facilities, CFL; plot_filename = "facility_example_solution")