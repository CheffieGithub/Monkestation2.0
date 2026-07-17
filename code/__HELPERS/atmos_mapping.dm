/// Generate a full list of subtyped atmos for this turf subtype, /atmos pathing for mapping convience only
#define MAPPING_GASMIX_HELPERS(path) \
	##path/atmos/airless {\
		initial_gas_mix = AIRLESS_ATMOS; \
	} \
	##path/atmos/low_pressure {\
		initial_gas_mix = OPENTURF_LOW_PRESSURE; \
	} \
	##path/atmos/air_co2 {\
		initial_gas_mix = OPENTURF_AIR_CO2; \
	}\
	##path/atmos/carbon_dioxide {\
		initial_gas_mix = OPENTURF_CO2; \
	}\
	##path/atmos/carbon_dioxide/low {\
		initial_gas_mix = OPENTURF_CO2_LOW; \
	}\
	##path/atmos/nitrogen {\
		initial_gas_mix = OPENTURF_NITROGEN; \
	}\
	##path/atmos/nitrogen/low {\
		initial_gas_mix = OPENTURF_NITROGEN_LOW; \
	}\
	##path/atmos/telecoms {\
		initial_gas_mix = TCOMMS_ATMOS; \
	}\
	##path/atmos/lavaland {\
		initial_gas_mix = LAVALAND_DEFAULT_ATMOS; \
	}\
	##path/atmos/icemoon {\
		initial_gas_mix = ICEMOON_DEFAULT_ATMOS; \
	}\
