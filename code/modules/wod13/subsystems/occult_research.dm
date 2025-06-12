SUBSYSTEM_DEF(research)
	name = "Research"
	priority = FIRE_PRIORITY_RESEARCH
	wait = 50  // Slower tick for WoD - research is more methodical
	init_order = INIT_ORDER_RESEARCH
	flags = SS_KEEP_TIMING

	// RESEARCH POINTS - Simple accumulation system
	var/list/research_points = list()          // point_type = current_amount
	var/list/point_income = list()             // point_type = points_per_tick
	var/list/point_multipliers = list()        // point_type = multiplier

	// RESEARCH EQUIPMENT
	var/list/obj/machinery/research_equipment = list()  // Objects that boost research
	var/list/research_boost_items = list()     // Items that provide research when used

	// FACTION RESEARCH PATHS
	var/list/datum/research_path/research_paths = list()  // Available research paths
	var/list/faction_subsystems = list()       // Faction-specific research handlers

	// BASE INCOME RATES (per tick)
	var/base_mundane_income = 5
	var/base_occult_income = 1
