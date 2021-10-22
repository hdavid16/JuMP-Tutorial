using Plots

function show_network(
    customers,
    facilities,
    model = missing;
    plot_filename = missing
)

    # Plot customers with markersize proportional to demand
    fig = scatter(
        customers.x,
        customers.y,
        label = "customers",
        markershape = :circle,
        markercolor = :blue,
        markersize = 4 .* customers.demand ./ minimum(customers.demand),
        legend = :outertopright
    )

    # Plot facilities
    scatter!(
        facilities.x,
        facilities.y,
        label = "candidate facilities",
        markershape = :rect,
        markercolor = :white,
        markersize = 4 .* facilities.capacity ./ minimum(facilities.capacity),
        markerstrokecolor = :red,
        markerstrokewidth = 2,
    )

    # Plot arcs
    if !ismissing(model) && primal_status(model) == MOI.FEASIBLE_POINT
        # fill in facilities that were actually installed
        installed = [key.I[1] for key in keys(model[:y]) if value(model[:y][key]) > 0.9]
        facilities_installed = filter(i -> i.id in installed, facilities)
        scatter!(
            facilities_installed.x,
            facilities_installed.y,
            label = "installed facilities",
            markershape = :rect,
            markercolor = :red,
            markersize = 4 .* facilities_installed.capacity ./ minimum(facilities_installed.capacity),
            markerstrokecolor = :red,
            markerstrokewidth = 2,
        )
        # connect facilities to customers
        for f in facilities.id, c in customers.id
            flow = value.(model[:x][f, c])
            if flow > 0
                #get facility coordinates (source)
                facility = filter(
                    i -> i.id == f, facilities
                )
                #get customer coordinates (destination)
                customer = filter(
                    i -> i.id == c, customers
                )
                #plot arc
                plot!(
                    [facility.x[1], customer.x[1]],
                    [facility.y[1], customer.y[1]],
                    color = :black,
                    label = nothing
                )
            end
        end
    end

    # Save figure
    if !ismissing(plot_filename)
        savefig(fig, plotsdir("$plot_filename.svg"))
    end

    return fig
end