GLOBAL_LIST_EMPTY(initalized_ocean_areas)
/area/ocean
	name = "Ocean"

	icon = 'icons/obj/effects/liquid.dmi'
	base_icon_state = "ocean"
	icon_state = "ocean_area"
	alpha = 120

	requires_power = TRUE
	always_unpowered = TRUE

	power_light = FALSE
	power_equip = FALSE
	power_environ = FALSE

	outdoors = TRUE
	ambience_index = AMBIENCE_SPACE

	flags_1 = CAN_BE_DIRTY_1
	sound_environment = SOUND_AREA_SPACE

/area/ocean/Initialize(mapload)
	. = ..()
	GLOB.initalized_ocean_areas += src

/area/ocean/dark
	icon_state = "ocean_dark"
	base_lighting_alpha = 0

/area/ruin/ocean
	has_gravity = TRUE

/area/ruin/ocean/listening_outpost
	area_flags = UNIQUE_AREA

/area/ruin/ocean/bunker
	area_flags = UNIQUE_AREA

/area/ruin/ocean/bioweapon_research
	area_flags = UNIQUE_AREA

/area/ruin/ocean/mining_site
	area_flags = UNIQUE_AREA

/area/ocean/near_station_powered
	requires_power = FALSE


/turf/open/floor/plating
	///do we still call parent but dont want other stuff?
	var/overwrites_attack_by = FALSE

/turf/open/floor/plating/ocean
	plane = FLOOR_PLANE
	layer = TURF_LAYER
	force_no_gravity = FALSE
	gender = PLURAL
	name = "ocean sand"
	baseturfs = /turf/open/floor/plating/ocean
	icon = 'icons/turf/seafloor.dmi'
	icon_state = "seafloor"
	base_icon_state = "seafloor"
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	planetary_atmos = TRUE
	initial_gas_mix = OSHAN_DEFAULT_ATMOS

	upgradable = FALSE
	attachment_holes = FALSE
	can_slice_apart = FALSE

	resistance_flags = INDESTRUCTIBLE

	overwrites_attack_by = TRUE

	astar_weight = 50

	var/static/obj/effect/abstract/ocean_overlay/static_overlay
	var/static/list/ocean_reagents = list(/datum/reagent/water = 10)
	var/ocean_temp = T20C
	var/list/ocean_turfs = list()
	var/list/open_turfs = list()

	///are we captured, this is easier than having to run checks on turfs for vents
	var/captured = FALSE

	var/rand_variants = 0
	var/rand_chance = 30

	/// Itemstack to drop when dug by a shovel
	var/obj/item/stack/dig_result = /obj/item/stack/ore/glass
	/// Whether the turf has been dug or not
	var/dug = FALSE

	/// do we build a catwalk or plating with rods
	var/catwalk = FALSE

/turf/open/floor/plating/ocean/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_ATOM_ENTERED, PROC_REF(movable_entered))
	RegisterSignal(src, COMSIG_TURF_MOB_FALL, PROC_REF(mob_fall))
	if(!static_overlay)
		static_overlay = new(null, ocean_reagents)

	vis_contents += static_overlay
	light_color = static_overlay.color

	if(rand_variants && prob(rand_chance))
		var/random = rand(1,rand_variants)
		icon_state = "[base_icon_state][random]"
		base_icon_state = "[base_icon_state][random]"

/turf/open/floor/plating/ocean/Destroy()
	UnregisterSignal(src, list(COMSIG_ATOM_ENTERED, COMSIG_TURF_MOB_FALL, COMSIG_TURF_CALCULATED_ADJACENT_ATMOS))
	return ..()

/turf/open/floor/plating/ocean/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	switch(the_rcd.mode)
		if(RCD_FLOORWALL)
			var/obj/structure/lattice/lattice = locate(/obj/structure/lattice, src)
			if(lattice)
				return list("mode" = RCD_FLOORWALL, "delay" = 0, "cost" = 1)
			else
				return list("mode" = RCD_FLOORWALL, "delay" = 0, "cost" = 3)
		if(RCD_CATWALK)
			var/obj/structure/lattice/lattice = locate(/obj/structure/lattice, src)
			if(lattice)
				return list("mode" = RCD_CATWALK, "delay" = 0, "cost" = 2)
			else
				return list("mode" = RCD_CATWALK, "delay" = 0, "cost" = 4)
	return FALSE

/turf/open/floor/plating/ocean/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, passed_mode)
	switch(passed_mode)
		if(RCD_FLOORWALL)
			to_chat(user, span_notice("You build a floor."))
			PlaceOnTop(/turf/open/floor/plating, flags = CHANGETURF_INHERIT_AIR)
			return TRUE
		if(RCD_CATWALK)
			to_chat(user, span_notice("You build a catwalk."))
			var/obj/structure/lattice/lattice = locate(/obj/structure/lattice, src)
			if(lattice)
				qdel(lattice)
			new /obj/structure/lattice/catwalk(src)
			return TRUE
	return FALSE

/turf/open/floor/plating/ocean/attackby(obj/item/C, mob/user, params)
	if(..())
		return
	if(istype(C, /obj/item/stack/rods))
		var/obj/item/stack/rods/rods = C
		if (rods.get_amount() < 2)
			to_chat(user, span_warning("You need two rods to make a [catwalk ? "catwalk" : "plating"]!"))
			return
		to_chat(user, span_notice("You begin constructing a [catwalk ? "catwalk" : "plating"]..."))
		if(!do_after(user, 3 SECONDS, target = src))
			return
		if(!rods.use(2))
			return
		if(catwalk)
			to_chat(user, span_notice("You build a catwalk over \the [src]."))
			playsound(src, 'sound/items/deconstruct.ogg', 80, TRUE)
			new /obj/structure/lattice/catwalk(src)
		else
			to_chat(user, span_notice("You reinforce \the [src]."))
			playsound(src, 'sound/items/deconstruct.ogg', 80, TRUE)
			PlaceOnTop(/turf/open/floor/plating, flags = CHANGETURF_INHERIT_AIR)

	else if(istype(C, /obj/item/trench_ladder_kit) && catwalk && is_safe())
		to_chat(user, span_notice("You begin constructing a ladder..."))
		if(do_after(user, 3 SECONDS, target = src))
			qdel(C)
			new /obj/structure/trench_ladder(src)

	else if(istype(C, /obj/item/mining_charge) && !catwalk)
		to_chat(user, span_notice("You begin laying down a breaching charge..."))
		if(do_after(user, 1.5 SECONDS, target = src))
			var/obj/item/mining_charge/boom = C
			user.dropItemToGround(boom)
			boom.Move(src)
			boom.set_explosion()
			to_chat(user, span_warning("You lay down a breaching charge, you better run."))


/// Drops itemstack when dug and changes icon
/turf/open/floor/plating/ocean/proc/getDug()
	dug = TRUE
	new dig_result(src, 5)

/// If the user can dig the turf
/turf/open/floor/plating/ocean/proc/can_dig(mob/user)
	if(!dug)
		return TRUE
	if(user)
		to_chat(user, span_warning("Looks like someone has dug here already!"))

/turf/open/attackby(obj/item/C, mob/user, params)
	. = ..()
	if(istype(C, /obj/item/dousing_rod))
		var/obj/item/dousing_rod/attacking_rod = C
		attacking_rod.deploy(src)

/turf/open/floor/plating/ocean/attackby(obj/item/C, mob/user, params)
	. = ..()

	if(C.tool_behaviour == TOOL_SHOVEL || C.tool_behaviour == TOOL_MINING)
		if(!can_dig(user))
			return TRUE

		if(!isturf(user.loc))
			return

		balloon_alert(user, "digging...")

		if(C.use_tool(src, user, 40, volume=50))
			if(!can_dig(user))
				return TRUE
			getDug()
			SSblackbox.record_feedback("tally", "pick_used_mining", 1, C.type)
			return TRUE

	if(istype(C, /obj/item/vent_package))
		if(captured)
			return
		if(!do_after(user, 2 SECONDS, src))
			return
		var/obj/item/vent_package/attacking = C
		attacking.deploy(src)

/obj/effect/abstract/ocean_overlay
	icon = 'icons/obj/effects/liquid.dmi'
	icon_state = "ocean"
	base_icon_state = "ocean"
	plane = AREA_PLANE //Same as weather, etc.
	layer = ABOVE_MOB_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	alpha = 80

/obj/effect/abstract/ocean_overlay/proc/mix_colors(list/ocean_contents)
	var/datum/reagents/fake_reagents = new
	fake_reagents.add_reagent_list(ocean_contents)
	color = mix_color_from_reagents(fake_reagents.reagent_list)
	qdel(fake_reagents)
	if(istype(loc, /area/ocean))
		var/area/area_loc = loc
		area_loc.base_lighting_color = color

/turf/open/floor/plating/ocean/proc/mob_fall(datum/source, mob/M)
	SIGNAL_HANDLER
	var/turf/T = source
	playsound(T, 'sound/effects/splash_loud.ogg', 50, 0)
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		to_chat(C, span_userdanger("You fall in the water!"))

/turf/open/floor/plating/ocean/proc/movable_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER

	var/turf/T = source
	if(isobserver(AM) || iseyemob(AM) || iseffect(AM))
		return //ghosts, camera eyes, etc. don't make water splashy splashy
	if(isliving(AM))
		var/mob/living/arrived = AM
		if(arrived.incorporeal_move)
			return

		if(!arrived.has_status_effect(/datum/status_effect/ocean_affected))
			arrived.apply_status_effect(/datum/status_effect/ocean_affected)
	if(prob(30))
		var/sound_to_play = pick(list(
			'sound/effects/water_wade1.ogg',
			'sound/effects/water_wade2.ogg',
			'sound/effects/water_wade3.ogg',
			'sound/effects/water_wade4.ogg'
			))
		playsound(T, sound_to_play, 50, 0)

	SEND_SIGNAL(AM, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_WASH)

/area/ocean/generated
	icon_state = "ocean_gen"
	base_lighting_alpha = 0
	//map_generator = /datum/map_generator/ocean_generator
	map_generator = /datum/map_generator/cave_generator/trench
	area_flags = UNIQUE_AREA | CAVES_ALLOWED | FLORA_ALLOWED | MOB_SPAWN_ALLOWED | MEGAFAUNA_SPAWN_ALLOWED

/area/ocean/generated_above
	icon_state = "ocean_gen_above"
	map_generator = /datum/map_generator/ocean_generator
	area_flags = UNIQUE_AREA | CAVES_ALLOWED | FLORA_ALLOWED | MOB_SPAWN_ALLOWED

/turf/open/floor/plating/ocean/proc/is_safe()
	//if anything matching this typecache is found in the lava, we don't drop things
	var/static/list/lava_safeties_typecache = typecacheof(list(/obj/structure/lattice/catwalk, /obj/structure/lattice/lava))
	var/list/found_safeties = typecache_filter_list(contents, lava_safeties_typecache)
	return LAZYLEN(found_safeties)

/turf/open/floor/plating/ocean/plating_real
	name = "plating"
	icon = 'icons/turf/floors.dmi'
	icon_state = "plating"
