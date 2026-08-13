/// Define a path with all the requirements for it to process as an ocean turf
#define DEFINE_OCEAN_TURF(path) \
	##path/ocean {\
		turf_flags = parent_type::turf_flags | NO_FLUID_GROUPS; \
	}\
	##path/ocean/Initialize(mapload) {\
		. = ..();\
		SSocean.add_turf(src); \
	}\
