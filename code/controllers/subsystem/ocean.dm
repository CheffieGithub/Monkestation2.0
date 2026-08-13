/// Manages handling of ocean turfs fluid spred
SUBSYSTEM_DEF(ocean)
	name = "Ocean Processing"
	flags = SS_KEEP_TIMING
	init_order = INIT_ORDER_OCEAN
	priority = FIRE_PRIORITY_OCEAN
	flags = SS_BACKGROUND | SS_HIBERNATE
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME

	var/list/current_run = list()

	/// Static reagents for expose/flooding
	var/list/ocean_reagents = list(/datum/reagent/water = 10)

	/// Unfiltered list of all ocean turfs
	var/list/ocean_turfs = list()
	/// All ocean turfs with real atmos adjacency
	var/list/active_ocean_turfs = list()

	/// A list of overlays generated for each plane offset
	var/list/ocean_overlays = list()

/datum/controller/subsystem/ocean/PreInit()
	. = ..()
	hibernate_checks = list(
		NAMEOF(src, active_ocean_turfs),
	)

/datum/controller/subsystem/ocean/Initialize()
	setup_ocean_overlays()

	RegisterSignal(SSmapping, COMSIG_PLANE_OFFSET_INCREASE, PROC_REF(setup_ocean_overlays))

	return SS_INIT_SUCCESS

/datum/controller/subsystem/ocean/proc/setup_ocean_overlays()
	SIGNAL_HANDLER

	var/datum/reagents/fake_reagents = new
	fake_reagents.add_reagent_list(ocean_reagents)

	for(var/offset in 0 to SSmapping.max_plane_offset)
		if(offset in ocean_overlays)
			continue
		var/mutable_appearance/ocean_appearance = mutable_appearance('icons/obj/effects/liquid.dmi', "ocean")
		ocean_appearance.color = mix_color_from_reagents(fake_reagents)
		ocean_appearance.alpha = 80
		SET_PLANE_W_SCALAR(ocean_appearance, AREA_PLANE, offset)
		ocean_overlays += ocean_appearance

/datum/controller/subsystem/ocean/stat_entry(msg)
	msg = "T:[length(ocean_turfs)]|A:[length(active_ocean_turfs)]"
	return ..()

/datum/controller/subsystem/ocean/fire(resumed)
	if(!resumed)
		src.current_run = active_ocean_turfs.Copy()

	//cache for sanic speed (lists are references anyways)
	var/list/current_run = src.current_run

	while(length(current_run))
		var/turf/open/ocean_turf = current_run[length(current_run)]
		current_run.len--

		flood_adjacent(ocean_turf)

		if(MC_TICK_CHECK)
			return

/datum/controller/subsystem/ocean/proc/flood_adjacent(turf/open/ocean)
	// This shouldn't happen often
	if(!length(ocean.atmos_adjacent_turfs))
		return

	for(var/turf/flooding as anything in ocean.atmos_adjacent_turfs)
		if(ocean_turfs[flooding] || !flooding.init_air)
			continue
		flooding.add_liquid_list(ocean_reagents, FALSE, T20C)

/datum/controller/subsystem/ocean/proc/add_turf(turf/open/new_turf)
	if(!istype(new_turf))
		return

	if(ocean_turfs[new_turf])
		CRASH("[new_turf] turf added to ocean processing multiple times!")

	ocean_turfs[new_turf] = TRUE

	new_turf.add_overlay(ocean_overlays[GET_TURF_PLANE_OFFSET(new_turf) + 1])

	// COMSIG_TURF_CALCULATED_ADJACENT_ATMOS is sent even if our turf doesn't process atmos
	RegisterSignal(new_turf, COMSIG_TURF_CALCULATED_ADJACENT_ATMOS, PROC_REF(consider_processing))
	RegisterSignal(new_turf, COMSIG_TURF_CHANGE, PROC_REF(post_change_turf))
	consider_processing(new_turf)

/datum/controller/subsystem/ocean/proc/consider_processing(turf/open/processing)
	SIGNAL_HANDLER

	// This may end up expensive so hopefully it doesn't happen that much
	for(var/turf/open as anything in processing.get_atmos_adjacent_turfs())
		if(open.z < processing.z) // Water can't pass down
			continue
		if(open.turf_flags & NO_FLUID_GROUPS)
			continue
		active_ocean_turfs |= processing
		return

	active_ocean_turfs -= processing

// Because turf refs stay, we need to remove them when we change
/datum/controller/subsystem/ocean/proc/post_change_turf(turf/source, turf/new_path, new_base_turfs, flags, post_change_callbacks)
	SIGNAL_HANDLER

	remove_turf(source)

/datum/controller/subsystem/ocean/proc/remove_turf(turf/open/old_turf)
	if(!old_turf)
		return

	ocean_turfs -= old_turf
	active_ocean_turfs -= old_turf
	old_turf.cut_overlay(ocean_overlays[GET_TURF_PLANE_OFFSET(old_turf) + 1])
	old_turf.light_color = old_turf::light_color

	UnregisterSignal(old_turf, list(COMSIG_TURF_CALCULATED_ADJACENT_ATMOS, COMSIG_TURF_CHANGE))
