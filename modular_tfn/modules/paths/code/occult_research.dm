SUBSYSTEM_DEF(occult_research)
	name = "Occult Research"
	flags = SS_BACKGROUND
	wait = 60 SECONDS // How often to process research points
	var/base_research_rate = 2 // Base points per tick
	var/necromancy_bonus = 1 // Additional bonus for necromancy
	var/thaumaturgy_bonus = 1 // Additional bonus for thaumaturgy
	var/obtenebration_bonus = 1
	var/list/collected_blood = list()

/datum/controller/subsystem/occult_research/fire(resumed = FALSE)
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(!H.client)
			continue
		if(H.stat >= HARD_CRIT)
			continue
		if(!HAS_TRAIT(H, TRAIT_THAUMATURGY_KNOWLEDGE) && !H.necromancy_knowledge)
			continue

		process_research_points(H)

/datum/controller/subsystem/occult_research/proc/process_research_points(mob/living/carbon/human/user)
	var/research_gain = 0
	var/has_necromancy = FALSE
	var/has_thaumaturgy = FALSE
	var/has_obtenebration

	// Check what disciplines the user has
	for(var/datum/action/discipline/D in user.actions)
		if(!D || !D.discipline)
			continue

		switch(D.discipline.name)
			if("Necromancy")
				has_necromancy = TRUE
			if("Thaumaturgy")
				has_thaumaturgy = TRUE
			if("Obtenebration")
				has_obtenebration = TRUE

	// Calculate research gain
	if(has_necromancy || has_thaumaturgy)
		research_gain = base_research_rate

		if(has_necromancy)
			research_gain += necromancy_bonus
		if(has_thaumaturgy)
			research_gain += thaumaturgy_bonus
		if(has_obtenebration)
			research_gain += obtenebration_bonus

		// Add the research points
		user.research_points += research_gain

		if(world.time % (10 MINUTES) == 0)
			to_chat(user, span_notice("Your occult studies have yielded [research_gain] research points. Total: [user.research_points]"))

/mob/living/carbon/human/verb/check_research_points()
	set name = "Check Research Points"
	set category = "IC"
	set desc = "Check your current research point balance."

	if(!HAS_TRAIT(src, TRAIT_THAUMATURGY_KNOWLEDGE) && !necromancy_knowledge)
		to_chat(src, span_alert("You lack occult knowledge."))
		return

	to_chat(src, span_notice("You currently have [research_points] research points."))


// Check if blood sample has been collected and award research points
/datum/controller/subsystem/occult_research/proc/process_blood_collection(mob/living/carbon/human/caster, datum/reagent/blood/blood_sample)
	if(!blood_sample || !blood_sample.data)
		return

	var/blood_data = blood_sample.data
	var/blood_species = blood_data["species"]
	var/blood_name = blood_data["real_name"]

	// Only process certain species
	if(!(blood_species in list(/datum/species/kindred, /datum/species/garou, /datum/species/ghoul, /datum/species/kuei_jin)))
		return

	// Create unique identifier for this blood sample
	var/blood_identifier = "[blood_name]_[blood_species]"

	// Check if we've already collected this blood
	if(blood_identifier in collected_blood)
		to_chat(caster, span_notice("You have already analyzed blood from this individual."))
		return

	// Add to collected blood list
	collected_blood += blood_identifier

	// Research points awarded based on species, clan, generation
	var/research_award = 0
	var/species_name = ""
	var/research_message = ""

	switch(blood_species)
		if("kindred")
			var/generation = blood_data["generation"]
			var/clan = blood_data["clan"]
			research_award = (14 - generation) * 5 //im assuming not many people will exactly want to give the TREMERE their blood so, perhaps this needs to be balanced in the future
			species_name = "Kindred"
			research_message = "You gain new insights into the [species_name] from clan [clan]! You gain [research_award] research points."
		if("garou")
			research_award = 30
			species_name = "Garou"
			research_message = "The blood of the [species_name]! Its blood burns with fury and rage - You gain [research_award] research points."
		if("ghoul")
			research_award = 5
			species_name = "Ghoul"
			research_message = "The blood of a [species_name] servitor. How boring. You gain [research_award] research points."
		if("kuei-jin")
			research_award = 15
			species_name = "Kuei-Jin"
			research_message = "The blood of the Cathayans. You gain [research_award] research points."

	caster.research_points += research_award
	to_chat(caster, span_notice("[research_message]"))
