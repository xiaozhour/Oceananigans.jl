using Oceananigans.Architectures
using Oceananigans.Architectures: device_event
using Oceananigans.BoundaryConditions
using Oceananigans.TurbulenceClosures: calculate_diffusivities!
using Oceananigans.ImmersedBoundaries: mask_immersed_field!
using Oceananigans.Models.NonhydrostaticModels: update_hydrostatic_pressure!

import Oceananigans.TimeSteppers: update_state!

compute_auxiliary_fields!(auxiliary_fields) = Tuple(compute!(a) for a in auxiliary_fields)

"""
    update_state!(model::HydrostaticFreeSurfaceModel)

Update peripheral aspects of the model (auxiliary fields, halo regions, diffusivities,
hydrostatic pressure) to the current model state.
"""
update_state!(model::HydrostaticFreeSurfaceModel) = update_state!(model, model.grid)

function update_state!(model::HydrostaticFreeSurfaceModel, grid)

    # Mask immersed fields
    masking_events = Tuple(mask_immersed_field!(field) for field in merge(model.auxiliary_fields, prognostic_fields(model)))

    wait(device(model.architecture), MultiEvent(masking_events))

    # Fill halos for velocities and tracers. On the CubedSphere, the halo filling for velocity fields is wrong.
    fill_halo_regions!(prognostic_fields(model), model.architecture, model.clock, fields(model))

    # This _refills_ the halos for horizontal velocity fields when grid::ConformalCubedSphereGrid
    # For every other type of grid, fill_horizontal_velocity_halos! does nothing.
    fill_horizontal_velocity_halos!(model.velocities.u, model.velocities.v, model.architecture)

    compute_w_from_continuity!(model)

    fill_halo_regions!(model.velocities.w, model.architecture, model.clock, fields(model))

    compute_auxiliary_fields!(model.auxiliary_fields)

    # Calculate diffusivities
    calculate_diffusivities!(model.diffusivity_fields, model.architecture, model.grid, model.closure,
                             model.buoyancy, model.velocities, model.tracers)

    fill_halo_regions!(model.diffusivity_fields, model.architecture, model.clock, fields(model))

    # Calculate hydrostatic pressure
    pressure_calculation = launch!(model.architecture, model.grid, :xy, update_hydrostatic_pressure!,
                                   model.pressure.pHY′, model.grid, model.buoyancy, model.tracers,
                                   dependencies=device_event(model.architecture))

    # Fill halo regions for pressure
    wait(device(model.architecture), pressure_calculation)

    fill_halo_regions!(model.pressure.pHY′, model.architecture)

    return nothing
end
