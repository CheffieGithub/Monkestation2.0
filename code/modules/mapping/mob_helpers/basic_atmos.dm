/obj/effect/mapping_helpers/mobs/basic/atmos
	icon_state = "basic_atmos"
	/// List to replace keys in the mobs habitable_atmos list
	var/list/habitable_atmos = list()

/obj/effect/mapping_helpers/mobs/basic/atmos/payload(mob/living/basic/thing)
	if(!length(habitable_atmos))
		log_mapping("[src] had no atmos override set!")
		return

	var/static/list/all_keys = list(
		"min_oxy",
		"max_oxy",
		"min_plas",
		"max_plas",
		"min_co2",
		"max_co2",
		"min_n2",
		"max_n2",
	)

	// No length set the list
	if(!length(thing.habitable_atmos))
		thing.habitable_atmos = habitable_atmos
		thing.apply_atmos_requirements()
		return

	var/list/existing_keys = list()
	for(var/key in habitable_atmos)
		if(!(key in all_keys))
			stack_trace("[src] ([type]) has an invalid gas string for habitable_atmos!")
			continue
		existing_keys += key

	var/list/replacement = habitable_atmos
	for(var/key in thing.habitable_atmos)
		if(key in existing_keys)
			continue
		if(!(key in all_keys))
			stack_trace("[thing] ([thing.type]) has an invalid gas string for habitable_atmos!")
			// No continue intentionally it doesn't do anything
		replacement[key] = thing.habitable_atmos[key]

	thing.RemoveElement(/datum/element/atmos_requirements, thing.habitable_atmos, thing.unsuitable_atmos_damage)

	thing.habitable_atmos = replacement

	thing.apply_atmos_requirements()

/// Swap a basic mobs oxygen requirement for nitrogen
/obj/effect/mapping_helpers/mobs/basic/atmos/nitrogen
	habitable_atmos = list(
		"min_n2" = 5,
		"max_n2" = 0,
	)

/// Swap a basic mobs oxygen requirement for nitrogen and make oxygen toxic
/obj/effect/mapping_helpers/mobs/basic/atmos/vox
	habitable_atmos = list(
		"min_oxy" = 0,
		"max_oxy" = 5,
		"min_n2" = 5,
		"max_n2" = 0,
	)
