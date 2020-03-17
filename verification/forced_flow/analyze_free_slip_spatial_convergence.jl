using PyPlot, Glob

include("ForcedFlow/ForcedFlow.jl")

free_slip_simulation_files = glob("data/forced_free_slip*CFL1e-03.jld2")

errors = ForcedFlow.compute_errors(ForcedFlow.FreeSlip.u, 
                                   free_slip_simulation_files...)

sizes = ForcedFlow.extract_sizes(free_slip_simulation_files...)

Nx = map(sz -> sz[1], sizes)
L₁ = map(err -> err.L₁, errors)
L∞ = map(err -> err.L∞, errors)

fig, ax = subplots()

loglog(Nx, L₁, linestyle="None", marker="o", label="error, \$L_1\$-norm")
loglog(Nx, L∞, linestyle="None", marker="^", label="error, \$L_\\infty\$-norm")

loglog(Nx, 200 * Nx.^(-2), "k--", linewidth=1, alpha=0.6, label="\$ 200 N_x^{-2} \$")
loglog(Nx, 5 * Nx.^(-1),   "k-", linewidth=1, alpha=0.6, label="\$ 5 N_x^{-1} \$")

xlabel(L"N_x")
ylabel("Norms of the absolute error, \$ | u_{\\mathrm{sim}} - u_{\\mathrm{exact}} | \$")
title("Convergence for forced free slip")

legend()
