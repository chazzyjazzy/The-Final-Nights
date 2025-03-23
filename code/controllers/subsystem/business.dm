/// Handles business related things.
SUBSYSTEM_DEF(business)
	name = "Business"
	init_order = INIT_ORDER_BUSINESS
	flags = SS_NO_FIRE

	var/list/businesses = list()
	var/list/business_access_list = list()
	var/list/all_business_ids = list()

/datum/controller/subsystem/business/Initialize(timeofday)
	//load_all_businesses()

	businesses = GLOB.all_businesses
	business_access_list = GLOB.all_business_accesses
	all_business_ids = GLOB.business_ids

	. = ..()

/datum/controller/subsystem/business/proc/refresh_all_businesses()
	for(var/datum/business/B in businesses)
		B.refresh_business_support_list()
