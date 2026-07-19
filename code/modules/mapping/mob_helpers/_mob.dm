/obj/effect/mapping_helpers/mobs
	layer = ABOVE_ALL_MOB_LAYER
	plane = GAME_PLANE_FOV_HIDDEN // mob plane
	alpha = 120 // see the mob
	/// Mob type to look for
	var/mob_type = /mob/living

/obj/effect/mapping_helpers/mobs/Initialize(mapload)
	. = ..()
	if(!mapload)
		log_mapping("[src] spawned outside of mapload!")
		return

	var/mob/mob = locate(mob_type) in loc
	if(!mob)
		log_mapping("[src] failed to find a mob at [AREACOORD(src)]")
		return

	payload(mob)

	return INITIALIZE_HINT_QDEL

/obj/effect/mapping_helpers/mobs/proc/payload(mob/thing)
	return

/obj/effect/mapping_helpers/mobs/basic
	mob_type = /mob/living/basic
