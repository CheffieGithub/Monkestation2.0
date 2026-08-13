/turf/open/ocean
	name = "ocean sand"
	icon = 'icons/turf/seafloor.dmi'
	icon_state = "seafloor"
	base_icon_state = "seafloor"
	gender = PLURAL

	rust_resistance = RUST_RESISTANCE_ABSOLUTE
	turf_flags =  NO_RUST | NO_FLUID_GROUPS

	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

	astar_weight = 50

	///are we captured, this is easier than having to run checks on turfs for vents
	var/captured = FALSE

	/// Itemstack to drop when dug by a shovel
	var/obj/item/stack/dig_result = /obj/item/stack/ore/glass

/turf/open/ocean/Initialize(mapload)
	. = ..()
	SSocean.add_turf(src)

/turf/open/ocean/red
	icon = 'icons/turf/floors.dmi'
	icon_state = "ironsand1"
	base_icon_state = "ironsand"

/turf/open/ocean/red/Initialize(mapload)
	. = ..()
	icon_state = "[base_icon_state][rand(1, 15)]"

/turf/open/ocean/cracked
	icon = 'icons/turf/seafloor.dmi'
	icon_state = "seafloor"

/turf/open/ocean/cracked/medium
	icon_state = "seafloor_med"

/turf/open/ocean/cracked/heavy
	icon_state = "seafloor_heavy"

/turf/open/openspace/ocean
	name = "ocean"

	baseturfs = /turf/open/openspace/ocean

/turf/open/openspace/ocean/Initialize(mapload)
	. = ..()
	SSocean.add_turf(src)

// Not an "ocean" turf but it needs to be this way
/turf/open/lava/ocean
	name = "fissure"
	icon = 'icons/turf/fissure.dmi'
	icon_state = "fissure-0"
	base_icon_state = "fissure"

	rust_resistance = /turf/open/ocean::rust_resistance
	turf_flags = /turf/open/ocean::turf_flags

	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_FISSURE
	canSmoothWith = SMOOTH_GROUP_FISSURE
