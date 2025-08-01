SUBSYSTEM_DEF(occult_research)
	name = "Occult Research"
	flags = SS_BACKGROUND
	wait = 30 SECONDS // How often to process research points
	var/base_research_rate = 1 // Base points per tick
	var/necromancy_bonus = 0.5 // Additional bonus for necromancy
	var/thaumaturgy_bonus = 0.5 // Additional bonus for thaumaturgy

/datum/controller/subsystem/occult_research/fire(resumed = FALSE)
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(!H.client) // Skip NPCs and disconnected players
			continue
		if(H.stat >= HARD_CRIT) // Skip dead/critically injured players
			continue
		if(!H.thaumaturgy_knowledge && !H.necromancy_knowledge) // Skip players without occult knowledge
			continue

		process_research_points(H)

/datum/controller/subsystem/occult_research/proc/process_research_points(mob/living/carbon/human/user)
	var/research_gain = 0
	var/has_necromancy = FALSE
	var/has_thaumaturgy = FALSE

	// Check what disciplines the user has
	for(var/datum/action/discipline/D in user.actions)
		if(!D || !D.discipline)
			continue

		switch(D.discipline.name)
			if("Necromancy")
				has_necromancy = TRUE
			if("Thaumaturgy")
				has_thaumaturgy = TRUE

	// Calculate research gain based on disciplines
	if(has_necromancy || has_thaumaturgy)
		research_gain = base_research_rate

		if(has_necromancy)
			research_gain += necromancy_bonus
		if(has_thaumaturgy)
			research_gain += thaumaturgy_bonus

		// Add the research points
		user.research_points += research_gain

		if(world.time % (5 MINUTES) == 0)
			to_chat(user, span_notice("Your occult studies have yielded [research_gain] research points. Total: [user.research_points]"))

/mob/living/carbon/human/verb/check_research_points()
	set name = "Check Research Points"
	set category = "IC"
	set desc = "Check your current research point balance."

	if(!thaumaturgy_knowledge && !necromancy_knowledge)
		to_chat(src, span_alert("You lack occult knowledge."))
		return

	to_chat(src, span_notice("You currently have [research_points] research points."))

