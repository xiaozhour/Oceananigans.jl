# # ConvergenceTests
#
# This module implements a few simple convergence tests for verifying
# the expected numerical behavior of the spatial discretization 
# and time-stepping.

module ConvergenceTests

using JLD2, Statistics

using Oceananigans, Oceananigans.Fields

import Oceananigans: RegularCartesianGrid

include("file_wrangling.jl")
include("analysis.jl")

# Exponential decay at a point:
#
# c = exp(-t) | ∂c/∂t = - c
#
# Tests time-stepper convergence.
#
include("PointExponentialDecay.jl")

# Advection and diffusion of a 1D Gaussian:
#
# c = 1/√(4πκt) * exp( -(x - Ut)^2 / 4κt )
#
# Tests x-advection and y-advection.
#
include("GaussianAdvectionDiffusion.jl")

# Advection and diffusion of a 1D cosine:
#
# c = exp(-κt) * cos(x - Ut)
#
# Tests x-advection and y-advection.
#
include("CosineAdvectionDiffusion.jl")

# Free decay of a horizontally-advected Taylor-Green vortex:
#
# u(x, y, t) = U + cos(x - Ut) sin(y)
# v(x, y, t) =   - sin(x - Ut) cos(y)
#
include("DoublyPeriodicTaylorGreen.jl")

include("ForcedFlowFreeSlip.jl")

end
